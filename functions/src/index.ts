/**
 * Cloud Functions entry point
 *
 * Account cleanup, meal processing, and notification scheduling
 */

import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {getStorage} from "firebase-admin/storage";
import {region} from "firebase-functions/v1";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";

import {
  ACCOUNT_DELETION_JOBS,
  enqueueAccountDeletion,
  hasRecentAuthentication,
  resumeAccountDeletions,
} from "./account-deletion";
import {dispatchDueNotifications} from "./dispatcher";
import {synchronizeNotificationSchedule} from "./schedule-sync";
import {
  cleanupExpiredAIMealRequests,
  APP_STORAGE_BUCKET,
  processCallableAIMeal,
} from "./meal-ai";
// Use Application Default Credentials supplied by the Cloud Functions runtime
initializeApp();

/** Queues cleanup for older clients and accounts deleted outside the app */
// Firebase Auth deletion is first generation and requires a first-generation region
export const cleanupDeletedUser = region("europe-west1")
  .runWith({
    timeoutSeconds: 540,
    memory: "256MB",
    failurePolicy: true,
  })
  .auth.user().onDelete(async (user) => {
    await enqueueAccountDeletion(getFirestore(), user.uid, true);
  });

/** Accepts a deletion request after client-side provider revocation */
export const requestAccountDeletion = onCall(
  {region: "europe-west8", enforceAppCheck: true},
  async (request) => {
    const auth = request.auth;
    if (auth === undefined) {
      throw new HttpsError("unauthenticated", "Authentication is required");
    }
    if (request.data?.expectedUid !== auth.uid) {
      throw new HttpsError("permission-denied", "The signed-in account changed");
    }

    const firestore = getFirestore();
    const existingJob = await firestore.collection(ACCOUNT_DELETION_JOBS).doc(auth.uid).get();
    if (existingJob.exists) {
      return {accepted: true};
    }
    if (!hasRecentAuthentication(auth.token.auth_time)) {
      throw new HttpsError("failed-precondition", "Sign in again before deleting your account");
    }

    // Check revocation before creating a job from a still-unexpired ID token
    try {
      await getAuth().verifyIdToken(auth.rawToken, true);
    } catch (error) {
      if (error instanceof Error && "code" in error &&
        (error.code === "auth/id-token-revoked" || error.code === "auth/id-token-expired" ||
          error.code === "auth/user-not-found" || error.code === "auth/user-disabled")) {
        throw new HttpsError("unauthenticated", "Sign in again before deleting your account");
      }
      throw error;
    }

    await enqueueAccountDeletion(firestore, auth.uid);
    return {accepted: true};
  },
);

/** Resumes queued deletion work without requiring the client's token or connection */
export const resumeQueuedAccountDeletions = onSchedule(
  {
    schedule: "every 5 minutes",
    region: "europe-west1",
    memory: "512MiB",
    timeoutSeconds: 540,
    maxInstances: 1,
    concurrency: 1,
  },
  async () => {
    const bucket = getStorage().bucket(APP_STORAGE_BUCKET);
    await resumeAccountDeletions(getFirestore(), getAuth(), async (userId) => {
      await bucket.deleteFiles({
        prefix: `users/${userId}/`,
        versions: true,
        force: true,
      });
    });
  },
);

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
