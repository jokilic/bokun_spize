/**
 * Builds and stores a deterministic previous-day recap from Firestore data
 */

import {
  DocumentData,
  DocumentReference,
  Timestamp,
} from "firebase-admin/firestore";
import {DateTime} from "luxon";

import {
  DAILY_SUMMARY_PREPARE_MINUTES,
  NotificationCopy,
  NotificationType,
  SupportedLocale,
} from "./notification-config";
import {getValidTimezone} from "./scheduling";

/** Calendar-day interval shared by the prepare payload and recap queries */
export interface DailyRecapPeriod {
  dayBeingSummarized: string;
  timezone: string;
  start: Date;
  end: Date;
  recapAt: Date;
  recapKey: string;
}

/** Aggregated meal values stored in one recap */
export interface DailyMealSummary {
  count: number;
  nutritionCount: number;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

/** Optional latest weight recorded during the recap day */
export interface DailyWeightSummary {
  status: "available" | "not_recorded";
  value?: number;
  recordedAt?: Timestamp;
}

/** Step status preserves the difference between unavailable and a real zero */
export interface DailyStepSummary {
  status: string;
  value?: number;
  source?: string;
}

/** Complete summary data written for one recap occurrence */
export interface DailyRecap {
  dayBeingSummarized: Timestamp;
  recapAt: Timestamp;
  timezone: string;
  status: "ready" | "ready_without_steps";
  meals: DailyMealSummary;
  weight: DailyWeightSummary;
  steps: DailyStepSummary;
}

/** Resolves yesterday's exact local-day bounds for a recap occurrence */
export function getDailyRecapPeriod(
  scheduledAt: Date,
  timezone: string,
  type: NotificationType,
): DailyRecapPeriod {
  const zone = getValidTimezone(timezone);
  const recapOccurrence = DateTime.fromJSDate(scheduledAt, {zone: "utc"})
    .setZone(zone)
    .plus({
      minutes: type === "dailySummaryPrepare"
        ? DAILY_SUMMARY_PREPARE_MINUTES
        : 0,
    });
  const activityDay = recapOccurrence.startOf("day").minus({days: 1});

  return {
    dayBeingSummarized: activityDay.toFormat("yyyy-LL-dd"),
    timezone: zone,
    start: activityDay.toUTC().toJSDate(),
    end: activityDay.plus({days: 1}).toUTC().toJSDate(),
    recapAt: recapOccurrence.toUTC().toJSDate(),
    recapKey: recapOccurrence.toFormat("yyyy-LL-dd_HH-mm"),
  };
}

/** Resolves exact UTC bounds from a validated local date and timezone */
export function getDailyRecapPeriodForSummarizedDay(
  dayBeingSummarized: string,
  timezone: string,
  recapAt: Date,
): DailyRecapPeriod {
  const zone = getValidTimezone(timezone);
  const activityDay = DateTime.fromISO(dayBeingSummarized, {zone}).startOf("day");
  const recapOccurrence = DateTime.fromJSDate(recapAt, {zone: "utc"}).setZone(zone);

  if (
    !activityDay.isValid ||
    activityDay.toFormat("yyyy-LL-dd") !== dayBeingSummarized ||
    !recapOccurrence.isValid
  ) {
    throw new Error(`Invalid summarized day: ${dayBeingSummarized}`);
  }

  return {
    dayBeingSummarized,
    timezone: zone,
    start: activityDay.toUTC().toJSDate(),
    end: activityDay.plus({days: 1}).toUTC().toJSDate(),
    recapAt: recapOccurrence.toUTC().toJSDate(),
    recapKey: recapOccurrence.toFormat("yyyy-LL-dd_HH-mm"),
  };
}

/** Reads a finite number from an unknown Firestore value */
export function getFiniteNumber(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

/** Aggregates completed meals and their available nutrition values */
export function summarizeMeals(documents: DocumentData[]): DailyMealSummary {
  const summary: DailyMealSummary = {
    count: 0,
    nutritionCount: 0,
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
  };

  for (const meal of documents) {
    if (meal.isLoading === true) {
      continue;
    }

    summary.count += 1;
    const nutrition = meal.nutrition;

    if (typeof nutrition !== "object" || nutrition === null) {
      continue;
    }

    const calories = getFiniteNumber(nutrition.calories);
    const protein = getFiniteNumber(nutrition.protein);
    const carbs = getFiniteNumber(nutrition.carbs);
    const fat = getFiniteNumber(nutrition.fat);

    if (calories === null || protein === null || carbs === null || fat === null) {
      continue;
    }

    summary.nutritionCount += 1;
    summary.calories += calories;
    summary.protein += protein;
    summary.carbs += carbs;
    summary.fat += fat;
  }

  return summary;
}

/** Converts the latest valid weight document into recap data */
export function summarizeWeight(document: DocumentData | undefined): DailyWeightSummary {
  const value = getFiniteNumber(document?.weight);
  const recordedAt = document?.dateTime;

  if (value === null || !(recordedAt instanceof Timestamp)) {
    return {status: "not_recorded"};
  }

  return {
    status: "available",
    value,
    recordedAt,
  };
}

/** Converts the client aggregate without interpreting missing data as zero */
export function summarizeSteps(document: DocumentData | undefined): DailyStepSummary {
  if (document === undefined) {
    return {status: "not_synced"};
  }

  const status = typeof document.status === "string" ? document.status : "unavailable";
  const value = getFiniteNumber(document.steps);

  if (status !== "available" || value === null || value < 0) {
    return {status};
  }

  return {
    status: "available",
    value: Math.round(value),
    ...(typeof document.source === "string" ? {source: document.source} : {}),
  };
}

/** Formats a number using the notification locale */
export function formatRecapNumber(
  value: number,
  locale: SupportedLocale,
  maximumFractionDigits = 0,
): string {
  return new Intl.NumberFormat(
    locale === "hr" ? "hr-HR" : "en-US",
    {maximumFractionDigits},
  ).format(value);
}

/** Builds one localized notification body from recap values */
export function buildDailyRecapBody(
  locale: SupportedLocale,
  meals: DailyMealSummary,
  weight: DailyWeightSummary,
  steps: DailyStepSummary,
): string {
  const mealLabel = locale === "hr" ? "Obroci" : "Meals";
  const weightLabel = locale === "hr" ? "Težina" : "Weight";
  const stepsLabel = locale === "hr" ? "Koraci" : "Steps";
  const unavailable = locale === "hr" ? "nedostupno" : "unavailable";
  const notRecorded = locale === "hr" ? "nije zabilježena" : "not recorded";
  const parts = [`${mealLabel}: ${formatRecapNumber(meals.count, locale)}`];

  if (meals.nutritionCount > 0) {
    parts.push(`${formatRecapNumber(meals.calories, locale)} kcal`);
  }

  parts.push(
    weight.status === "available" && weight.value !== undefined
      ? `${weightLabel}: ${formatRecapNumber(weight.value, locale, 1)} kg`
      : `${weightLabel}: ${notRecorded}`,
  );
  parts.push(
    steps.status === "available" && steps.value !== undefined
      ? `${stepsLabel}: ${formatRecapNumber(steps.value, locale)}`
      : `${stepsLabel}: ${unavailable}`,
  );

  return parts.join(" · ");
}

/** Builds concise localized notification copy from recap values */
export function buildDailyRecapCopy(
  meals: DailyMealSummary,
  weight: DailyWeightSummary,
  steps: DailyStepSummary,
): Record<SupportedLocale, NotificationCopy> {
  return {
    en: {
      title: "Overview of yesterday",
      body: buildDailyRecapBody("en", meals, weight, steps),
    },
    hr: {
      title: "Pregled prošlog dana",
      body: buildDailyRecapBody("hr", meals, weight, steps),
    },
  };
}

/** Loads Firestore data, stores the recap and returns its notification copy */
export async function buildAndStoreDailyRecap(
  userReference: DocumentReference<DocumentData>,
  period: DailyRecapPeriod,
): Promise<Record<SupportedLocale, NotificationCopy>> {
  const start = Timestamp.fromDate(period.start);
  const end = Timestamp.fromDate(period.end);
  const [mealSnapshot, weightSnapshot, activitySnapshot] = await Promise.all([
    userReference
      .collection("meals")
      .where("createdAt", ">=", start)
      .where("createdAt", "<", end)
      .get(),
    userReference
      .collection("weightTracks")
      .where("dateTime", ">=", start)
      .where("dateTime", "<", end)
      .orderBy("dateTime", "desc")
      .limit(1)
      .get(),
    userReference.collection("dailyActivity").doc(period.recapKey).get(),
  ]);
  const meals = summarizeMeals(mealSnapshot.docs.map((document) => document.data()));
  const weight = summarizeWeight(weightSnapshot.docs[0]?.data());
  const steps = summarizeSteps(activitySnapshot.data());
  const copy = buildDailyRecapCopy(meals, weight, steps);
  const recap: DailyRecap = {
    dayBeingSummarized: start,
    recapAt: Timestamp.fromDate(period.recapAt),
    timezone: period.timezone,
    status: steps.status === "available" ? "ready" : "ready_without_steps",
    meals,
    weight,
    steps,
  };

  await userReference.collection("dailyRecaps").doc(period.recapKey).set(recap);

  return copy;
}
