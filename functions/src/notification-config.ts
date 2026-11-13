/**
 * Shared notification configuration used by scheduling and FCM delivery
 *
 * Adding a new scheduled notification starts here because each definition maps
 * the user preference fields to its delivery time, route, channel and copy
 */

/** Notification identifiers shared with the Flutter FCM payload parser */
export type NotificationType = "weightReminder" | "dailySummary";

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
  nextAtField: "nextWeighReminderAt" | "nextDailySummaryAt";

  /** Local wall-clock delivery time interpreted in the user's IANA timezone */
  hour: number;
  minute: number;

  /** Flutter screen opened when the user taps the notification */
  route: "weights" | "meals";

  /** Android channel created by the Flutter application */
  androidChannelId: "reminders" | "daily_summaries";

  /** Maximum time FCM and platform services may keep an obsolete message */
  ttlSeconds: number;

  /** Suppresses delivery when a weight entry already exists for the due local date */
  skipWhenWeightRecorded: boolean;

  /** Localized copy sent to devices grouped by locale */
  copy: Record<SupportedLocale, NotificationCopy>;
}

/**
 * Source of truth for scheduled notification behavior
 *
 * Field names must remain aligned with the Firestore settings schema and
 * indexes while route and type values must match the Flutter enums
 */
export function getNotificationDefinitions(
  weighReminderHour = 9,
  weighReminderMinute = 0,
): Record<NotificationType, NotificationDefinition> {
  return {
    // Morning reminder intended to arrive before the user's first meal
    weightReminder: {
      type: "weightReminder",
      enabledField: "weighReminderEnabled",
      nextAtField: "nextWeighReminderAt",
      hour: weighReminderHour,
      minute: weighReminderMinute,
      route: "weights",
      androidChannelId: "reminders",
      ttlSeconds: 30 * 60,
      skipWhenWeightRecorded: true,
      copy: {
        en: {
          title: "Time to weigh in",
          body: "Record your weight before your first meal",
        },
        hr: {
          title: "Vrijeme je za vaganje",
          body: "Zabilježi težinu prije prvog obroka",
        },
      },
    },
    // Morning recap of the user's previous day
    dailySummary: {
      type: "dailySummary",
      enabledField: "dailySummaryEnabled",
      nextAtField: "nextDailySummaryAt",
      hour: 8,
      minute: 0,
      route: "meals",
      androidChannelId: "daily_summaries",
      ttlSeconds: 2 * 60 * 60,
      skipWhenWeightRecorded: false,
      copy: {
        en: {
          title: "Yesterday at a glance",
          body: "Review your meals, weight and walks",
        },
        hr: {
          title: "Jučerašnji pregled",
          body: "Pregledaj obroke, težinu i šetnje",
        },
      },
    },
  };
}

/** Default definitions used when no server-side testing override exists */
export const NOTIFICATION_DEFINITIONS = getNotificationDefinitions();

/** Iterable list derived from the definitions to avoid maintaining two sources */
export const NOTIFICATION_TYPES = Object.keys(NOTIFICATION_DEFINITIONS) as NotificationType[];

/** Safe scheduling fallback when a stored timezone is missing or invalid */
export const DEFAULT_TIMEZONE = "UTC";

/** Locale used when a settings or device document contains an unsupported value */
export const DEFAULT_LOCALE: SupportedLocale = "hr";

/** Registrations older than this window are ignored even before Firestore TTL cleanup */
export const DEVICE_ACTIVE_DAYS = 30;

/** Maximum number of due users processed per notification type and scheduler run */
export const DUE_QUERY_LIMIT = 100;

/** Maximum token count accepted by the Firebase Admin multicast API */
export const FCM_MULTICAST_LIMIT = 500;

/** Returns a supported locale and falls back to Croatian */
export function getSupportedLocale(value: unknown): SupportedLocale {
  return value === "en" || value === "hr" ? value : DEFAULT_LOCALE;
}
