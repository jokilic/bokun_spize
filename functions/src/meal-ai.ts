/**
 * Generates structured meals from text and images with Gemini
 */

import {GoogleGenAI, Part} from "@google/genai";
import {getApp} from "firebase-admin/app";
import {
  DocumentData,
  DocumentReference,
  FieldValue,
  Firestore,
} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import * as logger from "firebase-functions/logger";

import {
  DEFAULT_AI_MODEL_NAMES,
  parseDailySummaryModelNames,
} from "./daily-summary-ai";

/** Meal data returned by Gemini and persisted in Firestore */
export interface GeneratedMeal {
  name: string;
  emoji: string;
  color: string;
  nutrition: GeneratedNutrition;
  foods: GeneratedFood[];
}

/** Nutrition data shared by generated meals and foods */
export interface GeneratedNutrition {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

/** One food item returned as part of a generated meal */
export interface GeneratedFood {
  name: string;
  emoji: string;
  color: string;
  quantity: number;
  unit: string;
  nutrition: GeneratedNutrition;
}

/** Remote configuration used for meal generation */
export interface MealAIConfiguration {
  modelNames: string[];
  mealSystemInstruction: string;
  mealResponseSchema: Record<string, unknown>;
}

/** Result of a successful model fallback attempt */
export interface GeneratedMealResult {
  meal: GeneratedMeal;
  modelName: string;
}

/** Input loaded from a pending meal document and optional Storage image */
export interface MealGenerationInput {
  text: string | null;
  image: Buffer | null;
  imageContentType: string | null;
  languageCode: string;
}

/** Global Vertex AI location supports the broadest Gemini model selection */
export const MEAL_AI_LOCATION = "global";

/** Instructions preserve the established client-side meal extraction behavior */
export const MEAL_SYSTEM_INSTRUCTION = `
You will receive text and / or image describing what the user ate.
Estimate nutrition and extract foods.
Use the language identified by language code "{languageCode}" for meal names, food names, and unit names.
Keep JSON property names unchanged and preserve standard unit symbols such as g and ml.

Return only one valid Meal JSON object.
If quantity is unclear, make a reasonable estimate.
If nutrition is unknown, estimate based on typical values.
`.trim();

/** Structured meal schema used when remote configuration is missing or invalid */
export const MEAL_RESPONSE_SCHEMA: Record<string, unknown> = {
  type: "object",
  title: "Meal",
  propertyOrdering: ["name", "emoji", "color", "nutrition", "foods"],
  required: ["name", "emoji", "color", "nutrition", "foods"],
  additionalProperties: false,
  properties: {
    name: {
      type: "string",
      description: "Name best describing the meal in {languageCode}",
    },
    emoji: {
      type: "string",
      description: "Only one emoji best describing the meal",
    },
    color: {
      type: "string",
      description: "Color best describing the meal in hex format such as #FF0000",
    },
    nutrition: {
      type: "object",
      required: ["calories", "protein", "carbs", "fat"],
      additionalProperties: false,
      properties: {
        calories: {type: "number", description: "Calories in kcal"},
        protein: {type: "number", description: "Protein in g"},
        carbs: {type: "number", description: "Carbs in g"},
        fat: {type: "number", description: "Fat in g"},
      },
    },
    foods: {
      type: "array",
      description: "Foods in the meal",
      items: {
        type: "object",
        required: ["name", "emoji", "color", "quantity", "unit", "nutrition"],
        additionalProperties: false,
        properties: {
          name: {
            type: "string",
            description: "Food name in {languageCode}",
          },
          emoji: {
            type: "string",
            description: "Only one emoji best describing the food",
          },
          color: {
            type: "string",
            description: "Color best describing the food in hex format such as #FF0000",
          },
          quantity: {type: "number", description: "Quantity of food"},
          unit: {
            type: "string",
            description: "Food unit in {languageCode}, preserving standard unit symbols",
          },
          nutrition: {
            type: "object",
            required: ["calories", "protein", "carbs", "fat"],
            additionalProperties: false,
            properties: {
              calories: {type: "number", description: "Calories in kcal for this food"},
              protein: {type: "number", description: "Protein in g for this food"},
              carbs: {type: "number", description: "Carbs in g for this food"},
              fat: {type: "number", description: "Fat in g for this food"},
            },
          },
        },
      },
    },
  },
};

/** Returns a record only for non-array object values */
export function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === "object" && value !== null && !Array.isArray(value) ?
    value as Record<string, unknown> :
    null;
}

/** Replaces language placeholders throughout a JSON-compatible value */
export function localizeMealConfigurationValue(
  value: unknown,
  languageCode: string,
): unknown {
  if (typeof value === "string") {
    return value.replaceAll("{languageCode}", languageCode);
  }

  if (Array.isArray(value)) {
    return value.map((child) => localizeMealConfigurationValue(child, languageCode));
  }

  const record = asRecord(value);

  if (record !== null) {
    return Object.fromEntries(
      Object.entries(record).map(([key, child]) => [
        key,
        localizeMealConfigurationValue(child, languageCode),
      ]),
    );
  }

  return value;
}

/** Verifies that a configurable schema retains every required meal field and type */
export function isMealSchemaCompatible(
  candidate: unknown,
  expected: unknown = MEAL_RESPONSE_SCHEMA,
): boolean {
  const candidateRecord = asRecord(candidate);
  const expectedRecord = asRecord(expected);

  if (candidateRecord === null || expectedRecord === null) {
    return false;
  }

  const expectedType = expectedRecord.type;
  const candidateType = candidateRecord.type;
  const compatibleType = candidateType === expectedType ||
    (expectedType === "number" && candidateType === "integer");

  if (!compatibleType) {
    return false;
  }

  if (expectedType === "object") {
    const candidateProperties = asRecord(candidateRecord.properties);
    const expectedProperties = asRecord(expectedRecord.properties);
    const candidateRequired = candidateRecord.required;

    if (
      candidateProperties === null ||
      expectedProperties === null ||
      !Array.isArray(candidateRequired)
    ) {
      return false;
    }

    for (const [key, expectedProperty] of Object.entries(expectedProperties)) {
      if (
        !candidateRequired.includes(key) ||
        !isMealSchemaCompatible(candidateProperties[key], expectedProperty)
      ) {
        return false;
      }
    }
  }

  if (expectedType === "array") {
    return isMealSchemaCompatible(candidateRecord.items, expectedRecord.items);
  }

  return true;
}

/** Converts the former Firebase AI schema shape into Vertex JSON schema */
export function normalizeMealSchemaNode(
  value: unknown,
  languageCode: string,
): Record<string, unknown> | null {
  const localized = asRecord(
    localizeMealConfigurationValue(value, languageCode),
  );

  if (localized === null || typeof localized.type !== "string") {
    return null;
  }

  const supportedKeys = new Set([
    "type",
    "title",
    "description",
    "nullable",
    "format",
    "enum",
    "properties",
    "required",
    "optionalProperties",
    "propertyOrdering",
    "items",
    "minItems",
    "maxItems",
    "minimum",
    "maximum",
    "additionalProperties",
  ]);

  if (Object.keys(localized).some((key) => !supportedKeys.has(key))) {
    return null;
  }

  const normalized = {...localized};
  delete normalized.optionalProperties;
  delete normalized.format;

  if (localized.type === "object") {
    const properties = asRecord(localized.properties);

    if (properties === null || Object.keys(properties).length === 0) {
      return null;
    }

    const normalizedProperties: Record<string, unknown> = {};

    for (const [key, property] of Object.entries(properties)) {
      const normalizedProperty = normalizeMealSchemaNode(property, languageCode);

      if (normalizedProperty === null) {
        return null;
      }

      normalizedProperties[key] = normalizedProperty;
    }

    const propertyNames = Object.keys(properties);
    const configuredRequired = localized.required;
    const optionalProperties = localized.optionalProperties;
    const required = Array.isArray(configuredRequired) ?
      configuredRequired :
      Array.isArray(optionalProperties) ?
        propertyNames.filter((name) => !optionalProperties.includes(name)) :
        propertyNames;

    if (
      !required.every((name): name is string => typeof name === "string") ||
      required.some((name) => !propertyNames.includes(name))
    ) {
      return null;
    }

    normalized.properties = normalizedProperties;
    normalized.required = required;
  }

  if (localized.type === "array") {
    const items = normalizeMealSchemaNode(localized.items, languageCode);

    if (items === null) {
      return null;
    }

    normalized.items = items;
  }

  return normalized;
}

/** Decodes and validates the remotely configured meal response schema */
export function parseMealResponseSchema(
  value: unknown,
  languageCode: string,
): Record<string, unknown> {
  try {
    const decoded: unknown = typeof value === "string" ? JSON.parse(value) : value;
    const normalized = normalizeMealSchemaNode(decoded, languageCode);

    if (normalized === null || !isMealSchemaCompatible(normalized)) {
      return localizeMealConfigurationValue(
        MEAL_RESPONSE_SCHEMA,
        languageCode,
      ) as Record<string, unknown>;
    }

    return normalized;
  } catch (error) {
    logger.warn("Meal response schema is invalid", {
      error: error instanceof Error ? error.message.slice(0, 500) : "Unknown schema error",
    });

    return localizeMealConfigurationValue(
      MEAL_RESPONSE_SCHEMA,
      languageCode,
    ) as Record<string, unknown>;
  }
}

/** Loads meal AI settings from config/ai with independent field fallbacks */
export async function getMealAIConfiguration(
  firestore: Firestore,
  languageCode: string,
): Promise<MealAIConfiguration> {
  try {
    const snapshot = await firestore.doc("config/ai").get();
    const data = snapshot.data();
    const remoteInstruction = data?.mealSystemInstruction;
    const instruction = typeof remoteInstruction === "string" && remoteInstruction.trim().length > 0 ?
      remoteInstruction.trim() :
      MEAL_SYSTEM_INSTRUCTION;

    return {
      modelNames: parseDailySummaryModelNames(data?.modelNames),
      mealSystemInstruction: instruction.replaceAll("{languageCode}", languageCode),
      mealResponseSchema: parseMealResponseSchema(
        data?.mealResponseSchema,
        languageCode,
      ),
    };
  } catch (error) {
    logger.warn("Loading meal AI configuration failed", {
      error: error instanceof Error ? error.message.slice(0, 500) : "Unknown Firestore error",
    });

    return {
      modelNames: DEFAULT_AI_MODEL_NAMES,
      mealSystemInstruction: MEAL_SYSTEM_INSTRUCTION.replaceAll(
        "{languageCode}",
        languageCode,
      ),
      mealResponseSchema: localizeMealConfigurationValue(
        MEAL_RESPONSE_SCHEMA,
        languageCode,
      ) as Record<string, unknown>,
    };
  }
}

/** Parses one finite nonnegative numeric response property */
export function parseGeneratedNumber(value: unknown, propertyName: string): number {
  if (typeof value !== "number" || !Number.isFinite(value) || value < 0) {
    throw new Error(`Gemini returned invalid ${propertyName}`);
  }

  return value;
}

/** Parses one required bounded nonblank string response property */
export function parseGeneratedString(
  value: unknown,
  propertyName: string,
  maximumLength: number,
): string {
  if (
    typeof value !== "string" ||
    value.trim().length === 0 ||
    value.trim().length > maximumLength
  ) {
    throw new Error(`Gemini returned invalid ${propertyName}`);
  }

  return value.trim();
}

/** Parses a color that the Flutter meal parser can safely decode */
export function parseGeneratedColor(value: unknown, propertyName: string): string {
  const color = parseGeneratedString(value, propertyName, 7);

  if (!/^#[0-9a-fA-F]{6}$/.test(color)) {
    throw new Error(`Gemini returned invalid ${propertyName}`);
  }

  return color;
}

/** Parses and validates generated nutrition */
export function parseGeneratedNutrition(value: unknown): GeneratedNutrition {
  const nutrition = asRecord(value);

  if (nutrition === null) {
    throw new Error("Gemini returned invalid nutrition");
  }

  return {
    calories: parseGeneratedNumber(nutrition.calories, "calories"),
    protein: parseGeneratedNumber(nutrition.protein, "protein"),
    carbs: parseGeneratedNumber(nutrition.carbs, "carbs"),
    fat: parseGeneratedNumber(nutrition.fat, "fat"),
  };
}

/** Parses and validates one generated food */
export function parseGeneratedFood(value: unknown): GeneratedFood {
  const food = asRecord(value);

  if (food === null) {
    throw new Error("Gemini returned invalid food data");
  }

  return {
    name: parseGeneratedString(food.name, "food name", 500),
    emoji: parseGeneratedString(food.emoji, "food emoji", 32),
    color: parseGeneratedColor(food.color, "food color"),
    quantity: parseGeneratedNumber(food.quantity, "food quantity"),
    unit: parseGeneratedString(food.unit, "food unit", 100),
    nutrition: parseGeneratedNutrition(food.nutrition),
  };
}

/** Parses and validates one structured Gemini meal response */
export function parseGeneratedMeal(text: string | undefined): GeneratedMeal {
  if (text === undefined) {
    throw new Error("Gemini returned no meal data");
  }

  const meal = asRecord(JSON.parse(text));

  if (
    meal === null ||
    !Array.isArray(meal.foods) ||
    meal.foods.length > 200
  ) {
    throw new Error("Gemini returned invalid meal data");
  }

  return {
    name: parseGeneratedString(meal.name, "meal name", 500),
    emoji: parseGeneratedString(meal.emoji, "meal emoji", 32),
    color: parseGeneratedColor(meal.color, "meal color"),
    nutrition: parseGeneratedNutrition(meal.nutrition),
    foods: meal.foods.map(parseGeneratedFood),
  };
}

/** Resolves the Google Cloud project in deployed and emulator environments */
export function getMealAIProjectId(): string | undefined {
  return getApp().options.projectId ??
    process.env.GOOGLE_CLOUD_PROJECT ??
    process.env.GCLOUD_PROJECT;
}

/** Builds multimodal Gemini content from the available meal request fields */
export function buildMealContentParts(input: MealGenerationInput): Part[] {
  const parts: Part[] = [];

  if (input.text !== null && input.text.length > 0) {
    parts.push({text: input.text});
  }

  if (input.image !== null && input.imageContentType !== null) {
    parts.push({
      inlineData: {
        mimeType: input.imageContentType,
        data: input.image.toString("base64"),
      },
    });
  }

  if (parts.length === 0) {
    throw new Error("Meal generation requires text or an image");
  }

  return parts;
}

/** Generates a structured meal while falling through configured models on errors */
export async function generateMeal(
  firestore: Firestore,
  input: MealGenerationInput,
): Promise<GeneratedMealResult> {
  const project = getMealAIProjectId();

  if (project === undefined) {
    throw new Error("Firebase project ID is unavailable for meal generation");
  }

  const ai = new GoogleGenAI({
    enterprise: true,
    project,
    location: MEAL_AI_LOCATION,
  });
  const configuration = await getMealAIConfiguration(
    firestore,
    input.languageCode,
  );
  const parts = buildMealContentParts(input);
  const failures: string[] = [];

  for (const model of configuration.modelNames) {
    try {
      const response = await ai.models.generateContent({
        model,
        contents: [{role: "user", parts}],
        config: {
          systemInstruction: configuration.mealSystemInstruction,
          responseMimeType: "application/json",
          responseJsonSchema: configuration.mealResponseSchema,
          temperature: 0.2,
          maxOutputTokens: 4096,
        },
      });

      return {
        meal: parseGeneratedMeal(response.text),
        modelName: model,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown Gemini error";
      failures.push(`${model}: ${message}`);
      logger.warn("Meal generation model failed", {
        model,
        error: message.slice(0, 500),
      });
    }
  }

  throw new Error(`Generating the meal failed: ${failures.join(" | ").slice(0, 900)}`);
}

/** Returns the request language supported by the app */
export function getMealLanguageCode(data: DocumentData): string {
  return data.aiGenerationLanguage === "en" ? "en" : "hr";
}

/** Loads and validates the optional meal image owned by the triggering user */
export async function loadMealImage(
  data: DocumentData,
  userId: string,
): Promise<{image: Buffer | null; contentType: string | null}> {
  const imageStoragePath = data.imageStoragePath;

  if (imageStoragePath === null || imageStoragePath === undefined) {
    return {image: null, contentType: null};
  }

  if (
    typeof imageStoragePath !== "string" ||
    !imageStoragePath.startsWith(`users/${userId}/meal-images/`)
  ) {
    throw new Error("Meal image path does not belong to the user");
  }

  const file = getStorage().bucket().file(imageStoragePath);
  const [[image], [metadata]] = await Promise.all([
    file.download(),
    file.getMetadata(),
  ]);
  const contentType = metadata.contentType;

  if (typeof contentType !== "string" || !contentType.startsWith("image/")) {
    throw new Error("Meal image has an invalid content type");
  }

  return {image, contentType};
}

/** Builds the complete model input from a pending Firestore meal */
export async function buildMealGenerationInput(
  data: DocumentData,
  userId: string,
): Promise<MealGenerationInput> {
  const originalText = typeof data.originalText === "string" ? data.originalText.trim() : "";
  const loadedImage = await loadMealImage(data, userId);

  return {
    text: originalText.length > 0 ? originalText : null,
    image: loadedImage.image,
    imageContentType: loadedImage.contentType,
    languageCode: getMealLanguageCode(data),
  };
}

/** Returns a short localized meal error suitable for direct display */
export function getMealGenerationError(languageCode: string): string {
  return languageCode === "en" ?
    "Meal generation failed. Delete it and try again" :
    "Generiranje obroka nije uspjelo. Izbriši ga i pokušaj ponovno";
}

/** Processes one ready AI meal and persists either success or error state */
export async function processPendingAIMeal(
  mealReference: DocumentReference<DocumentData>,
  userId: string,
): Promise<void> {
  const currentSnapshot = await mealReference.get();
  const currentData = currentSnapshot.data();

  if (
    !currentSnapshot.exists ||
    currentData?.isLoading !== true ||
    currentData.aiGenerationReady !== true
  ) {
    return;
  }

  const languageCode = getMealLanguageCode(currentData);

  try {
    const input = await buildMealGenerationInput(currentData, userId);
    const result = await generateMeal(mealReference.firestore, input);

    await mealReference.update({
      ...result.meal,
      methodOfCreation: result.modelName,
      isLoading: false,
      errors: null,
      aiGenerationLanguage: FieldValue.delete(),
      aiGenerationReady: FieldValue.delete(),
    });
  } catch (error) {
    logger.error("Generating AI meal failed", {
      userId,
      mealId: mealReference.id,
      error: error instanceof Error ? error.message.slice(0, 900) : "Unknown meal generation error",
    });

    await mealReference.update({
      isLoading: false,
      errors: [getMealGenerationError(languageCode)],
      aiGenerationLanguage: FieldValue.delete(),
      aiGenerationReady: FieldValue.delete(),
    });
  }
}
