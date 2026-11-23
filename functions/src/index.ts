/**
 * Cloud Functions entry point
 *
 * Account cleanup, meal processing, and notification scheduling
 */

import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {getStorage} from "firebase-admin/storage";
import {region} from "firebase-functions/v1";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";

import {dispatchDueNotifications} from "./dispatcher";
import {synchronizeNotificationSchedule} from "./schedule-sync";
import {
  cleanupExpiredAIMealRequests,
  MEAL_IMAGE_BUCKET,
  processCallableAIMeal,
} from "./meal-ai";
// Use Application Default Credentials supplied by the Cloud Functions runtime
initializeApp();

/** Recursively removes private data after a Firebase Auth account is deleted */
export const cleanupDeletedUser = region("europe-west8")
  .runWith({
    timeoutSeconds: 540,
    memory: "256MB",
    failurePolicy: true,
  })
  .auth.user().onDelete(async (user) => {
    const firestore = getFirestore();
    const userDocument = firestore.collection("users").doc(user.uid);
    const userStoragePrefix = `users/${user.uid}/`;

    // Both operations are idempotent so failed event deliveries can retry safely
    await Promise.all([
      firestore.recursiveDelete(userDocument),
      getStorage().bucket(MEAL_IMAGE_BUCKET).deleteFiles({
        prefix: userStoragePrefix,
      }),
    ]);
  });

/** Generates one authenticated meal while uploading its optional image concurrently */
export const generateAIMeal = onCall(
  {
    region: "europe-west8",
    enforceAppCheck: true,
    timeoutSeconds: 120,
    memory: "1GiB",
  },
  async (request) => {
    const userId = request.auth?.uid;

    if (userId === undefined) {
      throw new HttpsError("unauthenticated", "Authentication is required");
    }

    return processCallableAIMeal(
      userId,
      request.data,
    );
  },
);

/** Finishes callable AI requests interrupted before reaching a terminal state */
export const cleanupAbandonedAIMeals = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "Etc/UTC",
    region: "europe-west8",
    memory: "256MiB",
    timeoutSeconds: 540,
    maxInstances: 1,
    retryCount: 3,
    minBackoffSeconds: 30,
  },
  async () => {
    await cleanupExpiredAIMealRequests(
      getFirestore(),
      new Date(),
    );
  },
);

/** Keeps server-managed due timestamps aligned with client preferences */
export const syncNotificationSchedule = onDocumentWritten(
  {
    // Only the single preferences document under each user affects schedules
    document: "users/{userId}/notificationSettings/preferences",

    // Keep both functions together in the nearest configured European region
    region: "europe-west1",

    // Safe retries rely on schedule synchronization producing the same desired values
    retry: true,
  },
  async (event) => {
    const after = event.data?.after;

    // Deletions need no follow-up because their timestamps disappear with the document
    if (after === undefined || !after.exists) {
      return;
    }

    // Passing before and after data reveals activation and timezone changes
    await synchronizeNotificationSchedule(
      event.data?.before.data(),
      after.data() ?? {},
      after.ref,
      new Date(),
    );
  },
);

/** Finds and sends due notifications every five minutes */
export const dispatchScheduledNotifications = onSchedule(
  {
    schedule: "every 5 minutes",

    // User-local timing is handled per document rather than by the scheduler timezone
    timeZone: "Etc/UTC",
    region: "europe-west1",
    memory: "256MiB",

    // Leave enough time for multiple users and FCM batches in one invocation
    timeoutSeconds: 540,

    // Limit normal concurrency while transaction reservations still protect manual overlaps
    maxInstances: 1,

    // Transient scheduler failures may retry without duplicating reserved occurrences
    retryCount: 3,
    minBackoffSeconds: 30,
  },
  async () => {
    // Capture one clock value so every due comparison in this run is consistent
    await dispatchDueNotifications(
      getFirestore(),
      getMessaging(),
      new Date(),
    );
  },
);
