/**
 * Server-only notification timing overrides
 *
 * Production defaults remain in source control while Firebase Console can
 * temporarily move the weigh reminder for end-to-end delivery testing
 */

import {Firestore, Timestamp} from "firebase-admin/firestore";

import {
  getNotificationDefinitions,
  NotificationDefinition,
  NotificationType,
} from "./notification-config";

/** Firestore document editable through Firebase Console by trusted operators */
export const NOTIFICATION_CONFIG_PATH = "config/notifications";

/** Extracts the UTC hour and minute while deliberately ignoring the timestamp date */
export function getWeightReminderTimeParts(
  value: unknown,
): {hour: number; minute: number} {
  if (!(value instanceof Timestamp)) {
    return {hour: 9, minute: 0};
  }

  const time = value.toDate();

  return {
    hour: time.getUTCHours(),
    minute: time.getUTCMinutes(),
  };
}

/** Loads a valid global weigh reminder time and falls back to 09:00 */
export async function getConfiguredNotificationDefinitions(
  firestore: Firestore,
): Promise<Record<NotificationType, NotificationDefinition>> {
  const snapshot = await firestore.doc(NOTIFICATION_CONFIG_PATH).get();
  const data = snapshot.data();
  const {hour, minute} = getWeightReminderTimeParts(data?.weightReminderTime);

  return getNotificationDefinitions(hour, minute);
}
