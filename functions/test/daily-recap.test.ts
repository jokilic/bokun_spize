import {describe, expect, it} from "vitest";

import {
  buildDailyRecapCopy,
  getDailyRecapPeriod,
} from "../src/daily-recap";

describe("daily meal recap", () => {
  it("targets the previous local day just after midnight", () => {
    const period = getDailyRecapPeriod(
      new Date("2026-11-16T23:05:00.000Z"),
      "Europe/Zagreb",
    );

    expect(period.start.toISOString()).toBe("2026-11-15T23:00:00.000Z");
    expect(period.end.toISOString()).toBe("2026-11-16T23:00:00.000Z");
    expect(period.recapAt.toISOString()).toBe("2026-11-16T23:05:00.000Z");
    expect(period.recapKey).toBe("2026-11-17_00-05");
  });

  it("builds localized copy with the meal count and calories", () => {
    const copy = buildDailyRecapCopy(
      {
        count: 2,
        nutritionCount: 2,
        calories: 1800,
        protein: 100,
        carbs: 200,
        fat: 60,
      },
    );

    expect(copy.en.body).toBe("Meals: 2 · 1,800 kcal");
    expect(copy.hr.body).toBe("Obroci: 2 · 1.800 kcal");
  });
});
