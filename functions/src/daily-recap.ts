/**
 * Builds and stores the previous-day recap from Firestore data
 */

import {
  DocumentData,
  DocumentReference,
  Timestamp,
} from "firebase-admin/firestore";
import {DateTime} from "luxon";

import {
  DailyRecapMeal,
  GeneratedDailyRecapBodies,
  generateDailyRecapBodies,
} from "./daily-recap-ai";
import {SupportedLocale} from "./notification-config";
import {getValidTimezone} from "./scheduling";

/** Calendar-day interval used by the recap query */
export interface DailyRecapPeriod {
  timezone: string;
  start: Date;
  end: Date;
  recapAt: Date;
  recapKey: string;
}

/** Localized notification bodies written for one recap occurrence */
export type DailyRecapNotification = Record<SupportedLocale, {body: string}>;

/** Generated recap data written for one recap occurrence */
export interface DailyRecap {
  dayBeingSummarized: Timestamp;
  recapAt: Timestamp;
  timezone: string;
  notification: DailyRecapNotification;
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

/** Keeps generated bodies in the persisted locale structure without redundant titles */
export function buildDailyRecapNotification(
  bodies: GeneratedDailyRecapBodies,
): DailyRecapNotification {
  return {
    en: {body: bodies.en},
    hr: {body: bodies.hr},
  };
}

/** Loads Firestore data, stores the recap and returns its notification bodies */
export async function buildAndStoreDailyRecap(
  userReference: DocumentReference<DocumentData>,
  period: DailyRecapPeriod,
): Promise<DailyRecapNotification> {
  const start = Timestamp.fromDate(period.start);
  const end = Timestamp.fromDate(period.end);
  const mealSnapshot = await userReference
    .collection("meals")
    .where("createdAt", ">=", start)
    .where("createdAt", "<", end)
    .orderBy("createdAt", "asc")
    .get();
  const mealDocuments: DailyRecapMeal[] = mealSnapshot.docs.map((document) => ({
    documentId: document.id,
    data: document.data(),
  }));
  const notification = buildDailyRecapNotification(
    await generateDailyRecapBodies(
      userReference.firestore,
      mealDocuments,
    ),
  );
  const recap: DailyRecap = {
    dayBeingSummarized: start,
    recapAt: Timestamp.fromDate(period.recapAt),
    timezone: period.timezone,
    notification,
  };

  await userReference.collection("dailyRecaps").doc(period.recapKey).set(recap);

  return notification;
}
