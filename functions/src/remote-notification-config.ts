/**
 * Server-only notification timing overrides
 *
 * Production defaults remain in source control while Firebase Console can
 * temporarily move the weigh reminder for end-to-end delivery testing
 */

import {Firestore, Timestamp} from "firebase-admin/firestore";
import {DateTime} from "luxon";

import {
  getNotificationDefinitions,
  NotificationDefinition,
  NotificationType,
} from "./notification-config";

/** Firestore document editable through Firebase Console by trusted operators */
export const NOTIFICATION_CONFIG_PATH = "config/notifications";

/** Timezone used by Firebase Console operators when entering reminder overrides */
export const NOTIFICATION_CONFIG_TIMEZONE = "Europe/Zagreb";

/** Extracts the Zagreb wall-clock time entered through Firebase Console */
export function getWeightReminderTimeParts(
  value: unknown,
): {hour: number; minute: number} {
  if (!(value instanceof Timestamp)) {
    return {hour: 9, minute: 0};
  }

  const time = DateTime.fromJSDate(value.toDate(), {zone: "utc"}).setZone(
    NOTIFICATION_CONFIG_TIMEZONE,
  );

  return {
    hour: time.hour,
    minute: time.minute,
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
