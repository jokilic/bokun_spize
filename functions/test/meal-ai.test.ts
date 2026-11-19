import {describe, expect, it} from "vitest";

import {parseGeneratedMeal} from "../src/meal-ai";

const nutrition = {
  calories: 420,
  protein: 30,
  carbs: 35,
  fat: 18,
};

describe("localized AI meals", () => {
  it("parses complete English and Croatian meal payloads", () => {
    const meal = parseGeneratedMeal(JSON.stringify({
      en: {
        name: "Chicken salad",
        emoji: "🥗",
        color: "#5F9E52",
        nutrition,
        foods: [{
          name: "Chicken",
          emoji: "🍗",
          color: "#C98B62",
          quantity: 150,
          unit: "g",
          nutrition,
        }],
      },
      hr: {
        name: "Pileća salata",
        emoji: "🥗",
        color: "#5F9E52",
        nutrition,
        foods: [{
          name: "Piletina",
          emoji: "🍗",
          color: "#C98B62",
          quantity: 150,
          unit: "g",
          nutrition,
        }],
      },
    }));

    expect(meal.en.name).toBe("Chicken salad");
    expect(meal.hr.name).toBe("Pileća salata");
    expect(meal.en.foods[0].name).toBe("Chicken");
    expect(meal.hr.foods[0].name).toBe("Piletina");
  });
});
