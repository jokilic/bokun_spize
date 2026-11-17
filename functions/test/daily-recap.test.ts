import {describe, expect, it} from "vitest";
import {Timestamp} from "firebase-admin/firestore";

import {
  buildDailyRecapNotification,
  getDailyRecapPeriod,
} from "../src/daily-recap";
import {
  buildDailyRecapPrompt,
  DAILY_RECAP_RESPONSE_SCHEMA,
  DAILY_RECAP_SYSTEM_INSTRUCTION,
  parseDailyRecapModelNames,
  parseDailyRecapResponse,
  parseDailyRecapResponseSchema,
  parseDailyRecapSystemInstruction,
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

  it("stores generated localized bodies without redundant titles", () => {
    const bodies = parseDailyRecapResponse(JSON.stringify({
      en: "You included fruit today. Add an egg next time for more protein.",
      hr: "Danas si uključio voće. Sljedeći put dodaj jaje za više proteina.",
    }));
    const notification = buildDailyRecapNotification(bodies);

    expect(notification).toEqual({
      en: {
        body: "You included fruit today. Add an egg next time for more protein.",
      },
      hr: {
        body: "Danas si uključio voće. Sljedeći put dodaj jaje za više proteina.",
      },
    });
  });

  it("parses independently configurable daily recap AI fields", () => {
    const schema = {
      type: "object",
      properties: {
        en: {type: "string"},
        hr: {type: "string"},
      },
      required: ["en", "hr"],
    };

    expect(parseDailyRecapModelNames([" model-a ", "model-a", "model-b"])).toEqual([
      "model-a",
      "model-b",
    ]);
    expect(
      parseDailyRecapSystemInstruction(" Custom instruction "),
    ).toBe("Custom instruction");
    expect(parseDailyRecapResponseSchema(JSON.stringify(schema))).toEqual(schema);
  });

  it("falls back when daily recap AI fields are invalid", () => {
    expect(parseDailyRecapModelNames(null).length).toBeGreaterThan(0);
    expect(
      parseDailyRecapSystemInstruction(" "),
    ).toBe(DAILY_RECAP_SYSTEM_INSTRUCTION);
    expect(
      parseDailyRecapResponseSchema({type: "string"}),
    ).toBe(DAILY_RECAP_RESPONSE_SCHEMA);
  });
});
