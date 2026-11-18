/**
 * Builds and stores the previous-day summary from Firestore data
 */

import {
  DocumentData,
  DocumentReference,
  Timestamp,
} from "firebase-admin/firestore";
import {DateTime} from "luxon";

import {
  DailySummaryMeal,
  GeneratedDailySummaryBodies,
  generateDailySummaryBodies,
} from "./daily-summary-ai";
import {SupportedLocale} from "./notification-config";
import {getValidTimezone} from "./scheduling";

/** Calendar-day interval used by the summary query */
export interface DailySummaryPeriod {
  timezone: string;
  start: Date;
  end: Date;
  summaryAt: Date;
  summaryKey: string;
}

/** Localized notification bodies written for one summary occurrence */
export type DailySummaryNotification = Record<SupportedLocale, string>;

/** Generated summary data written for one summary occurrence */
export interface DailySummary {
  dayBeingSummarized: Timestamp;
  summaryAt: Timestamp;
  timezone: string;
  notification: DailySummaryNotification;
}

/** Keeps only completed meals without persisted processing errors */
export function isCompletedDailySummaryMeal(data: DocumentData): boolean {
  const errors = data.errors;
  const hasNoErrors = errors === null ||
    errors === undefined ||
    (Array.isArray(errors) && errors.length === 0);

  return data.isLoading !== true &&
    hasNoErrors &&
    typeof data.name === "string" &&
    data.name.trim().length > 0;
}

/** Resolves yesterday's exact local-day bounds for a summary occurrence */
export function getDailySummaryPeriod(
  scheduledAt: Date,
  timezone: string,
): DailySummaryPeriod {
  const zone = getValidTimezone(timezone);
  const summaryOccurrence = DateTime.fromJSDate(scheduledAt, {zone: "utc"})
    .setZone(zone);
  const mealDay = summaryOccurrence.startOf("day").minus({days: 1});

  return {
    timezone: zone,
    start: mealDay.toUTC().toJSDate(),
    end: mealDay.plus({days: 1}).toUTC().toJSDate(),
    summaryAt: summaryOccurrence.toUTC().toJSDate(),
    summaryKey: summaryOccurrence.toFormat("yyyy-LL-dd_HH-mm"),
  };
}

/** Keeps generated bodies in the persisted locale structure without redundant titles */
export function buildDailySummaryNotification(
  bodies: GeneratedDailySummaryBodies,
): DailySummaryNotification {
  return {
    en: bodies.en,
    hr: bodies.hr,
  };
}

/** Loads Firestore data, stores the summary and returns its notification bodies */
export async function buildAndStoreDailySummary(
  userReference: DocumentReference<DocumentData>,
  period: DailySummaryPeriod,
): Promise<DailySummaryNotification> {
  const start = Timestamp.fromDate(period.start);
  const end = Timestamp.fromDate(period.end);
  const mealSnapshot = await userReference
    .collection("meals")
    .where("createdAt", ">=", start)
    .where("createdAt", "<", end)
    .orderBy("createdAt", "asc")
    .get();
  const mealDocuments: DailySummaryMeal[] = mealSnapshot.docs
    .filter((document) => isCompletedDailySummaryMeal(document.data()))
    .map((document) => ({
      documentId: document.id,
      data: document.data(),
    }));
  const notification = buildDailySummaryNotification(
    await generateDailySummaryBodies(
      userReference.firestore,
      mealDocuments,
    ),
  );
  const summary: DailySummary = {
    dayBeingSummarized: start,
    summaryAt: Timestamp.fromDate(period.summaryAt),
    timezone: period.timezone,
    notification,
  };

  await userReference.collection("dailySummaries").doc(period.summaryKey).set(summary);

  return notification;
}
