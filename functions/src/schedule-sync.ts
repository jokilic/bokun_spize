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
  NOTIFICATION_DEFINITIONS,
  NOTIFICATION_TYPES,
} from "./notification-config";
import {getNextOccurrence} from "./scheduling";

/**
 * Pure schedule update where a Date writes a timestamp and null deletes a field
 */
export type SchedulePatch = Record<string, Date | null>;

/** Builds schedule changes after a client preference or timezone update */
export function buildSchedulePatch(
  before: DocumentData | undefined,
  after: DocumentData,
  now: Date,
): SchedulePatch {
  const patch: SchedulePatch = {};

  // Every enabled schedule must be recalculated when its local timezone changes
  const timezoneChanged = before?.timezone !== after.timezone;

  for (const type of NOTIFICATION_TYPES) {
    const definition = NOTIFICATION_DEFINITIONS[type];
    const wasEnabled = before?.[definition.enabledField] === true;
    const isEnabled = after[definition.enabledField] === true;
    const hasNextOccurrence = after[definition.nextAtField] !== undefined;

    // Disabled notifications must not remain visible to indexed due queries
    if (!isEnabled && hasNextOccurrence) {
      patch[definition.nextAtField] = null;
      continue;
    }

    // Preserve an existing timestamp unless activation, repair or timezone change requires a new one
    if (isEnabled && (!wasEnabled || !hasNextOccurrence || timezoneChanged)) {
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
): Promise<void> {
  // Keep calculation separate from persistence so scheduling rules remain easy to test
  const schedulePatch = buildSchedulePatch(before, after, now);
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
