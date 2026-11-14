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
  getNotificationDefinitions,
  NOTIFICATION_DEFINITIONS,
} from "../src/notification-config";
import {getWeightReminderTimeParts} from "../src/remote-notification-config";
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

  /** Verifies one local day always produces the same duplicate-prevention key */
  it("creates a stable idempotency key for a local occurrence", () => {
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

    // Different UTC instants on the same Zagreb date represent one logical send
    expect(first).toBe("dailySummary_2026-10-25");
    expect(retry).toBe(first);
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

  /** Verifies a trusted global override can move the fixed time for testing */
  it("overrides the weigh reminder time without changing user preferences", () => {
    // Firebase stores 02:40 entered in Zagreb during standard time as 01:40 UTC
    const configuredTime = Timestamp.fromDate(new Date("2026-11-14T01:40:45.000Z"));
    const {hour, minute} = getWeightReminderTimeParts(configuredTime);
    const definitions = getNotificationDefinitions(hour, minute);

    expect(definitions.weightReminder.hour).toBe(2);
    expect(definitions.weightReminder.minute).toBe(40);
    expect(definitions.dailySummary.hour).toBe(8);
  });

  /** Verifies console input remains unchanged while Zagreb observes daylight saving time */
  it("reads a summer weigh reminder override as Zagreb wall-clock time", () => {
    // Firebase stores 02:40 entered in Zagreb during daylight time as 00:40 UTC
    const configuredTime = Timestamp.fromDate(new Date("2026-06-01T00:40:00.000Z"));

    expect(getWeightReminderTimeParts(configuredTime)).toEqual({
      hour: 2,
      minute: 40,
    });
  });

  /** Verifies a missing or invalid timestamp retains the production default */
  it("falls back to the default weigh reminder time", () => {
    expect(getWeightReminderTimeParts(null)).toEqual({hour: 9, minute: 0});
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

  /** Verifies a same-local-day weight entry suppresses the reserved reminder */
  it("skips a weigh reminder when weight was already recorded", async () => {
    if (emulatorApp === null) {
      return;
    }

    const firestore = getFirestore(emulatorApp);
    const userReference = firestore.collection("users").doc(randomUUID());
    const settingsReference = userReference.collection("notificationSettings").doc("preferences");
    const dueAt = new Date("2026-06-01T07:00:00.000Z");
    const now = new Date("2026-06-01T07:05:00.000Z");

    await settingsReference.set({
      weighReminderEnabled: true,
      dailySummaryEnabled: false,
      announcementsEnabled: false,
      timezone: "Europe/Zagreb",
      locale: "en",
      nextWeighReminderAt: Timestamp.fromDate(dueAt),
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
      .doc("weightReminder_2026-06-01")
      .get();

    expect(dispatch.data()?.status).toBe("skipped_weight_recorded");
    expect(dispatch.data()?.type).toBeUndefined();
    expect(dispatch.data()?.idempotencyKey).toBeUndefined();
    expect(dispatch.data()?.localDate).toBeUndefined();
    expect(dispatch.data()?.reservedAt).toBeUndefined();
  });
});
