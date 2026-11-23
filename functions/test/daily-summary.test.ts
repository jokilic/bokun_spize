import {describe, expect, it} from "vitest";
import {Timestamp} from "firebase-admin/firestore";

import {
  buildDailySummaryNotification,
  getDailySummaryPeriod,
  isCompletedDailySummaryMeal,
} from "../src/daily-summary";
import {
  DAILY_SUMMARY_BODY_MAX_LENGTH,
  buildDailySummaryPrompt,
  parseDailySummaryResponse,
} from "../src/daily-summary-ai";

describe("daily meal summary", () => {
  it("targets the previous local day just after midnight", () => {
    const period = getDailySummaryPeriod(
      new Date("2026-11-16T23:05:00.000Z"),
      "Europe/Zagreb",
    );

    expect(period.start.toISOString()).toBe("2026-11-15T23:00:00.000Z");
    expect(period.end.toISOString()).toBe("2026-11-16T23:00:00.000Z");
    expect(period.summaryAt.toISOString()).toBe("2026-11-16T23:05:00.000Z");
    expect(period.summaryKey).toBe("2026-11-17_00-05");
  });

  it("passes complete meal data to the AI prompt", () => {
    const prompt = buildDailySummaryPrompt([{
      documentId: "meal-1",
      data: {
        name: "Fruit and yogurt",
        foods: [{name: "Apple", quantity: 1, unit: "piece"}],
        createdAt: Timestamp.fromDate(new Date("2026-11-16T08:00:00.000Z")),
      },
    }]);

    expect(prompt).toContain('"documentId":"meal-1"');
    expect(prompt).toContain('"foods":[{"name":"Apple","quantity":1,"unit":"piece"}]');
    expect(prompt).toContain('"createdAt":"2026-11-16T08:00:00.000Z"');
  });

  it("includes completed localized AI meals", () => {
    expect(isCompletedDailySummaryMeal({
      isLoading: false,
      errors: null,
      name: {
        en: "Chicken salad",
        hr: "Pileća salata",
      },
    })).toBe(true);
  });

  it("stores generated localized bodies without redundant titles", () => {
    const bodies = parseDailySummaryResponse(JSON.stringify({
      en: "You included fruit today. Add an egg next time for more protein.",
      hr: "Danas si uključio voće. Sljedeći put dodaj jaje za više proteina.",
    }));
    const notification = buildDailySummaryNotification(bodies);

    expect(notification).toEqual({
      en: "You included fruit today. Add an egg next time for more protein.",
      hr: "Danas si uključio voće. Sljedeći put dodaj jaje za više proteina.",
    });
  });

  it("shortens overlong localized bodies without rejecting valid JSON", () => {
    const bodies = parseDailySummaryResponse(JSON.stringify({
      en: `Your meals included ${"fruit and vegetables ".repeat(30)}`,
      hr: `Tvoji obroci uključivali su ${"voće i povrće ".repeat(30)}`,
    }));

    expect(bodies.en.length).toBeLessThanOrEqual(DAILY_SUMMARY_BODY_MAX_LENGTH);
    expect(bodies.hr.length).toBeLessThanOrEqual(DAILY_SUMMARY_BODY_MAX_LENGTH);
    expect(bodies.en.endsWith("…")).toBe(true);
    expect(bodies.hr.endsWith("…")).toBe(true);
  });
});
