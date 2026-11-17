/**
 * Synchronizes client-owned preferences with server-owned due timestamps
 *
 * The Flutter client can enable notifications and update its timezone but only
 * trusted server code decides when the next occurrence should be dispatched
 */

import {
  DocumentData,
  DocumentReference,
  FieldValue,
  Timestamp,
} from "firebase-admin/firestore";

import {
  getNotificationDefinitionForSettings,
  isNotificationDefinitionEnabled,
  NOTIFICATION_DEFINITIONS,
  NOTIFICATION_TYPES,
  NotificationDefinition,
  NotificationType,
} from "./notification-config";
import {getDate, getNextOccurrence} from "./scheduling";

/**
 * Pure schedule update where a Date writes a timestamp and null deletes a field
 */
export type SchedulePatch = Record<string, Date | null>;

/** Builds schedule changes after a client preference or timezone update */
export function buildSchedulePatch(
  before: DocumentData | undefined,
  after: DocumentData,
  now: Date,
  definitions: Record<NotificationType, NotificationDefinition> = NOTIFICATION_DEFINITIONS,
  forcedTypes: NotificationType[] = [],
): SchedulePatch {
  const patch: SchedulePatch = {};

  // Every enabled schedule must be recalculated when its local timezone changes
  const timezoneChanged = before?.timezone !== after.timezone;
  const beforeWeighReminderTime = getDate(before?.weighReminderTime);
  const afterWeighReminderTime = getDate(after.weighReminderTime);
  const weighReminderTimeChanged = beforeWeighReminderTime?.getTime() !== afterWeighReminderTime?.getTime();
  const beforeDailyRecapTime = getDate(before?.dailyRecapTime);
  const afterDailyRecapTime = getDate(after.dailyRecapTime);
  const dailyRecapTimeChanged = beforeDailyRecapTime?.getTime() !== afterDailyRecapTime?.getTime();

  for (const type of NOTIFICATION_TYPES) {
    const definition = getNotificationDefinitionForSettings(
      definitions[type],
      after,
    );
    const wasEnabled = before === undefined
      ? false
      : isNotificationDefinitionEnabled(before, definition);
    const isEnabled = isNotificationDefinitionEnabled(after, definition);
    const hasNextOccurrence = after[definition.nextAtField] !== undefined;

    // Disabled notifications must not remain visible to indexed due queries
    if (!isEnabled && hasNextOccurrence) {
      patch[definition.nextAtField] = null;
      continue;
    }

    // Preserve an existing timestamp unless activation, repair or timezone change requires a new one
    const scheduleTimeChanged = type === "weightReminder"
      ? weighReminderTimeChanged
      : dailyRecapTimeChanged;

    if (isEnabled && (!wasEnabled || !hasNextOccurrence || timezoneChanged || scheduleTimeChanged || forcedTypes.includes(type))) {
      patch[definition.nextAtField] = getNextOccurrence(
        now,
        String(after.timezone ?? "UTC"),
        definition,
      );
    }
  }

  return patch;
}

/** Writes server-managed scheduling fields without changing client preferences */
export async function synchronizeNotificationSchedule(
  before: DocumentData | undefined,
  after: DocumentData,
  settingsReference: DocumentReference,
  now: Date,
  definitions: Record<NotificationType, NotificationDefinition> = NOTIFICATION_DEFINITIONS,
  forcedTypes: NotificationType[] = [],
): Promise<void> {
  // Keep calculation separate from persistence so scheduling rules remain easy to test
  const schedulePatch = buildSchedulePatch(
    before,
    after,
    now,
    definitions,
    forcedTypes,
  );
  const entries = Object.entries(schedulePatch);

  // Avoid writing the document again when client changes do not affect scheduling
  if (entries.length === 0) {
    return;
  }

  // Converts pure schedule changes into Firestore update values
  const firestorePatch = Object.fromEntries(
    entries.map(([field, value]) => [
      field,
      // Firestore uses an explicit sentinel to remove disabled schedule fields
      value === null ? FieldValue.delete() : Timestamp.fromDate(value),
    ]),
  );

  // Admin writes bypass client rules while preserving all unrelated preference fields
  await settingsReference.update(firestorePatch);
}
