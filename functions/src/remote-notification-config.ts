/**
 * Server-only notification timing overrides
 *
 * Production defaults remain in source control while Firebase Console can
 * temporarily move the weigh reminder for end-to-end delivery testing
 */

import {Firestore} from "firebase-admin/firestore";

import {
  getNotificationDefinitions,
  NotificationDefinition,
  NotificationType,
} from "./notification-config";

/** Firestore document editable through Firebase Console by trusted operators */
export const NOTIFICATION_CONFIG_PATH = "config/notifications";

/** Loads a valid global weigh reminder time and falls back to 09:00 */
export async function getConfiguredNotificationDefinitions(
  firestore: Firestore,
): Promise<Record<NotificationType, NotificationDefinition>> {
  const snapshot = await firestore.doc(NOTIFICATION_CONFIG_PATH).get();
  const data = snapshot.data();
  const configuredHour = data?.weighReminderHour;
  const configuredMinute = data?.weighReminderMinute;
  const hour = typeof configuredHour === "number" && Number.isInteger(configuredHour) && configuredHour >= 0 && configuredHour <= 23
    ? configuredHour
    : 9;
  const minute = typeof configuredMinute === "number" && Number.isInteger(configuredMinute) && configuredMinute >= 0 && configuredMinute <= 59
    ? configuredMinute
    : 0;

  return getNotificationDefinitions(hour, minute);
}
