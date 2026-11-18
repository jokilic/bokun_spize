/**
 * Unit and Firestore emulator coverage for notification scheduling
 *
 * Pure tests always run while the transaction test automatically runs only
 * when Firebase starts this suite with FIRESTORE_EMULATOR_HOST configured
 */

import {randomUUID} from "node:crypto";

import {deleteApp, initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {afterAll, describe, expect, it} from "vitest";

import {reserveDueNotification} from "../src/dispatcher";
import {
  getNotificationDefinitionForSettings,
  NOTIFICATION_DEFINITIONS,
} from "../src/notification-config";
import {buildSchedulePatch} from "../src/schedule-sync";
import {
  getDispatchId,
  getLocalDayBounds,
  getNextOccurrence,
  isNotificationDue,
} from "../src/scheduling";

/** Covers pure due selection, recurrence and schedule synchronization behavior */
describe("notification scheduling", () => {
  /** Verifies due selection uses the indexed next occurrence and enabled flag */
  it("selects only enabled occurrences at or before now", () => {
    const now = new Date("2026-06-01T08:00:00.000Z");
    const definition = NOTIFICATION_DEFINITIONS.weightReminder;

    // An enabled occurrence at exactly now is due
    expect(isNotificationDue({
      weighReminderEnabled: true,
      nextWeighReminderAt: Timestamp.fromDate(now),
    }, definition, now)).toBe(true);

    // The timestamp alone is not enough when the user disabled the preference
    expect(isNotificationDue({
      weighReminderEnabled: false,
      nextWeighReminderAt: Timestamp.fromDate(now),
    }, definition, now)).toBe(false);

    // Enabled future occurrences remain outside the current dispatcher run
    expect(isNotificationDue({
      weighReminderEnabled: true,
      nextWeighReminderAt: Timestamp.fromDate(new Date("2026-06-01T08:01:00.000Z")),
    }, definition, now)).toBe(false);
  });

  /** Verifies spring DST applies the new UTC offset to the next local occurrence */
  it("keeps the same local time across the spring DST transition", () => {
    // Zagreb changes from UTC+1 to UTC+2 before this next occurrence
    const next = getNextOccurrence(
      new Date("2026-03-28T07:30:00.000Z"),
      "Europe/Zagreb",
      {hour: 8, minute: 0},
    );

    expect(next.toISOString()).toBe("2026-03-29T06:00:00.000Z");
  });

  /** Verifies autumn DST applies the standard UTC offset to the next local occurrence */
  it("keeps the same local time across the autumn DST transition", () => {
    // Zagreb changes from UTC+2 to UTC+1 before this next occurrence
    const next = getNextOccurrence(
      new Date("2026-10-24T06:30:00.000Z"),
      "Europe/Zagreb",
      {hour: 8, minute: 0},
    );

    expect(next.toISOString()).toBe("2026-10-25T07:00:00.000Z");
  });

  /** Verifies local-day bounds follow a shortened spring DST calendar day */
  it("calculates weight-entry bounds for the user's local calendar day", () => {
    const bounds = getLocalDayBounds(
      new Date("2026-03-29T10:00:00.000Z"),
      "Europe/Zagreb",
    );

    expect(bounds.start.toISOString()).toBe("2026-03-28T23:00:00.000Z");
    expect(bounds.end.toISOString()).toBe("2026-03-29T22:00:00.000Z");
  });

  /** Verifies distinct local hours remain distinct across the autumn DST change */
  it("includes the local occurrence time in the idempotency key", () => {
    const definition = NOTIFICATION_DEFINITIONS.dailySummary;
    const first = getDispatchId(
      definition,
      new Date("2026-10-25T06:00:00.000Z"),
      "Europe/Zagreb",
    );
    const retry = getDispatchId(
      definition,
      new Date("2026-10-25T07:00:00.000Z"),
      "Europe/Zagreb",
    );

    expect(first).toBe("dailySummary_2026-10-25_07-00");
    expect(retry).toBe("dailySummary_2026-10-25_08-00");
    expect(retry).not.toBe(first);
  });

  /** Verifies summary time changes can create another summary on the same local date */
  it("creates separate daily summary keys for different same-day times", () => {
    const definition = NOTIFICATION_DEFINITIONS.dailySummary;
    const morning = getDispatchId(
      definition,
      new Date("2026-06-01T06:00:00.000Z"),
      "Europe/Zagreb",
    );
    const later = getDispatchId(
      definition,
      new Date("2026-06-01T06:30:00.000Z"),
      "Europe/Zagreb",
    );

    expect(morning).toBe("dailySummary_2026-06-01_08-00");
    expect(later).toBe("dailySummary_2026-06-01_08-30");
    expect(later).not.toBe(morning);
  });

  /** Verifies changing the reminder time allows another delivery on the same local day */
  it("creates separate weight reminder keys for different same-day times", () => {
    const definition = NOTIFICATION_DEFINITIONS.weightReminder;
    const morning = getDispatchId(
      definition,
      new Date("2026-06-01T06:00:00.000Z"),
      "Europe/Zagreb",
    );
    const later = getDispatchId(
      definition,
      new Date("2026-06-01T09:00:00.000Z"),
      "Europe/Zagreb",
    );

    expect(morning).toBe("weightReminder_2026-06-01_08-00");
    expect(later).toBe("weightReminder_2026-06-01_11-00");
    expect(later).not.toBe(morning);
  });

  /** Verifies a retry of the same weight reminder keeps its duplicate-prevention key */
  it("keeps the same weight reminder key for the same occurrence", () => {
    const definition = NOTIFICATION_DEFINITIONS.weightReminder;
    const occurrence = new Date("2026-06-01T09:00:00.000Z");
    const retry = new Date(occurrence.getTime());

    expect(getDispatchId(definition, occurrence, "Europe/Zagreb")).toBe(
      getDispatchId(definition, retry, "Europe/Zagreb"),
    );
  });

  /** Verifies enabling a preference initializes its server-managed timestamp */
  it("initializes a newly enabled schedule", () => {
    // 09:00 in summer Zagreb is 07:00 UTC
    const patch = buildSchedulePatch(
      {
        weighReminderEnabled: false,
        timezone: "Europe/Zagreb",
      },
      {
        weighReminderEnabled: true,
        dailySummaryEnabled: false,
        timezone: "Europe/Zagreb",
      },
      new Date("2026-06-01T04:00:00.000Z"),
    );

    expect(patch.nextWeighReminderAt?.toISOString()).toBe("2026-06-01T07:00:00.000Z");
  });

  /** Verifies the timestamp date is not treated as the notification delivery day */
  it("extracts the user's custom wall-clock reminder time", () => {
    const definition = getNotificationDefinitionForSettings(
      NOTIFICATION_DEFINITIONS.weightReminder,
      {
        // 18:35 in summer Zagreb is 16:35 UTC
        weighReminderTime: Timestamp.fromDate(new Date("2035-04-18T16:35:00.000Z")),
        timezone: "Europe/Zagreb",
      },
    );

    expect(definition.hour).toBe(18);
    expect(definition.minute).toBe(35);
  });

  /** Verifies equal timestamp values do not continuously reschedule */
  it("preserves the schedule when the weigh reminder timestamp is unchanged", () => {
    const patch = buildSchedulePatch(
      {
        weighReminderEnabled: true,
        weighReminderTime: Timestamp.fromDate(new Date("2035-04-18T16:35:00.000Z")),
        timezone: "Europe/Zagreb",
        nextWeighReminderAt: Timestamp.fromDate(new Date("2026-06-02T16:35:00.000Z")),
      },
      {
        weighReminderEnabled: true,
        weighReminderTime: Timestamp.fromDate(new Date("2035-04-18T16:35:00.000Z")),
        dailySummaryEnabled: false,
        timezone: "Europe/Zagreb",
        nextWeighReminderAt: Timestamp.fromDate(new Date("2026-06-02T16:35:00.000Z")),
      },
      new Date("2026-06-01T12:00:00.000Z"),
    );

    expect(patch).toEqual({});
  });

  /** Verifies changing the custom time recalculates an enabled schedule */
  it("reschedules an enabled weigh reminder after its time changes", () => {
    const patch = buildSchedulePatch(
      {
        weighReminderEnabled: true,
        // 09:00 in winter Zagreb is 08:00 UTC
        weighReminderTime: Timestamp.fromDate(new Date("2020-01-01T08:00:00.000Z")),
        timezone: "Europe/Zagreb",
        nextWeighReminderAt: Timestamp.fromDate(new Date("2026-06-02T07:00:00.000Z")),
      },
      {
        weighReminderEnabled: true,
        weighReminderTime: Timestamp.fromDate(new Date("2035-04-18T16:35:00.000Z")),
        dailySummaryEnabled: false,
        timezone: "Europe/Zagreb",
        nextWeighReminderAt: Timestamp.fromDate(new Date("2026-06-02T07:00:00.000Z")),
      },
      new Date("2026-06-01T12:00:00.000Z"),
    );

    expect(patch.nextWeighReminderAt?.toISOString()).toBe("2026-06-01T16:35:00.000Z");
  });

  /** Verifies changing the custom summary time recalculates its enabled schedule */
  it("reschedules the summary when its local time changes", () => {
    const patch = buildSchedulePatch(
      {
        dailySummaryEnabled: true,
        dailySummaryTime: Timestamp.fromDate(new Date("2020-01-01T08:00:00.000Z")),
        timezone: "Europe/Zagreb",
        nextDailySummaryAt: Timestamp.fromDate(new Date("2026-06-02T07:00:00.000Z")),
      },
      {
        weighReminderEnabled: false,
        dailySummaryEnabled: true,
        dailySummaryTime: Timestamp.fromDate(new Date("2020-01-01T08:30:00.000Z")),
        timezone: "Europe/Zagreb",
        nextDailySummaryAt: Timestamp.fromDate(new Date("2026-06-02T07:00:00.000Z")),
      },
      new Date("2026-06-01T06:00:00.000Z"),
    );

    expect(patch.nextDailySummaryAt?.toISOString()).toBe("2026-06-01T07:30:00.000Z");
  });
});

// The regular unit command leaves these null and skips the integration suite
const emulatorAvailable = process.env.FIRESTORE_EMULATOR_HOST !== undefined;

// A unique project ID isolates this suite from other emulator clients
const emulatorApp = emulatorAvailable ? initializeApp({
  projectId: `bs-${randomUUID().slice(0, 20)}`,
}, "notification-dispatcher-emulator") : null;

/** Covers transaction-level duplicate prevention against Firestore */
describe.skipIf(!emulatorAvailable)("notification reservation emulator", () => {
  /** Removes the isolated Admin app after emulator coverage */
  afterAll(async () => {
    if (emulatorApp !== null) {
      await deleteApp(emulatorApp);
    }
  });

  /** Verifies overlapping transactions reserve one delivery for a due occurrence */
  it("prevents duplicate reservations when executions overlap", async () => {
    // Type narrowing also keeps the skipped non-emulator path safe
    if (emulatorApp === null) {
      return;
    }

    const firestore = getFirestore(emulatorApp);
    const settingsReference = firestore
      .collection("users")
      .doc(randomUUID())
      .collection("notificationSettings")
      .doc("preferences");
    const now = new Date("2026-06-01T07:05:00.000Z");
    const definition = NOTIFICATION_DEFINITIONS.weightReminder;

    // Seed one settings document whose reminder is already due
    await settingsReference.set({
      weighReminderEnabled: true,
      dailySummaryEnabled: false,
      announcementsEnabled: false,
      timezone: "Europe/Zagreb",
      locale: "en",
      nextWeighReminderAt: Timestamp.fromDate(new Date("2026-06-01T07:00:00.000Z")),
    });

    // Start both reservations before either promise is awaited
    const reservations = await Promise.all([
      reserveDueNotification(firestore, settingsReference, definition, now),
      reserveDueNotification(firestore, settingsReference, definition, now),
    ]);

    // Counts successful reservations from both overlapping executions
    expect(reservations.filter((reservation) => reservation !== null)).toHaveLength(1);
  });

  /** Verifies a changed time can reserve another weight reminder on the same day */
  it("reserves a later same-day weight reminder", async () => {
    if (emulatorApp === null) {
      return;
    }

    const firestore = getFirestore(emulatorApp);
    const userReference = firestore.collection("users").doc(randomUUID());
    const settingsReference = userReference.collection("notificationSettings").doc("preferences");
    const scheduledAt = new Date("2026-06-01T09:00:00.000Z");
    const now = new Date("2026-06-01T09:05:00.000Z");

    // The earlier 08:00 occurrence already completed before the user selected 11:00
    await userReference.collection("notificationDispatches").doc(
      "weightReminder_2026-06-01_08-00",
    ).set({
      status: "sent",
    });
    await settingsReference.set({
      weighReminderEnabled: true,
      dailySummaryEnabled: false,
      announcementsEnabled: false,
      timezone: "Europe/Zagreb",
      locale: "en",
      weighReminderTime: Timestamp.fromDate(new Date("2020-01-01T10:00:00.000Z")),
      nextWeighReminderAt: Timestamp.fromDate(scheduledAt),
    });

    const reservation = await reserveDueNotification(
      firestore,
      settingsReference,
      NOTIFICATION_DEFINITIONS.weightReminder,
      now,
    );

    expect(reservation?.idempotencyKey).toBe("weightReminder_2026-06-01_11-00");
    expect(reservation?.scheduledAt).toEqual(scheduledAt);
  });

  /** Verifies a same-local-day weight entry suppresses the reserved reminder */
  it("skips a weigh reminder when weight was already recorded", async () => {
    if (emulatorApp === null) {
      return;
    }

    const firestore = getFirestore(emulatorApp);
    const userReference = firestore.collection("users").doc(randomUUID());
    const settingsReference = userReference.collection("notificationSettings").doc("preferences");
    const scheduledAt = new Date("2026-06-01T07:00:00.000Z");
    const now = new Date("2026-06-01T07:05:00.000Z");

    await settingsReference.set({
      weighReminderEnabled: true,
      dailySummaryEnabled: false,
      announcementsEnabled: false,
      timezone: "Europe/Zagreb",
      locale: "en",
      nextWeighReminderAt: Timestamp.fromDate(scheduledAt),
    });
    await userReference.collection("weightTracks").doc(randomUUID()).set({
      dateTime: Timestamp.fromDate(new Date("2026-06-01T04:30:00.000Z")),
      weight: 75,
    });

    const reservation = await reserveDueNotification(
      firestore,
      settingsReference,
      NOTIFICATION_DEFINITIONS.weightReminder,
      now,
    );

    expect(reservation?.skipReason).toBe("weight_recorded");

    const dispatch = await userReference
      .collection("notificationDispatches")
      .doc("weightReminder_2026-06-01_09-00")
      .get();

    expect(dispatch.data()?.status).toBe("skipped_weight_recorded");
    expect(dispatch.data()?.type).toBeUndefined();
    expect(dispatch.data()?.idempotencyKey).toBeUndefined();
    expect(dispatch.data()?.dayBeingSummarized).toBeUndefined();
    expect(dispatch.data()?.reservedAt).toBeUndefined();
  });
});
