/** Enforces one shared Gemini call allowance per UTC day */

import {type Firestore, getFirestore, Timestamp, type Transaction} from "firebase-admin/firestore";

import {getAIIntegerSetting} from "./ai-config.ts";

/** Project-wide allowance covering meals, summaries, and their fallbacks */
export const DEFAULT_PROJECT_DAILY_AI_CALL_LIMIT = 1000;
export const PROJECT_AI_USAGE_PATH = "projectAIUsage/gemini";
export const UTC_DAY_MILLIS = 24 * 60 * 60 * 1000;

/** Carries the next reset time when no project-wide call slot is available */
export class ProjectAIQuotaExceeded extends Error {
  readonly retryAtMillis: number;

  constructor(retryAtMillis: number) {
    super("Project AI call allowance exhausted");
    this.retryAtMillis = retryAtMillis;
  }
}

/** Reads the deployed project allowance, using the default when unset */
export function getProjectDailyAICallLimit(): number {
  return getAIIntegerSetting("AI_PROJECT_DAILY_CALL_LIMIT", DEFAULT_PROJECT_DAILY_AI_CALL_LIMIT);
}

/** Reserves a call in the caller's transaction or returns the next reset time */
export async function reserveProjectAICallInTransaction(
  firestore: Firestore,
  transaction: Transaction,
  limit: number = getProjectDailyAICallLimit(),
): Promise<number | null> {
  if (!Number.isSafeInteger(limit) || limit < 1) {
    throw new Error("AI_PROJECT_DAILY_CALL_LIMIT must be a positive integer");
  }

  const reference = firestore.doc(PROJECT_AI_USAGE_PATH);
  const snapshot = await transaction.get(reference);
  const now = snapshot.readTime.toMillis();
  const utcMidnightMillis = now - now % UTC_DAY_MILLIS;
  const dayStart = Timestamp.fromMillis(utcMidnightMillis);
  const usage = snapshot.data();
  let calls = 0;

  if (usage !== undefined) {
    if (
      !(usage.dayStart instanceof Timestamp) ||
      usage.dayStart.toMillis() > utcMidnightMillis ||
      !Number.isSafeInteger(usage.calls) ||
      usage.calls < 0
    ) {
      throw new Error("Invalid project AI usage counter");
    }

    if (usage.dayStart.isEqual(dayStart)) {
      calls = usage.calls;
    }
  }

  if (calls >= limit) {
    return utcMidnightMillis + UTC_DAY_MILLIS;
  }

  transaction.set(reference, {
    dayStart,
    calls: calls + 1,
  });
  return null;
}

/** Reserves a standalone slot before a Gemini call outside a meal claim */
export async function reserveProjectAICall(
  firestore: Firestore = getFirestore(),
  limit: number = getProjectDailyAICallLimit(),
): Promise<void> {
  const retryAtMillis = await firestore.runTransaction((transaction) =>
    reserveProjectAICallInTransaction(firestore, transaction, limit),
  );

  if (retryAtMillis !== null) {
    throw new ProjectAIQuotaExceeded(retryAtMillis);
  }
}
