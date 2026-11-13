/**
 * Pure date and due-selection helpers shared by triggers and the dispatcher
 *
 * Firestore stores UTC timestamps while users expect a fixed local wall-clock
 * time, so timezone conversion happens only while calculating occurrences
 */

import {DocumentData, Timestamp} from "firebase-admin/firestore";
import {DateTime} from "luxon";

import {
  DEFAULT_TIMEZONE,
  NotificationDefinition,
} from "./notification-config";

/** Returns a valid IANA timezone or the UTC fallback */
export function getValidTimezone(timezone: unknown): string {
  // Luxon validates the identifier against the runtime's IANA timezone data
  if (typeof timezone !== "string" || !DateTime.local().setZone(timezone).isValid) {
    return DEFAULT_TIMEZONE;
  }

  return timezone;
}

/** Calculates the next local occurrence strictly after the supplied UTC instant */
export function getNextOccurrence(
  after: Date,
  timezone: string,
  definition: Pick<NotificationDefinition, "hour" | "minute">,
): Date {
  const zone = getValidTimezone(timezone);

  // Convert the UTC reference instant to the user's local calendar and offset
  const localAfter = DateTime.fromJSDate(after, {zone: "utc"}).setZone(zone);

  // First try today's requested wall-clock time in the user's timezone
  let next = localAfter.startOf("day").set({
    hour: definition.hour,
    minute: definition.minute,
    second: 0,
    millisecond: 0,
  });

  // Move to tomorrow when today's occurrence has already happened
  // Adding a calendar day lets Luxon apply any DST offset change automatically
  if (next <= localAfter) {
    next = localAfter.plus({days: 1}).startOf("day").set({
      hour: definition.hour,
      minute: definition.minute,
      second: 0,
      millisecond: 0,
    });
  }

  // Firestore timestamps are absolute instants so convert back to UTC
  return next.toUTC().toJSDate();
}

/** Converts Firestore or JavaScript date values into a Date */
export function getDate(value: unknown): Date | null {
  // Production settings read timestamps through the Firebase Admin SDK
  if (value instanceof Timestamp) {
    return value.toDate();
  }

  // Unit tests and pure helpers may already provide native dates
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return value;
  }

  return null;
}

/** Reports whether one notification type is enabled and due */
export function isNotificationDue(
  settings: DocumentData,
  definition: NotificationDefinition,
  now: Date,
): boolean {
  const nextAt = getDate(settings[definition.nextAtField]);

  // Both conditions are checked again inside the reservation transaction
  return settings[definition.enabledField] === true && nextAt !== null && nextAt.getTime() <= now.getTime();
}

/** Creates the stable per-user key used to suppress a duplicate local-day delivery */
export function getDispatchId(
  definition: NotificationDefinition,
  dueAt: Date,
  timezone: string,
): string {
  // The local date is intentional because one logical occurrence exists per user day
  const localDate = DateTime.fromJSDate(dueAt, {zone: "utc"})
    .setZone(getValidTimezone(timezone))
    .toFormat("yyyy-LL-dd");

  // This value is also the Firestore dispatch document ID
  return `${definition.type}_${localDate}`;
}
