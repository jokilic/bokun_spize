/**
 * Cloud Functions entry point
 *
 * One Firestore trigger maintains due timestamps and one scheduled trigger
 * queries those timestamps and sends notifications through FCM
 */

import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";

import {dispatchDueNotifications} from "./dispatcher";
import {synchronizeNotificationSchedule} from "./schedule-sync";

// Use Application Default Credentials supplied by the Cloud Functions runtime
initializeApp();

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

/** Finds and sends due notifications every ten minutes */
export const dispatchScheduledNotifications = onSchedule(
  {
    // The ten-minute cadence balances delivery delay with scheduler and query cost
    schedule: "every 10 minutes",

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
