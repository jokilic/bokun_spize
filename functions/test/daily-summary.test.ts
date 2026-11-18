import {describe, expect, it} from "vitest";
import {Timestamp} from "firebase-admin/firestore";

import {
  buildDailySummaryNotification,
  getDailySummaryPeriod,
} from "../src/daily-summary";
import {
  buildDailySummaryPrompt,
  DAILY_SUMMARY_RESPONSE_SCHEMA,
  DAILY_SUMMARY_SYSTEM_INSTRUCTION,
  parseDailySummaryModelNames,
  parseDailySummaryResponse,
  parseDailySummaryResponseSchema,
  parseDailySummarySystemInstruction,
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

  it("parses independently configurable daily summary AI fields", () => {
    const schema = {
      type: "object",
      properties: {
        en: {type: "string"},
        hr: {type: "string"},
      },
      required: ["en", "hr"],
    };

    expect(parseDailySummaryModelNames([" model-a ", "model-a", "model-b"])).toEqual([
      "model-a",
      "model-b",
    ]);
    expect(
      parseDailySummarySystemInstruction(" Custom instruction "),
    ).toBe("Custom instruction");
    expect(parseDailySummaryResponseSchema(JSON.stringify(schema))).toEqual(schema);
  });

  it("falls back when daily summary AI fields are invalid", () => {
    expect(parseDailySummaryModelNames(null).length).toBeGreaterThan(0);
    expect(
      parseDailySummarySystemInstruction(" "),
    ).toBe(DAILY_SUMMARY_SYSTEM_INSTRUCTION);
    expect(
      parseDailySummaryResponseSchema({type: "string"}),
    ).toBe(DAILY_SUMMARY_RESPONSE_SCHEMA);
  });
});
