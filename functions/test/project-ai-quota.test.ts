import {randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import type {Messaging} from "firebase-admin/messaging";
import {describe, expect, it, vi} from "vitest";
import {processDueSettings} from "../src/dispatcher";
import {claimPendingAIMeal} from "../src/meal-ai";
import {NOTIFICATION_DEFINITIONS} from "../src/notification-config";
import {
  PROJECT_AI_USAGE_PATH,
  ProjectAIQuotaExceeded,
  reserveProjectAICall,
  UTC_DAY_MILLIS,
} from "../src/project-ai-quota";

/** Exercises the shared allowance and meal claim against real Firestore transactions */
describe.skipIf(process.env.FIRESTORE_EMULATOR_HOST === undefined)("project AI quota emulator", () => {
  /** A meal claim and standalone call compete for the same final slot */
  it("allows one reservation and preserves personal quota when the project is full", async () => {
    const app = initializeApp({projectId: `bs-${randomUUID().slice(0, 20)}`}, "project-ai-quota-race");
    const firestore = getFirestore(app);
    const user = firestore.collection("users").doc("test-user");
    const meal = user.collection("meals").doc("first-meal");
    const quota = user.collection("aiUsage").doc("mealGeneration");
    vi.stubEnv("AI_PROJECT_DAILY_CALL_LIMIT", "1");

    try {
      await meal.set({isLoading: true, methodOfCreation: "ai", originalText: "Soup"});
      const [claim, standalone] = await Promise.all([
        claimPendingAIMeal(meal, randomUUID(), "en", false),
        reserveProjectAICall(firestore).then(() => "reserved", (error: unknown) => error),
      ]);

      if (claim.status === "claimed") {
        expect(standalone).toBeInstanceOf(ProjectAIQuotaExceeded);
        expect((await quota.get()).data()?.attempts).toHaveLength(1);
      } else {
        expect(claim.status).toBe("project-rate-limited");
        expect(standalone).toBe("reserved");
        expect((await quota.get()).exists).toBe(false);
      }

      const nextUser = firestore.collection("users").doc("another-user");
      const nextMeal = nextUser.collection("meals").doc("rejected-meal");
      await nextMeal.set({isLoading: true, methodOfCreation: "ai", originalText: "Soup"});
      expect(await claimPendingAIMeal(nextMeal, randomUUID(), "en", false)).toMatchObject({
        status: "project-rate-limited",
      });
      expect((await nextMeal.get()).data()).toMatchObject({
        isLoading: false,
        errors: ["AI is temporarily unavailable. Try again later"],
      });
      expect((await nextUser.collection("aiUsage").doc("mealGeneration").get()).exists).toBe(false);
      expect((await firestore.doc(PROJECT_AI_USAGE_PATH).get()).data()?.calls).toBe(1);
    } finally {
      vi.unstubAllEnvs();
      await deleteApp(app);
    }
  });

  /** A previous day's usage leaves the current allowance available */
  it("resets the counter at the UTC day boundary and rejects the next call", async () => {
    const app = initializeApp({projectId: `bs-${randomUUID().slice(0, 20)}`}, "project-ai-quota-reset");
    const firestore = getFirestore(app);
    const counter = firestore.doc(PROJECT_AI_USAGE_PATH);

    try {
      const {readTime} = await counter.get();
      const now = readTime.toMillis();
      const dayStartMillis = now - now % UTC_DAY_MILLIS;
      await counter.set({dayStartMillis: dayStartMillis - UTC_DAY_MILLIS, calls: 1000});

      await reserveProjectAICall(firestore, 1);
      await expect(reserveProjectAICall(firestore, 1)).rejects.toMatchObject({
        retryAtMillis: dayStartMillis + UTC_DAY_MILLIS,
      });
      expect((await counter.get()).data()).toEqual({dayStartMillis, calls: 1});
    } finally {
      await deleteApp(app);
    }
  });

  /** Finishes an exhausted summary as skipped and advances its schedule */
  it("skips a due summary without generating or delivering it", async () => {
    const app = initializeApp({projectId: `bs-${randomUUID().slice(0, 20)}`});
    const firestore = getFirestore(app);
    const user = firestore.collection("users").doc("test-user");
    const settings = user.collection("notificationSettings");
    const now = new Date("2026-06-01T07:05:00.000Z");
    const sendEachForMulticast = vi.fn();
    vi.stubEnv("AI_PROJECT_DAILY_CALL_LIMIT", "1");

    try {
      await reserveProjectAICall(firestore);
      await settings.doc("preferences").set({
        dailySummaryEnabled: true,
        timezone: "UTC",
        locale: "en",
        dailySummaryTime: Timestamp.fromDate(new Date("2020-01-01T07:00:00.000Z")),
        nextDailySummaryAt: Timestamp.fromDate(new Date("2026-06-01T07:00:00.000Z")),
      });
      const [settingsDocument] = (await settings.get()).docs;
      await processDueSettings(
        firestore,
        {sendEachForMulticast} as unknown as Messaging,
        settingsDocument!,
        NOTIFICATION_DEFINITIONS.dailySummary,
        now,
      );

      const [dispatch] = (await user.collection("notificationDispatches").get()).docs;
      expect(dispatch?.data()).toMatchObject({status: "skipped_ai_quota_exhausted"});
      expect((await settings.doc("preferences").get()).data()?.nextDailySummaryAt.toDate()).toEqual(
        new Date("2026-06-02T07:00:00.000Z"),
      );
      expect((await user.collection("dailySummaries").get()).empty).toBe(true);
      expect(sendEachForMulticast).not.toHaveBeenCalled();
    } finally {
      vi.unstubAllEnvs();
      await deleteApp(app);
    }
  });
});
