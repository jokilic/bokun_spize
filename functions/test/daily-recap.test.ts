import {describe, expect, it} from "vitest";
import {Timestamp} from "firebase-admin/firestore";

import {getDailyRecapPeriod} from "../src/daily-recap";
import {
  buildDailyRecapPrompt,
  buildGeneratedDailyRecapCopy,
  parseDailyRecapResponse,
} from "../src/daily-recap-ai";

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

  it("passes complete meal data to the AI prompt", () => {
    const prompt = buildDailyRecapPrompt([{
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

  it("uses generated localized bodies as notification copy", () => {
    const bodies = parseDailyRecapResponse(JSON.stringify({
      en: "You included fruit today. Add an egg next time for more protein.",
      hr: "Danas si uključio voće. Sljedeći put dodaj jaje za više proteina.",
    }));
    const copy = buildGeneratedDailyRecapCopy(bodies);

    expect(copy.en.body).toBe("You included fruit today. Add an egg next time for more protein.");
    expect(copy.hr.body).toBe("Danas si uključio voće. Sljedeći put dodaj jaje za više proteina.");
  });
});
