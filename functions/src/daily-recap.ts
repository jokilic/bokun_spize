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
  NotificationCopy,
  SupportedLocale,
} from "./notification-config";
import {getValidTimezone} from "./scheduling";

/** Calendar-day interval used by the recap query */
export interface DailyRecapPeriod {
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

/** Complete summary data written for one recap occurrence */
export interface DailyRecap {
  dayBeingSummarized: Timestamp;
  recapAt: Timestamp;
  timezone: string;
  meals: DailyMealSummary;
}

/** Resolves yesterday's exact local-day bounds for a recap occurrence */
export function getDailyRecapPeriod(
  scheduledAt: Date,
  timezone: string,
): DailyRecapPeriod {
  const zone = getValidTimezone(timezone);
  const recapOccurrence = DateTime.fromJSDate(scheduledAt, {zone: "utc"})
    .setZone(zone);
  const mealDay = recapOccurrence.startOf("day").minus({days: 1});

  return {
    timezone: zone,
    start: mealDay.toUTC().toJSDate(),
    end: mealDay.plus({days: 1}).toUTC().toJSDate(),
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

/** Formats a number using the notification locale */
export function formatRecapNumber(
  value: number,
  locale: SupportedLocale,
): string {
  return new Intl.NumberFormat(
    locale === "hr" ? "hr-HR" : "en-US",
    {maximumFractionDigits: 0},
  ).format(value);
}

/** Builds one localized notification body from recap values */
export function buildDailyRecapBody(
  locale: SupportedLocale,
  meals: DailyMealSummary,
): string {
  const mealLabel = locale === "hr" ? "Obroci" : "Meals";
  const parts = [`${mealLabel}: ${formatRecapNumber(meals.count, locale)}`];

  if (meals.nutritionCount > 0) {
    parts.push(`${formatRecapNumber(meals.calories, locale)} kcal`);
  }

  return parts.join(" · ");
}

/** Builds concise localized notification copy from recap values */
export function buildDailyRecapCopy(
  meals: DailyMealSummary,
): Record<SupportedLocale, NotificationCopy> {
  return {
    en: {
      title: "Overview of yesterday",
      body: buildDailyRecapBody("en", meals),
    },
    hr: {
      title: "Pregled prošlog dana",
      body: buildDailyRecapBody("hr", meals),
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
  const mealSnapshot = await userReference
    .collection("meals")
    .where("createdAt", ">=", start)
    .where("createdAt", "<", end)
    .get();
  const meals = summarizeMeals(mealSnapshot.docs.map((document) => document.data()));
  const copy = buildDailyRecapCopy(meals);
  const recap: DailyRecap = {
    dayBeingSummarized: start,
    recapAt: Timestamp.fromDate(period.recapAt),
    timezone: period.timezone,
    meals,
  };

  await userReference.collection("dailyRecaps").doc(period.recapKey).set(recap);

  return copy;
}
