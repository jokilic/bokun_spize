/**
 * Shared notification configuration used by scheduling and FCM delivery
 *
 * Adding a new scheduled notification starts here because each definition maps
 * the user preference fields to its delivery time, route, channel and copy
 */

import {Timestamp} from "firebase-admin/firestore";
import {DateTime} from "luxon";

/** Notification identifiers shared with the Flutter FCM payload parser */
export type NotificationType = "weightReminder" | "dailySummaryPrepare" | "dailySummary";

/** Locales supported by both the Flutter app and notification copy */
export type SupportedLocale = "en" | "hr";

/** User-visible title and body for one locale */
export interface NotificationCopy {
  title: string;
  body: string;
}

/** Complete configuration needed to schedule and deliver one notification type */
export interface NotificationDefinition {
  /** Stable identifier placed in the FCM data payload */
  type: NotificationType;

  /** Boolean preference field stored in the notification settings document */
  enabledField: "weighReminderEnabled" | "dailySummaryEnabled";

  /** Server-managed timestamp queried by the scheduled dispatcher */
  nextAtField: "nextWeighReminderAt" | "nextDailySummaryPrepareAt" | "nextDailySummaryAt";

  /** Whether FCM displays an alert or only wakes the app for background work */
  delivery: "alert" | "background";

  /** Local wall-clock delivery time interpreted in the user's IANA timezone */
  hour: number;
  minute: number;

  /** Flutter screen opened when the user taps the notification */
  route: "weights" | "meals";

  /** Android channel created by the Flutter application */
  androidChannelId: "reminders" | "daily_summaries";

  /** Android notification icon accent sent in the FCM payload */
  androidColor: string;

  /** Maximum time FCM and platform services may keep an obsolete message */
  ttlSeconds: number;

  /** Suppresses delivery when a weight entry already exists for the due local date */
  skipWhenWeightRecorded: boolean;

  /** Localized copy sent to devices grouped by locale */
  copy: Record<SupportedLocale, NotificationCopy>;
}

/** Lead time between the silent step sync request and the visible recap */
export const DAILY_SUMMARY_PREPARE_MINUTES = 15;

/** Subtracts minutes from a wall-clock time while wrapping across midnight */
export function subtractTimeMinutes(
  hour: number,
  minute: number,
  minutesToSubtract: number,
): {hour: number; minute: number} {
  const minutesPerDay = 24 * 60;
  const totalMinutes = (
    hour * 60 + minute - minutesToSubtract + minutesPerDay
  ) % minutesPerDay;

  return {
    hour: Math.floor(totalMinutes / 60),
    minute: totalMinutes % 60,
  };
}

/**
 * Source of truth for scheduled notification behavior
 *
 * Field names must remain aligned with the Firestore settings schema and
 * indexes while route and type values must match the Flutter enums
 */
export function getNotificationDefinitions(
  weightReminderHour = 9,
  weightReminderMinute = 0,
  dailyRecapHour = 8,
  dailyRecapMinute = 0,
): Record<NotificationType, NotificationDefinition> {
  const dailySummaryPrepareTime = subtractTimeMinutes(
    dailyRecapHour,
    dailyRecapMinute,
    DAILY_SUMMARY_PREPARE_MINUTES,
  );

  return {
    // Morning reminder intended to arrive before the user's first meal
    weightReminder: {
      type: "weightReminder",
      enabledField: "weighReminderEnabled",
      nextAtField: "nextWeighReminderAt",
      delivery: "alert",
      hour: weightReminderHour,
      minute: weightReminderMinute,
      route: "weights",
      androidChannelId: "reminders",
      androidColor: "#4F5094",
      ttlSeconds: 30 * 60,
      skipWhenWeightRecorded: true,
      copy: {
        en: {
          title: "Reminder to weigh",
          body: "Log your daily weight",
        },
        hr: {
          title: "Podsjetnik za vaganje",
          body: "Zabilježi svoju dnevnu težinu",
        },
      },
    },
    // Silent wake-up that gives the device time to upload yesterday's step total
    dailySummaryPrepare: {
      type: "dailySummaryPrepare",
      enabledField: "dailySummaryEnabled",
      nextAtField: "nextDailySummaryPrepareAt",
      delivery: "background",
      hour: dailySummaryPrepareTime.hour,
      minute: dailySummaryPrepareTime.minute,
      route: "meals",
      androidChannelId: "daily_summaries",
      androidColor: "#3B7D5E",
      ttlSeconds: DAILY_SUMMARY_PREPARE_MINUTES * 60,
      skipWhenWeightRecorded: false,
      copy: {
        en: {
          title: "",
          body: "",
        },
        hr: {
          title: "",
          body: "",
        },
      },
    },
    // Morning recap of the user's previous day
    dailySummary: {
      type: "dailySummary",
      enabledField: "dailySummaryEnabled",
      nextAtField: "nextDailySummaryAt",
      delivery: "alert",
      hour: dailyRecapHour,
      minute: dailyRecapMinute,
      route: "meals",
      androidChannelId: "daily_summaries",
      androidColor: "#3B7D5E",
      ttlSeconds: 2 * 60 * 60,
      skipWhenWeightRecorded: false,
      copy: {
        en: {
          title: "Overview of yesterday",
          body: "Summary of your meals, weight & steps",
        },
        hr: {
          title: "Pregled prošlog dana",
          body: "Sažetak tvojih obroka, težine i koraka",
        },
      },
    },
  };
}

/** Default definitions used when no server-side testing override exists */
export const NOTIFICATION_DEFINITIONS = getNotificationDefinitions();

/** Iterable list derived from the definitions to avoid maintaining two sources */
export const NOTIFICATION_TYPES = Object.keys(NOTIFICATION_DEFINITIONS) as NotificationType[];

/** Extracts wall-clock time from a timestamp in the supplied IANA timezone */
export function getTimestampTimeParts(
  value: unknown,
  timezone: string,
): {hour: number; minute: number} | null {
  if (!(value instanceof Timestamp)) {
    return null;
  }

  const time = DateTime.fromJSDate(value.toDate(), {zone: "utc"}).setZone(timezone);

  if (!time.isValid) {
    return null;
  }

  return {
    hour: time.hour,
    minute: time.minute,
  };
}

/** Applies a valid user-specific weigh reminder time to its definition */
export function getNotificationDefinitionForSettings(
  definition: NotificationDefinition,
  settings: Record<string, unknown>,
): NotificationDefinition {
  const timezone = typeof settings.timezone === "string" ? settings.timezone : DEFAULT_TIMEZONE;
  const configuredTime = definition.type === "weightReminder"
    ? getTimestampTimeParts(settings.weighReminderTime, timezone)
    : definition.type === "dailySummary" || definition.type === "dailySummaryPrepare"
      ? getTimestampTimeParts(settings.dailyRecapTime, timezone)
      : null;

  if (configuredTime === null) {
    return definition;
  }

  const time = definition.type === "dailySummaryPrepare"
    ? subtractTimeMinutes(
      configuredTime.hour,
      configuredTime.minute,
      DAILY_SUMMARY_PREPARE_MINUTES,
    )
    : configuredTime;

  return {
    ...definition,
    hour: time.hour,
    minute: time.minute,
  };
}

/** Reports whether all preference fields required by a schedule are enabled */
export function isNotificationDefinitionEnabled(
  settings: Record<string, unknown>,
  definition: NotificationDefinition,
): boolean {
  if (settings[definition.enabledField] !== true) {
    return false;
  }

  return definition.type !== "dailySummaryPrepare" || settings.dailyRecapStepsEnabled === true;
}

/** Safe scheduling fallback when a stored timezone is missing or invalid */
export const DEFAULT_TIMEZONE = "UTC";

/** Locale used when a settings or device document contains an unsupported value */
export const DEFAULT_LOCALE: SupportedLocale = "hr";

/** Registrations older than this window are ignored even before Firestore TTL cleanup */
export const DEVICE_ACTIVE_DAYS = 30;

/** Maximum number of due users processed per notification type and scheduler run */
export const DUE_QUERY_LIMIT = 100;

/** Maximum FID count accepted by the Firebase Admin multicast API */
export const FCM_MULTICAST_LIMIT = 500;

/** Returns a supported locale and falls back to Croatian */
export function getSupportedLocale(value: unknown): SupportedLocale {
  return value === "en" || value === "hr" ? value : DEFAULT_LOCALE;
}
