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
  DAILY_SUMMARY_MAX_FOODS_PER_MEAL,
  DAILY_SUMMARY_MAX_NAME_LENGTH,
  DAILY_SUMMARY_MAX_UNIT_LENGTH,
  DailySummaryFood,
  DailySummaryLabel,
  DailySummaryMeal,
  DailySummaryNutrition,
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
  methodOfCreation: string;
}

/** Keeps only completed meals without persisted processing errors */
export function isCompletedDailySummaryMeal(data: DocumentData): boolean {
  const errors = data.errors;
  const localizedName = data.name;
  const hasMealName = (
    typeof data.name === "string" &&
    data.name.trim().length > 0
  ) || (
    typeof localizedName === "object" &&
    localizedName !== null &&
    typeof localizedName.en === "string" &&
    localizedName.en.trim().length > 0 &&
    typeof localizedName.hr === "string" &&
    localizedName.hr.trim().length > 0
  );
  const hasNoErrors = errors === null ||
    errors === undefined ||
    (Array.isArray(errors) && errors.length === 0);

  return data.isLoading !== true &&
    hasNoErrors &&
    hasMealName;
}

/** Normalizes whitespace and bounds a single label without splitting a surrogate pair */
export function normalizeDailySummaryLabel(value: unknown, maximumLength: number): string | undefined {
  if (typeof value !== "string") {
    return undefined;
  }

  return value.replace(/[\s\p{Cc}\p{Cf}]+/gu, " ")
    .trim()
    .slice(0, maximumLength)
    .replace(/[\uD800-\uDFFF]/gu, "")
    .trimEnd() || undefined;
}

/** Keeps a plain label or just the two supported locale keys */
export function readDailySummaryLabel(value: unknown, maximumLength: number): DailySummaryLabel | undefined {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return normalizeDailySummaryLabel(value, maximumLength);
  }

  const localized = value as Record<string, unknown>;
  const en = normalizeDailySummaryLabel(localized.en, maximumLength);
  const hr = normalizeDailySummaryLabel(localized.hr, maximumLength);
  return en === undefined && hr === undefined ? undefined : {en, hr};
}

/** Recognizes valid portion and nutrition values without coercing strings */
export function isDailySummaryNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value) && value >= 0;
}

/** Keeps the four meal nutrition values when the complete set is valid */
export function readDailySummaryNutrition(value: unknown): DailySummaryNutrition | undefined {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return undefined;
  }

  const {calories, protein, carbs, fat} = value as Record<string, unknown>;
  if (
    !isDailySummaryNumber(calories) ||
    !isDailySummaryNumber(protein) ||
    !isDailySummaryNumber(carbs) ||
    !isDailySummaryNumber(fat)
  ) {
    return undefined;
  }

  return {calories, protein, carbs, fat};
}

/** Keeps a named food and its valid portion fields */
export function readDailySummaryFood(value: unknown): DailySummaryFood | undefined {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return undefined;
  }

  const food = value as Record<string, unknown>;
  const name = readDailySummaryLabel(food.name, DAILY_SUMMARY_MAX_NAME_LENGTH);
  if (name === undefined) {
    return undefined;
  }

  return {
    name,
    quantity: isDailySummaryNumber(food.quantity) ? food.quantity : undefined,
    unit: readDailySummaryLabel(food.unit, DAILY_SUMMARY_MAX_UNIT_LENGTH),
  };
}

/** Projects a completed Firestore meal onto the summary allowlist */
export function readDailySummaryMeal(data: DocumentData): DailySummaryMeal | undefined {
  if (!isCompletedDailySummaryMeal(data)) {
    return undefined;
  }

  const name = readDailySummaryLabel(data.name, DAILY_SUMMARY_MAX_NAME_LENGTH);
  if (name === undefined) {
    return undefined;
  }

  const foods: DailySummaryFood[] = [];
  if (Array.isArray(data.foods)) {
    for (const value of data.foods) {
      const food = readDailySummaryFood(value);
      if (food !== undefined) {
        foods.push(food);
      }
      if (foods.length === DAILY_SUMMARY_MAX_FOODS_PER_MEAL) {
        break;
      }
    }
  }

  return {name, foods, nutrition: readDailySummaryNutrition(data.nutrition)};
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
    .select("name", "foods", "nutrition", "isLoading", "errors")
    .get();
  const meals = mealSnapshot.docs.flatMap((document) => {
    const meal = readDailySummaryMeal(document.data());
    return meal === undefined ? [] : [meal];
  });
  const generatedSummary = await generateDailySummaryBodies(meals);
  const notification = buildDailySummaryNotification(
    generatedSummary.bodies,
  );
  const summary: DailySummary = {
    dayBeingSummarized: start,
    summaryAt: Timestamp.fromDate(period.summaryAt),
    timezone: period.timezone,
    notification,
    methodOfCreation: generatedSummary.modelName,
  };

  await userReference.collection("dailySummaries").doc(period.summaryKey).set(summary);

  return notification;
}
