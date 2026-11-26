import {ApiError, type GenerateContentResponse} from "@google/genai";
import {Timestamp} from "firebase-admin/firestore";
import {describe, expect, it, vi} from "vitest";

import {
  buildMealContentParts,
  generateMeal,
  getAIMealQuota,
  MAX_AI_MEAL_DESCRIPTION_LENGTH,
  MEAL_AI_PRIMARY_MODEL,
  MEAL_AI_TEXT_FALLBACK_MODEL,
  NoFoodInImageError,
  parseAIMealCallableInput,
  parseGeneratedMeal,
} from "../src/meal-ai";

const nutrition = {
  calories: 420,
  protein: 30,
  carbs: 35,
  fat: 18,
};

describe("localized AI meals", () => {
  it("parses compact English and Croatian meal text with shared values", () => {
    const meal = parseGeneratedMeal(JSON.stringify({
      status: "meal",
      meal: {
        name: {
          en: "Chicken salad",
          hr: "Pileća salata",
        },
        emoji: "🥗",
        color: "#5F9E52",
        nutrition,
        foods: [{
          name: {
            en: "Chicken",
            hr: "Piletina",
          },
          emoji: "🥗",
          color: "#C98B62",
          quantity: 150,
          unit: {
            en: "g",
            hr: "g",
          },
          nutrition,
        }],
      },
    }));

    expect(meal.name.en).toBe("Chicken salad");
    expect(meal.name.hr).toBe("Pileća salata");
    expect(meal.foods[0].name.en).toBe("Chicken");
    expect(meal.foods[0].name.hr).toBe("Piletina");
    expect(meal.foods[0].nutrition).toEqual(nutrition);
  });

  it("rejects an image classified as containing no food or drink", () => {
    expect(() => parseGeneratedMeal(JSON.stringify({
      status: "no_food_in_image",
    }))).toThrow(NoFoodInImageError);
  });

  it("passes callable WebP bytes to Gemini as inline data", () => {
    const imageBase64 = Buffer.from("RIFF0000WEBP").toString("base64");
    const input = parseAIMealCallableInput({
      mealId: "123e4567-e89b-12d3-a456-426614174000",
      languageCode: "en",
      imageBase64,
      imageContentType: "image/webp",
      imageBlurHash: "blur-hash",
    });

    expect(input.image?.base64).toBe(imageBase64);
    expect(buildMealContentParts({
      text: "Chicken salad",
      imageBase64: input.image?.base64 ?? null,
      imageContentType: input.image?.contentType ?? null,
    })).toEqual([
      {text: "Chicken salad"},
      {
        inlineData: {
          mimeType: "image/webp",
          data: imageBase64,
        },
      },
    ]);
  });
});

const textMeal = {
  text: "Chicken and rice",
  imageBase64: null,
  imageContentType: null,
};

const photoMeal = {
  ...textMeal,
  imageBase64: Buffer.from("RIFF0000WEBP").toString("base64"),
  imageContentType: "image/webp",
};

/** Exercises provider attempts without issuing paid requests */
describe("AI meal generation cost controls", () => {
  /** Checks the maximum description length before sending content */
  it("accepts the limit and rejects longer descriptions", () => {
    const text = "a".repeat(MAX_AI_MEAL_DESCRIPTION_LENGTH);

    expect(buildMealContentParts({...textMeal, text})).toEqual([{text}]);
    expect(() => buildMealContentParts({...textMeal, text: text + "a"})).toThrow("maximum length");
  });

  /** Keeps the attempt and model available for analytics after a successful generation */
  it.each([
    {attempt: 1, modelName: MEAL_AI_PRIMARY_MODEL},
    {attempt: 2, modelName: MEAL_AI_TEXT_FALLBACK_MODEL},
  ])("reports the successful model on attempt $attempt", async ({attempt, modelName}) => {
    const text = JSON.stringify({
      status: "meal",
      meal: {
        name: {en: "Chicken and rice", hr: "Piletina i riža"},
        emoji: "🍗",
        color: "#C98B62",
        nutrition,
        foods: [],
      },
    });
    const generateContent = vi.fn().mockResolvedValue({text} satisfies Pick<GenerateContentResponse, "text">);
    if (attempt === 2) {
      generateContent.mockRejectedValueOnce(new ApiError({status: 503, message: "Service unavailable"}));
    }

    vi.useFakeTimers();
    try {
      const result = expect(generateMeal(textMeal, {generateContent}))
        .resolves.toMatchObject({attempt, modelName});

      await vi.runAllTimersAsync();
      await result;
    } finally {
      vi.useRealTimers();
    }
  });

  /** Prevents SDK retries from multiplying the two model calls */
  it.each([
    {kind: "text", input: textMeal, fallback: MEAL_AI_TEXT_FALLBACK_MODEL},
    {kind: "photo", input: photoMeal, fallback: MEAL_AI_PRIMARY_MODEL},
  ])("makes at most two calls for a $kind meal", async ({input, fallback}) => {
    vi.useFakeTimers();
    try {
      const error = new ApiError({status: 503, message: "Service unavailable"});
      const generateContent = vi.fn().mockRejectedValue(error);
      const result = expect(generateMeal(input, {generateContent})).rejects.toBe(error);

      await vi.advanceTimersByTimeAsync(999);
      expect(generateContent).toHaveBeenCalledTimes(1);

      await vi.runAllTimersAsync();
      await result;
      expect(generateContent.mock.calls.map(([request]) => request.model)).toEqual([
        MEAL_AI_PRIMARY_MODEL,
        fallback,
      ]);
      for (const [request] of generateContent.mock.calls) {
        expect(request.config).toMatchObject({
          httpOptions: {retryOptions: {attempts: 1}},
          mediaResolution: "MEDIA_RESOLUTION_MEDIUM",
          thinkingConfig: {thinkingLevel: "MINIMAL"},
          maxOutputTokens: 4096,
        });
      }
    } finally {
      vi.useRealTimers();
    }
  });

  /** Ends a failed request when the provider reports a permanent error */
  it("does not retry permanent API errors", async () => {
    const error = new ApiError({status: 400, message: "Invalid request"});
    const generateContent = vi.fn().mockRejectedValue(error);

    await expect(generateMeal(textMeal, {generateContent})).rejects.toBe(error);
    expect(generateContent).toHaveBeenCalledTimes(1);
  });

  /** Ends the request after a received response fails meal validation */
  it.each([
    {kind: "invalid JSON", text: "invalid JSON", error: SyntaxError},
    {kind: "no food", text: '{"status":"no_food_in_image"}', error: NoFoodInImageError},
  ])("does not retry a response classified as $kind", async ({text, error}) => {
    const generateContent = vi.fn().mockResolvedValue({text} satisfies Pick<GenerateContentResponse, "text">);

    await expect(generateMeal(photoMeal, {generateContent})).rejects.toThrow(error);
    expect(generateContent).toHaveBeenCalledTimes(1);
  });
});

/** Covers the quota boundaries used by the meal claim transaction */
describe("AI meal quota", () => {
  /** Allows a fourth request exactly one minute after the oldest recent attempt */
  it("enforces a rolling minute without rounding to a clock minute", () => {
    const first = Date.UTC(2026, 0, 5, 14, 0, 30);
    const attempts = [first, first + 10_000, first + 20_000].map((time) => Timestamp.fromMillis(time));

    expect(getAIMealQuota(attempts.slice(0, 2), first + 20_000).retryAtMillis).toBeNull();
    expect(getAIMealQuota(attempts, first + 59_999).retryAtMillis).toBe(first + 60_000);
    expect(getAIMealQuota(attempts, first + 60_000).retryAtMillis).toBeNull();
  });

  /** Allows the 25th request and resets the daily count at UTC midnight */
  it("enforces the UTC daily limit", () => {
    const midnight = Date.UTC(2026, 0, 6);
    const attempts = Array.from(
      {length: 25},
      (_, index) => Timestamp.fromMillis(midnight - (index + 2) * 60_000),
    );

    expect(getAIMealQuota(attempts.slice(1), midnight - 1).retryAtMillis).toBeNull();
    expect(getAIMealQuota(attempts, midnight - 1).retryAtMillis).toBe(midnight);
    expect(getAIMealQuota(attempts, midnight)).toEqual({
      retainedAttempts: [],
      retryAtMillis: null,
    });
  });

  /** Uses the later expiry when both limits apply across midnight */
  it("carries recent attempts across the daily reset", () => {
    const midnight = Date.UTC(2026, 0, 6);
    const recentAttempts = [midnight - 30_000, midnight - 20_000, midnight - 10_000]
      .map((time) => Timestamp.fromMillis(time));
    const earlierAttempts = Array.from(
      {length: 22},
      (_, index) => Timestamp.fromMillis(midnight - (index + 2) * 60_000),
    );
    const attempts = [...earlierAttempts, ...recentAttempts];

    expect(getAIMealQuota(attempts, midnight - 1).retryAtMillis).toBe(midnight + 30_000);
    expect(getAIMealQuota(attempts, midnight)).toEqual({
      retainedAttempts: recentAttempts,
      retryAtMillis: midnight + 30_000,
    });
    expect(getAIMealQuota(attempts, midnight + 30_000).retryAtMillis).toBeNull();
  });
});
