import {execFileSync} from "node:child_process";
import {readFile} from "node:fs/promises";
import {GoogleGenAI} from "@google/genai";
import {
  generateMealWithModel,
  MEAL_AI_LOCATION,
  MEAL_AI_PRIMARY_MODEL,
  MEAL_AI_TEXT_FALLBACK_MODEL,
  MEAL_IMAGE_CONTENT_TYPE,
  NoFoodInImageError,
  parseInlineMealImage,
} from "../src/meal-ai.ts";

/** Loads a benchmark fixture through the same WebP validation as the callable */
async function readPhoto(path) {
  const image = parseInlineMealImage({
    imageBase64: (await readFile(path)).toString("base64"),
    imageContentType: MEAL_IMAGE_CONTENT_TYPE,
  });

  return {imageBase64: image.base64, imageContentType: image.contentType};
}

/** Gets the active gcloud access token for this benchmark */
function getGcloudAuthOptions() {
  const token = execFileSync("gcloud", ["auth", "print-access-token", "--quiet"], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "inherit"],
  }).trim();

  return {
    authClient: {
      /** Supplies the credential to the Gemini SDK */
      async getRequestHeaders() {
        return new Headers({Authorization: `Bearer ${token}`});
      },
    },
  };
}

const [project, mixedPlatePath, nonFoodPath, authMode] = process.argv.slice(2);
if (!project || !mixedPlatePath || !nonFoodPath || (authMode && authMode !== "--gcloud")) {
  console.error("Usage: npm run benchmark:meal-ai -- PROJECT MIXED_PLATE.webp NON_FOOD.webp [--gcloud]");
  process.exit(1);
}

const textOnly = {imageBase64: null, imageContentType: null};
const cases = [
  {
    id: "en-explicit-portions",
    expected: "120 g grilled chicken, 150 g cooked rice, 80 g broccoli, 250 ml orange juice",
    input: {
      ...textOnly,
      text: "I ate 120 g grilled chicken, 150 g of cooked rice and 80 g of steamed broccoli. I drank 250 ml of orange juice.",
    },
  },
  {
    id: "hr-explicit-portions",
    expected: "180 g grilled sea bass, 150 g chard with potatoes, 10 g olive oil, 200 ml mineral water",
    input: {
      ...textOnly,
      text: "Pojeo sam 180 g brancina sa žara i 150 g blitve s krumpirom, preliveno s 10 g maslinova ulja. Popio sam 200 ml mineralne vode.",
    },
  },
  {
    id: "hr-estimated-portions",
    expected: "Two slices of whole-grain bread, one teaspoon of butter, one banana, one glass of kefir",
    input: {
      ...textOnly,
      text: "Dvije kriške integralnog kruha s jednom žličicom maslaca, jedna banana i čaša kefira.",
    },
  },
  {
    id: "mixed-plate",
    expected: "Visible foods match the fixture; photo quantities are estimates",
    input: {text: null, ...await readPhoto(mixedPlatePath)},
  },
  {
    id: "non-food-photo",
    expected: "No food, even with a meal description",
    expectsNoFood: true,
    input: {text: "Chicken and rice", ...await readPhoto(nonFoodPath)},
  },
];

const ai = new GoogleGenAI({
  enterprise: true,
  project,
  location: MEAL_AI_LOCATION,
  googleAuthOptions: authMode === "--gcloud" ? getGcloudAuthOptions() : undefined,
});

for (const model of [MEAL_AI_PRIMARY_MODEL, MEAL_AI_TEXT_FALLBACK_MODEL]) {
  for (const {id, expected, expectsNoFood = false, input} of cases) {
    const sample = {model, sample: id, expected};

    try {
      const {meal} = await generateMealWithModel(ai.models, model, input);
      const foods = meal.foods.map(({name, quantity, unit}) => ({name, quantity, unit}));
      console.log(JSON.stringify({
        ...sample,
        outcome: expectsNoFood ? "false-positive" : "meal",
        foods,
        totalCalories: meal.nutrition.calories,
      }));
    } catch (error) {
      if (error instanceof NoFoodInImageError) {
        console.log(JSON.stringify({...sample, outcome: expectsNoFood ? "no-food" : "false-negative"}));
        continue;
      }

      console.error(JSON.stringify({...sample, errorType: error.name, httpStatus: error.status}));
      process.exitCode = 1;

      if ([401, 403, 404].includes(error.status) || /default credentials/i.test(error.message)) {
        process.exit(1);
      }
    }
  }
}
