/**
 * Generates structured meals from text and images with Gemini
 */

import {GoogleGenAI, Part} from "@google/genai";
import {randomUUID} from "node:crypto";
import {getApp} from "firebase-admin/app";
import {
  DocumentData,
  DocumentReference,
  FieldValue,
  Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import * as logger from "firebase-functions/logger";

import {AI_MODEL_NAMES} from "./daily-summary-ai";

/** One localized meal payload returned by Gemini */
export interface GeneratedMealContent {
  name: string;
  emoji: string;
  color: string;
  nutrition: GeneratedNutrition;
  foods: GeneratedFood[];
}

/** Localized meal data returned by Gemini and persisted in Firestore */
export interface GeneratedMeal {
  en: GeneratedMealContent;
  hr: GeneratedMealContent;
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

/** Result of a successful model fallback attempt */
export interface GeneratedMealResult {
  meal: GeneratedMeal;
  modelName: string;
}

/** Input resolved from a pending meal document and optional Storage image */
export interface MealGenerationInput {
  text: string | null;
  imageUri: string | null;
  imageContentType: string | null;
}

/** Transaction result used to coordinate concurrent trigger deliveries */
export interface AIMealGenerationClaim {
  status: "claimed" | "busy" | "not-ready";
  mealData: DocumentData | null;
}

/** Global Vertex AI location supports the broadest Gemini model selection */
export const MEAL_AI_LOCATION = "global";

/** Lease outlives the function timeout while allowing crashed jobs to recover */
export const AI_MEAL_GENERATION_LEASE_DURATION_MS = 10 * 60 * 1000;

/** Maximum time allowed for the client to attach an AI meal image */
export const AI_MEAL_IMAGE_UPLOAD_TIMEOUT_MS = 15 * 60 * 1000;

/** Maximum abandoned image requests processed by one cleanup occurrence */
export const AI_MEAL_IMAGE_CLEANUP_LIMIT = 200;

/** Instructions preserve the established meal extraction behavior */
export const MEAL_SYSTEM_INSTRUCTION = `
You will receive text and / or image describing what the user ate.
Estimate nutrition and extract foods.
If quantity is unclear, make a reasonable estimate.
If nutrition is unknown, estimate based on typical values.
`.trim();

/** Mandatory localized output instructions appended to the meal prompt */
export const MEAL_LOCALIZATION_INSTRUCTION = `
Return one JSON object containing complete "en" and "hr" meal objects.
The user's text may be written in any language. Understand it in its original language.
Use English for meal names, food names, and unit names inside "en".
Use Croatian for meal names, food names, and unit names inside "hr".
Both objects must describe the same meal and use identical numeric nutrition values, quantities, emojis, and colors.
Keep JSON property names unchanged and preserve standard unit symbols such as g and ml.
`.trim();

/** Complete generated fields shared by both localized meal schema branches */
export const MEAL_CONTENT_RESPONSE_SCHEMA: Record<string, unknown> = {
  type: "object",
  propertyOrdering: ["name", "emoji", "color", "nutrition", "foods"],
  required: ["name", "emoji", "color", "nutrition", "foods"],
  additionalProperties: false,
  properties: {
    name: {
      type: "string",
      description: "Name best describing the meal",
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
            description: "Food name",
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
            description: "Food unit, preserving standard unit symbols",
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

/** Structured response schema for complete localized meals */
export const MEAL_RESPONSE_SCHEMA: Record<string, unknown> = {
  type: "object",
  title: "Meal",
  propertyOrdering: ["en", "hr"],
  required: ["en", "hr"],
  additionalProperties: false,
  properties: {
    en: {
      ...MEAL_CONTENT_RESPONSE_SCHEMA,
      description: "Complete meal data with English names and units",
    },
    hr: {
      ...MEAL_CONTENT_RESPONSE_SCHEMA,
      description: "Complete meal data with Croatian names and units",
    },
  },
};

/** Returns a record only for non-array object values */
export function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === "object" && value !== null && !Array.isArray(value) ?
    value as Record<string, unknown> :
    null;
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

/** Parses and validates one localized Gemini meal payload */
export function parseGeneratedMealContent(
  value: unknown,
  languageCode: "en" | "hr",
): GeneratedMealContent {
  const meal = asRecord(value);

  if (
    meal === null ||
    !Array.isArray(meal.foods) ||
    meal.foods.length > 200
  ) {
    throw new Error("Gemini returned invalid meal data");
  }

  return {
    name: parseGeneratedString(meal.name, `${languageCode} meal name`, 500),
    emoji: parseGeneratedString(meal.emoji, `${languageCode} meal emoji`, 32),
    color: parseGeneratedColor(meal.color, `${languageCode} meal color`),
    nutrition: parseGeneratedNutrition(meal.nutrition),
    foods: meal.foods.map(parseGeneratedFood),
  };
}

/** Parses and validates one structured localized Gemini meal response */
export function parseGeneratedMeal(text: string | undefined): GeneratedMeal {
  if (text === undefined) {
    throw new Error("Gemini returned no meal data");
  }

  const meal = asRecord(JSON.parse(text));

  if (meal === null) {
    throw new Error("Gemini returned invalid localized meal data");
  }

  return {
    en: parseGeneratedMealContent(meal.en, "en"),
    hr: parseGeneratedMealContent(meal.hr, "hr"),
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

  if (input.imageUri !== null && input.imageContentType !== null) {
    parts.push({
      fileData: {
        mimeType: input.imageContentType,
        fileUri: input.imageUri,
      },
    });
  }

  if (parts.length === 0) {
    throw new Error("Meal generation requires text or an image");
  }

  return parts;
}

/** Generates a structured meal while falling through models on errors */
export async function generateMeal(
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
  const parts = buildMealContentParts(input);
  const systemInstruction = [
    MEAL_SYSTEM_INSTRUCTION,
    MEAL_LOCALIZATION_INSTRUCTION,
  ].join("\n\n");
  const failures: string[] = [];

  for (const model of AI_MODEL_NAMES) {
    try {
      const response = await ai.models.generateContent({
        model,
        contents: [{role: "user", parts}],
        config: {
          systemInstruction,
          responseMimeType: "application/json",
          responseJsonSchema: MEAL_RESPONSE_SCHEMA,
          temperature: 0.2,
          maxOutputTokens: 8192,
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

/** Resolves and validates the optional meal image owned by the triggering user */
export async function loadMealImage(
  data: DocumentData,
  userId: string,
): Promise<{imageUri: string | null; contentType: string | null}> {
  const imageStoragePath = data.imageStoragePath;

  if (imageStoragePath === null || imageStoragePath === undefined) {
    return {imageUri: null, contentType: null};
  }

  if (
    typeof imageStoragePath !== "string" ||
    !imageStoragePath.startsWith(`users/${userId}/meal-images/`)
  ) {
    throw new Error("Meal image path does not belong to the user");
  }

  const bucket = getStorage().bucket();
  const file = bucket.file(imageStoragePath);
  const [metadata] = await file.getMetadata();
  const contentType = metadata.contentType;

  if (typeof contentType !== "string" || !contentType.startsWith("image/")) {
    throw new Error("Meal image has an invalid content type");
  }

  return {
    imageUri: `gs://${bucket.name}/${file.name}`,
    contentType,
  };
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
    imageUri: loadedImage.imageUri,
    imageContentType: loadedImage.contentType,
  };
}

/** Returns a short localized meal error suitable for direct display */
export function getMealGenerationError(languageCode: string): string {
  return languageCode === "en" ?
    "Meal generation failed. Delete it and try again" :
    "Generiranje obroka nije uspjelo. Izbriši ga i pokušaj ponovno";
}

/** Returns a short localized image upload error suitable for direct display */
export function getMealImageUploadError(languageCode: string): string {
  return languageCode === "en" ?
    "Image upload failed" :
    "Prijenos slike nije uspio";
}

/** Returns the server-only claim document paired with one meal */
export function getAIMealGenerationClaimReference(
  mealReference: DocumentReference<DocumentData>,
): DocumentReference<DocumentData> {
  const userReference = mealReference.parent.parent;

  if (userReference === null) {
    throw new Error("Meal does not belong to a user document");
  }

  return userReference.collection("mealGenerationClaims").doc(mealReference.id);
}

/** Atomically claims one ready meal or reports an active competing lease */
export async function claimPendingAIMeal(
  mealReference: DocumentReference<DocumentData>,
  leaseId: string,
  now: Date,
): Promise<AIMealGenerationClaim> {
  const firestore = mealReference.firestore;
  const claimReference = getAIMealGenerationClaimReference(mealReference);

  return firestore.runTransaction<AIMealGenerationClaim>(async (transaction) => {
    const mealSnapshot = await transaction.get(mealReference);
    const mealData = mealSnapshot.data();

    if (
      !mealSnapshot.exists ||
      mealData?.isLoading !== true ||
      mealData.aiGenerationReady !== true
    ) {
      return {
        status: "not-ready",
        mealData: null,
      };
    }

    const claimSnapshot = await transaction.get(claimReference);
    const existingExpiration = claimSnapshot.data()?.expiresAt;

    if (
      existingExpiration instanceof Timestamp &&
      existingExpiration.toMillis() > now.getTime()
    ) {
      return {
        status: "busy",
        mealData: null,
      };
    }

    transaction.set(claimReference, {
      leaseId,
      claimedAt: Timestamp.fromDate(now),
      expiresAt: Timestamp.fromMillis(
        now.getTime() + AI_MEAL_GENERATION_LEASE_DURATION_MS,
      ),
    });

    return {
      status: "claimed",
      mealData,
    };
  });
}

/** Writes a terminal meal state only when the caller still owns its lease */
export async function finalizePendingAIMeal(
  mealReference: DocumentReference<DocumentData>,
  leaseId: string,
  updates: DocumentData,
): Promise<boolean> {
  const firestore = mealReference.firestore;
  const claimReference = getAIMealGenerationClaimReference(mealReference);

  return firestore.runTransaction<boolean>(async (transaction) => {
    const claimSnapshot = await transaction.get(claimReference);

    if (claimSnapshot.data()?.leaseId !== leaseId) {
      return false;
    }

    const mealSnapshot = await transaction.get(mealReference);
    const mealData = mealSnapshot.data();

    if (
      mealSnapshot.exists &&
      mealData?.isLoading === true &&
      mealData.aiGenerationReady === true
    ) {
      transaction.update(mealReference, updates);
    }

    transaction.delete(claimReference);
    return mealSnapshot.exists;
  });
}

/** Removes a claim when its meal is deleted during processing */
export async function deleteAIMealGenerationClaim(
  mealReference: DocumentReference<DocumentData>,
): Promise<void> {
  await getAIMealGenerationClaimReference(mealReference).delete();
}

/** Finishes one expired image request unless it became ready after querying */
export async function failExpiredAIMealImageRequest(
  mealReference: DocumentReference<DocumentData>,
  cutoff: Timestamp,
): Promise<boolean> {
  return mealReference.firestore.runTransaction<boolean>(async (transaction) => {
    const mealSnapshot = await transaction.get(mealReference);
    const mealData = mealSnapshot.data();
    const requestedAt = mealData?.aiGenerationRequestedAt;

    if (
      !mealSnapshot.exists ||
      mealData?.isLoading !== true ||
      mealData.aiGenerationReady !== false ||
      !(requestedAt instanceof Timestamp) ||
      requestedAt.toMillis() > cutoff.toMillis()
    ) {
      return false;
    }

    transaction.update(mealReference, {
      isLoading: false,
      errors: [getMealImageUploadError(getMealLanguageCode(mealData))],
      aiGenerationLanguage: FieldValue.delete(),
      aiGenerationReady: FieldValue.delete(),
      aiGenerationRequestedAt: FieldValue.delete(),
    });

    return true;
  });
}

/** Finds and finishes image requests that never became ready */
export async function cleanupExpiredAIMealImageRequests(
  firestore: Firestore,
  now: Date,
): Promise<number> {
  const cutoff = Timestamp.fromMillis(
    now.getTime() - AI_MEAL_IMAGE_UPLOAD_TIMEOUT_MS,
  );
  const snapshot = await firestore
    .collectionGroup("meals")
    .where("isLoading", "==", true)
    .where("aiGenerationReady", "==", false)
    .where("aiGenerationRequestedAt", "<=", cutoff)
    .limit(AI_MEAL_IMAGE_CLEANUP_LIMIT)
    .get();
  const results = await Promise.all(
    snapshot.docs.map((document) => failExpiredAIMealImageRequest(
      document.ref,
      cutoff,
    )),
  );
  const failedCount = results.filter(Boolean).length;

  if (failedCount > 0) {
    logger.info("Finished abandoned AI meal image requests", {
      failedCount,
    });
  }

  return failedCount;
}

/** Processes one ready AI meal and persists either success or error state */
export async function processPendingAIMeal(
  mealReference: DocumentReference<DocumentData>,
  userId: string,
): Promise<void> {
  const leaseId = randomUUID();
  const claim = await claimPendingAIMeal(
    mealReference,
    leaseId,
    new Date(),
  );

  if (claim.status === "not-ready") {
    return;
  }

  if (claim.status === "busy") {
    throw new Error(`AI meal ${mealReference.id} already has an active generation lease`);
  }

  const mealData = claim.mealData!;
  const languageCode = getMealLanguageCode(mealData);
  let result: GeneratedMealResult;

  try {
    const input = await buildMealGenerationInput(mealData, userId);
    result = await generateMeal(input);
  } catch (error) {
    logger.error("Generating AI meal failed", {
      userId,
      mealId: mealReference.id,
      error: error instanceof Error ? error.message.slice(0, 900) : "Unknown meal generation error",
    });

    await finalizePendingAIMeal(mealReference, leaseId, {
      isLoading: false,
      errors: [getMealGenerationError(languageCode)],
      aiGenerationLanguage: FieldValue.delete(),
      aiGenerationReady: FieldValue.delete(),
      aiGenerationRequestedAt: FieldValue.delete(),
    });

    return;
  }

  await finalizePendingAIMeal(mealReference, leaseId, {
    en: result.meal.en,
    hr: result.meal.hr,
    name: FieldValue.delete(),
    emoji: FieldValue.delete(),
    color: FieldValue.delete(),
    nutrition: FieldValue.delete(),
    foods: FieldValue.delete(),
    methodOfCreation: result.modelName,
    isLoading: false,
    errors: null,
    aiGenerationLanguage: FieldValue.delete(),
    aiGenerationReady: FieldValue.delete(),
    aiGenerationRequestedAt: FieldValue.delete(),
  });
}
