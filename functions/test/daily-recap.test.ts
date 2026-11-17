import {describe, expect, it} from "vitest";

import {
  buildDailyRecapCopy,
  getDailyRecapPeriod,
  summarizeSteps,
} from "../src/daily-recap";

/** Covers local-day boundaries and unavailable-versus-zero recap semantics */
describe("daily recap", () => {
  /** Keeps a real zero when the health aggregate completed successfully */
  it("distinguishes zero steps from unavailable steps", () => {
    expect(summarizeSteps({
      status: "available",
      steps: 0,
      source: "healthkit",
    })).toMatchObject({
      status: "available",
      value: 0,
    });
    expect(summarizeSteps(undefined)).toEqual({status: "not_synced"});
  });

  /** Uses the recap occurrence date when prepare crosses local midnight */
  it("targets the correct day for a prepare occurrence before midnight", () => {
    const period = getDailyRecapPeriod(
      new Date("2026-11-16T22:50:00.000Z"),
      "Europe/Zagreb",
      "dailySummaryPrepare",
    );

    expect(period.localDate).toBe("2026-11-16");
    expect(period.start.toISOString()).toBe("2026-11-15T23:00:00.000Z");
    expect(period.end.toISOString()).toBe("2026-11-16T23:00:00.000Z");
  });

  /** Writes explicit unavailable copy rather than displaying zero activity */
  it("builds localized fallback copy without steps", () => {
    const copy = buildDailyRecapCopy(
      {
        count: 2,
        nutritionCount: 2,
        calories: 1800,
        protein: 100,
        carbs: 200,
        fat: 60,
      },
      {status: "not_recorded"},
      {status: "not_synced"},
    );

    expect(copy.en.body).toContain("Steps: unavailable");
    expect(copy.hr.body).toContain("Koraci: nedostupno");
  });
});
