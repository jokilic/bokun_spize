import {describe, expect, it} from "vitest";

import {
  buildMealContentParts,
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
