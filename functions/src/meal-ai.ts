/**
 * Generates compact localized meals from text and inline images with Gemini
 */

import {
  ApiError,
  type GenerateContentResponse,
  GoogleGenAI,
  MediaResolution,
  type Part,
  ThinkingLevel,
} from "@google/genai";
import { randomUUID } from "node:crypto";
import { getApp } from "firebase-admin/app";
import {
  type DocumentData,
  type DocumentReference,
  FieldValue,
  type Firestore,
  getFirestore,
  Timestamp,
  type Transaction,
} from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import * as logger from "firebase-functions/logger";
import { HttpsError } from "firebase-functions/v2/https";

import {getAIIntegerSetting} from "./ai-config.ts";
import {
  ProjectAIQuotaExceeded,
  reserveProjectAICall,
  reserveProjectAICallInTransaction,
  UTC_DAY_MILLIS,
} from "./project-ai-quota.ts";

/** Localized text generated once for each supported app language */
export interface GeneratedLocalizedText {
  en: string;
  hr: string;
}

/** Nutrition data shared by generated meals and foods */
export interface GeneratedNutrition {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

/** One compact food item with shared values and localized text */
export interface GeneratedFood {
  name: GeneratedLocalizedText;
  emoji: string;
  color: string;
  quantity: number;
  unit: GeneratedLocalizedText;
  nutrition: GeneratedNutrition;
}

/** Compact localized meal persisted directly in Firestore */
export interface GeneratedMeal {
  name: GeneratedLocalizedText;
  emoji: string;
  color: string;
  nutrition: GeneratedNutrition;
  foods: GeneratedFood[];
}

/** Result of a successful model fallback attempt */
export interface GeneratedMealResult {
  meal: GeneratedMeal;
  modelName: string;
}

/** Signals that the supplied photo has no recognizable food or drink */
export class NoFoodInImageError extends Error { }

/** Optional inline image supplied by the callable client */
export interface InlineMealImage {
  buffer: Buffer;
  base64: string;
  contentType: "image/webp";
  blurHash: string | null;
}

/** Input passed directly to Gemini */
export interface MealGenerationInput {
  text: string | null;
  imageBase64: string | null;
  imageContentType: string | null;
}

/** Validated callable request fields */
export interface AIMealCallableInput {
  mealId: string;
  languageCode: "en" | "hr";
  image: InlineMealImage | null;
}

/** Transaction result used to coordinate requests and enforce the user quota */
export type AIMealGenerationClaim =
  | { status: "claimed"; text: string | null }
  | { status: "busy" }
  | { status: "not-ready" }
  | { status: "invalid-input" }
  | { status: "rate-limited"; retryAtMillis: number; message: string }
  | { status: "project-rate-limited"; retryAtMillis: number; message: string };

/** Uploaded image information persisted with a generated meal */
export interface UploadedMealImage {
  storagePath: string;
  blurHash: string | null;
}

/** Result returned to the Flutter callable client */
export interface AIMealCallableResult {
  success: boolean;
}

/** General European bucket containing meal images and future app files */
export const APP_STORAGE_BUCKET = "bokun-spize-eu";

/** Global Vertex AI location supports the broadest Gemini model selection */
export const MEAL_AI_LOCATION = "global";

/** Primary model for all meals and the alternate model for text-only requests */
export const MEAL_AI_PRIMARY_MODEL = "gemini-3.5-flash-lite";
export const MEAL_AI_TEXT_FALLBACK_MODEL = "gemini-3.1-flash-lite";

/** Bounds input length and leaves room for a complete bilingual response */
export const MAX_AI_MEAL_DESCRIPTION_LENGTH = 2000;
export const AI_MEAL_MAX_OUTPUT_TOKENS = 4096;

/** Returns the backend description limit shared by request validation and prompt assembly */
export function getAIMealDescriptionLimit(): number {
  return getAIIntegerSetting("AI_MEAL_MAX_DESCRIPTION_LENGTH", MAX_AI_MEAL_DESCRIPTION_LENGTH);
}

/** Transient HTTP statuses eligible for the single delayed fallback */
export const MEAL_AI_RETRYABLE_STATUSES = [408, 429, 500, 502, 503, 504];

/** Inline images are already compressed to WebP by the Flutter app */
export const MEAL_IMAGE_CONTENT_TYPE = "image/webp";

/** Raw image limit leaves room below callable limits after Base64 encoding */
export const MAX_INLINE_MEAL_IMAGE_BYTES = 5 * 1024 * 1024;

/** Lease outlives the function timeout while allowing crashed jobs to recover */
export const AI_MEAL_GENERATION_LEASE_DURATION_MS = 10 * 60 * 1000;

/** Per-user AI meal generation limits */
export const AI_MEAL_MINUTE_LIMIT = 3;
export const AI_MEAL_DAILY_LIMIT = 25;
export const AI_MEAL_ROLLING_WINDOW_MS = 60 * 1000;

/** Maximum time before an interrupted callable request is marked failed */
export const AI_MEAL_REQUEST_TIMEOUT_MS = 15 * 60 * 1000;

/** Maximum abandoned requests processed by one cleanup occurrence */
export const AI_MEAL_CLEANUP_LIMIT = 200;

/** Instructions preserve extraction while preventing duplicated shared values */
export const MEAL_SYSTEM_INSTRUCTION = `
You will receive text and / or an image describing what the user ate.

When an image is supplied, check that it shows at least one recognizable food, drink, or edible ingredient.

If the image is unrelated or too unclear to identify any such item, return only {"status":"no_food_in_image"}, even if the accompanying text describes food.

For a meal, return status {"status":"meal"}, put the extracted foods and estimated nutrition in the meal object.
Include each identified drink as a food item, even if it has zero calories.

If quantity is unclear, make a reasonable estimate.
If nutrition is unknown, estimate based on typical values.

The user's text may be written in any language.
Understand it in its original language.

Return English and Croatian only for the localized name and unit objects.

All quantities, nutrition values, emojis, and colors must appear only once as shared values.

Keep JSON property names unchanged and preserve standard unit symbols such as g and ml.
`.trim();

/** Reusable schema for one English and Croatian text pair */
export const LOCALIZED_TEXT_RESPONSE_SCHEMA: Record<string, unknown> = {
  type: "object",
  propertyOrdering: ["en", "hr"],
  required: ["en", "hr"],
  additionalProperties: false,
  properties: {
    en: { type: "string", description: "English value" },
    hr: { type: "string", description: "Croatian value" },
  },
};

/** Reusable schema for nutrition values */
export const NUTRITION_RESPONSE_SCHEMA: Record<string, unknown> = {
  type: "object",
  propertyOrdering: ["calories", "protein", "carbs", "fat"],
  required: ["calories", "protein", "carbs", "fat"],
  additionalProperties: false,
  properties: {
    calories: { type: "number", description: "Calories in kcal" },
    protein: { type: "number", description: "Protein in g" },
    carbs: { type: "number", description: "Carbs in g" },
    fat: { type: "number", description: "Fat in g" },
  },
};

/** Structured response schema for one compact bilingual meal */
export const MEAL_RESPONSE_SCHEMA: Record<string, unknown> = {
  type: "object",
  title: "Meal",
  propertyOrdering: ["name", "emoji", "color", "nutrition", "foods"],
  required: ["name", "emoji", "color", "nutrition", "foods"],
  additionalProperties: false,
  properties: {
    name: {
      ...LOCALIZED_TEXT_RESPONSE_SCHEMA,
      description: "Meal name in English and Croatian",
    },
    emoji: {
      type: "string",
      description: "Only one emoji best describing the meal",
    },
    color: {
      type: "string",
      description: "Color best describing the meal in hex format such as #FF0000",
    },
    nutrition: NUTRITION_RESPONSE_SCHEMA,
    foods: {
      type: "array",
      description: "Foods in the meal",
      items: {
        type: "object",
        propertyOrdering: ["name", "emoji", "color", "quantity", "unit", "nutrition"],
        required: ["name", "emoji", "color", "quantity", "unit", "nutrition"],
        additionalProperties: false,
        properties: {
          name: {
            ...LOCALIZED_TEXT_RESPONSE_SCHEMA,
            description: "Food name in English and Croatian",
          },
          emoji: {
            type: "string",
            description: "Only one emoji best describing the food",
          },
          color: {
            type: "string",
            description: "Color best describing the food in hex format such as #FF0000",
          },
          quantity: { type: "number", description: "Quantity of food" },
          unit: {
            ...LOCALIZED_TEXT_RESPONSE_SCHEMA,
            description: "Food unit in English and Croatian while preserving standard symbols",
          },
          nutrition: NUTRITION_RESPONSE_SCHEMA,
        },
      },
    },
  },
};

/** Lets Gemini report an unrelated image without supplying meal data */
export const MEAL_GENERATION_RESPONSE_SCHEMA: Record<string, unknown> = {
  type: "object",
  propertyOrdering: ["status", "meal"],
  required: ["status"],
  additionalProperties: false,
  properties: {
    status: { type: "string", enum: ["meal", "no_food_in_image"] },
    meal: MEAL_RESPONSE_SCHEMA,
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
    throw new Error(`AI returned invalid ${propertyName}`);
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
    throw new Error(`AI returned invalid ${propertyName}`);
  }

  return value.trim();
}

/** Parses one complete English and Croatian text pair */
export function parseGeneratedLocalizedText(
  value: unknown,
  propertyName: string,
  maximumLength: number,
): GeneratedLocalizedText {
  const localizedText = asRecord(value);

  if (localizedText === null) {
    throw new Error(`AI returned invalid localized ${propertyName}`);
  }

  return {
    en: parseGeneratedString(localizedText.en, `English ${propertyName}`, maximumLength),
    hr: parseGeneratedString(localizedText.hr, `Croatian ${propertyName}`, maximumLength),
  };
}

/** Parses a color that the Flutter meal parser can safely decode */
export function parseGeneratedColor(value: unknown, propertyName: string): string {
  const color = parseGeneratedString(value, propertyName, 7);

  if (!/^#[0-9a-fA-F]{6}$/.test(color)) {
    throw new Error(`AI returned invalid ${propertyName}`);
  }

  return color;
}

/** Parses and validates generated nutrition */
export function parseGeneratedNutrition(value: unknown): GeneratedNutrition {
  const nutrition = asRecord(value);

  if (nutrition === null) {
    throw new Error("AI returned invalid nutrition");
  }

  return {
    calories: parseGeneratedNumber(nutrition.calories, "calories"),
    protein: parseGeneratedNumber(nutrition.protein, "protein"),
    carbs: parseGeneratedNumber(nutrition.carbs, "carbs"),
    fat: parseGeneratedNumber(nutrition.fat, "fat"),
  };
}

/** Parses and validates one compact generated food */
export function parseGeneratedFood(value: unknown): GeneratedFood {
  const food = asRecord(value);

  if (food === null) {
    throw new Error("AI returned invalid food data");
  }

  return {
    name: parseGeneratedLocalizedText(food.name, "food name", 500),
    emoji: parseGeneratedString(food.emoji, "food emoji", 32),
    color: parseGeneratedColor(food.color, "food color"),
    quantity: parseGeneratedNumber(food.quantity, "food quantity"),
    unit: parseGeneratedLocalizedText(food.unit, "food unit", 100),
    nutrition: parseGeneratedNutrition(food.nutrition),
  };
}

/** Parses and validates one compact Gemini meal response */
export function parseGeneratedMeal(text: string | undefined): GeneratedMeal {
  if (text === undefined) {
    throw new Error("AI returned no meal data");
  }

  const response = asRecord(JSON.parse(text));
  if (response?.status === "no_food_in_image") {
    throw new NoFoodInImageError("Meal photo contains no recognizable food or drink");
  }

  const meal = response?.status === "meal" ? asRecord(response.meal) : null;

  if (
    meal === null ||
    !Array.isArray(meal.foods) ||
    meal.foods.length > 200
  ) {
    throw new Error("AI returned invalid meal data");
  }

  return {
    name: parseGeneratedLocalizedText(meal.name, "meal name", 500),
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

/** Builds multimodal Gemini content from text and optional inline WebP data */
export function buildMealContentParts(input: MealGenerationInput): Part[] {
  const parts: Part[] = [];

  if (input.text !== null && input.text.length > 0) {
    if (input.text.length > getAIMealDescriptionLimit()) {
      throw new Error("AI meal description exceeds the maximum length");
    }

    parts.push({ text: input.text });
  }

  if (input.imageBase64 !== null && input.imageContentType !== null) {
    parts.push({
      inlineData: {
        mimeType: input.imageContentType,
        data: input.imageBase64,
      },
    });
  }

  if (parts.length === 0) {
    throw new Error("Meal generation requires text or an image");
  }

  return parts;
}

/** Creates a client for the project's global Gemini endpoint */
export function createMealAIClient(): GoogleGenAI {
  const project = getMealAIProjectId();

  if (project === undefined) {
    throw new Error("Firebase project ID is unavailable for meal generation");
  }

  return new GoogleGenAI({
    enterprise: true,
    project,
    location: MEAL_AI_LOCATION,
  });
}

/** Requests and validates one Gemini response, recording usage before discarding it */
export async function generateMealWithModel(
  models: Pick<GoogleGenAI["models"], "generateContent">,
  model: typeof MEAL_AI_PRIMARY_MODEL | typeof MEAL_AI_TEXT_FALLBACK_MODEL,
  input: MealGenerationInput,
  attempt: 1 | 2 = 1,
): Promise<GeneratedMealResult> {
  const parts = buildMealContentParts(input);
  const maxOutputTokens = getAIIntegerSetting("AI_MEAL_MAX_OUTPUT_TOKENS", AI_MEAL_MAX_OUTPUT_TOKENS);
  const start = Date.now();
  let response: GenerateContentResponse | undefined;
  let outcome = "success";
  let httpStatus: number | undefined;

  try {
    response = await models.generateContent({
      model,
      contents: [{ role: "user", parts }],
      config: {
        httpOptions: { retryOptions: { attempts: 1 } },
        systemInstruction: MEAL_SYSTEM_INSTRUCTION,
        responseMimeType: "application/json",
        responseJsonSchema: MEAL_GENERATION_RESPONSE_SCHEMA,
        mediaResolution: MediaResolution.MEDIA_RESOLUTION_MEDIUM,
        thinkingConfig: { thinkingLevel: ThinkingLevel.MINIMAL },
        maxOutputTokens,
      },
    });

    const meal = parseGeneratedMeal(response.text);
    if (input.imageBase64 !== null && meal.foods.length === 0) {
      throw new Error("AI returned an image-based meal without any food or drink items");
    }

    return { meal, modelName: model };
  } catch (error) {
    outcome = error instanceof NoFoodInImageError ? "no-food" : "failed";
    httpStatus = error instanceof ApiError ? error.status : undefined;
    throw error;
  } finally {
    const usage = response?.usageMetadata;
    logger.info("AI meal model attempt", {
      model,
      attempt,
      outcome,
      httpStatus,
      latencyMillis: Date.now() - start,
      hasImage: input.imageBase64 !== null,
      finishReason: response?.candidates?.[0]?.finishReason,
      promptTokenCount: usage?.promptTokenCount,
      cachedContentTokenCount: usage?.cachedContentTokenCount,
      candidatesTokenCount: usage?.candidatesTokenCount,
      thoughtsTokenCount: usage?.thoughtsTokenCount,
      totalTokenCount: usage?.totalTokenCount,
    });
  }
}

/** Uses the meal claim's first slot and reserves another only for a transient fallback */
export async function generateMeal(
  input: MealGenerationInput,
  models: Pick<GoogleGenAI["models"], "generateContent"> = createMealAIClient().models,
  reserveFallback: () => Promise<void> = reserveProjectAICall,
): Promise<GeneratedMealResult> {
  try {
    return await generateMealWithModel(models, MEAL_AI_PRIMARY_MODEL, input);
  } catch (error) {
    if (!(error instanceof ApiError) || !MEAL_AI_RETRYABLE_STATUSES.includes(error.status)) {
      throw error;
    }
  }

  // The alternate model can mistake a caption for food in an unrelated photo
  const fallbackModel = input.imageBase64 === null ? MEAL_AI_TEXT_FALLBACK_MODEL : MEAL_AI_PRIMARY_MODEL;
  await new Promise((resolve) => setTimeout(resolve, 1000 + Math.random() * 500));
  await reserveFallback();
  return generateMealWithModel(models, fallbackModel, input, 2);
}

/** Confirms the decoded bytes contain the WebP file signature */
export function isWebPImage(buffer: Buffer): boolean {
  return buffer.length >= 12 &&
    buffer.subarray(0, 4).toString("ascii") === "RIFF" &&
    buffer.subarray(8, 12).toString("ascii") === "WEBP";
}

/** Decodes and validates optional inline image data from the callable request */
export function parseInlineMealImage(data: Record<string, unknown>): InlineMealImage | null {
  const imageBase64 = data.imageBase64;
  const imageContentType = data.imageContentType;
  const imageBlurHash = data.imageBlurHash;

  if (imageBase64 === null || imageBase64 === undefined) {
    if (imageContentType !== null && imageContentType !== undefined) {
      throw new HttpsError("invalid-argument", "Image content type requires image data");
    }

    return null;
  }

  if (
    typeof imageBase64 !== "string" ||
    imageContentType !== MEAL_IMAGE_CONTENT_TYPE ||
    imageBase64.length > Math.ceil(MAX_INLINE_MEAL_IMAGE_BYTES / 3) * 4 + 4 ||
    (imageBlurHash !== null && imageBlurHash !== undefined &&
      (typeof imageBlurHash !== "string" || imageBlurHash.length > 100))
  ) {
    throw new HttpsError("invalid-argument", "Invalid meal image data");
  }

  const buffer = Buffer.from(imageBase64, "base64");

  if (
    buffer.length === 0 ||
    buffer.length > MAX_INLINE_MEAL_IMAGE_BYTES ||
    !isWebPImage(buffer)
  ) {
    throw new HttpsError("invalid-argument", "Invalid meal image file");
  }

  return {
    buffer,
    base64: imageBase64,
    contentType: MEAL_IMAGE_CONTENT_TYPE,
    blurHash: typeof imageBlurHash === "string" ? imageBlurHash : null,
  };
}

/** Validates the authenticated callable payload */
export function parseAIMealCallableInput(value: unknown): AIMealCallableInput {
  const data = asRecord(value);

  if (data === null) {
    throw new HttpsError("invalid-argument", "AI meal request must be an object");
  }

  const mealId = data.mealId;
  const languageCode = data.languageCode;

  if (
    typeof mealId !== "string" ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(mealId) ||
    (languageCode !== "en" && languageCode !== "hr")
  ) {
    throw new HttpsError("invalid-argument", "Invalid AI meal request");
  }

  return {
    mealId,
    languageCode,
    image: parseInlineMealImage(data),
  };
}

/** Returns a short localized meal error suitable for direct display */
export function getMealGenerationError(languageCode: string): string {
  return languageCode === "en" ?
    "Meal generation failed. Delete it and try again" :
    "Generiranje obroka nije uspjelo. Izbriši ga i pokušaj ponovno";
}

/** Returns the localized error shown when the shared Gemini allowance runs out */
export function getProjectAIUnavailableMessage(languageCode: string): string {
  return languageCode === "en" ?
    "AI is temporarily unavailable. Try again later" :
    "AI je privremeno nedostupan. Pokušaj ponovno kasnije";
}

/** Returns a localized message when the photo contains no recognizable food or drink */
export function getNoFoodInImageError(languageCode: string): string {
  return languageCode === "en" ?
    "No food or drink was recognized in this photo" :
    "Na fotografiji nije prepoznata hrana ni piće";
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

/** Keeps the timestamps needed by both limits and finds when another meal can start */
export function getAIMealQuota(attempts: number[], nowMillis: number): {
  retainedAttempts: number[];
  retryAtMillis: number | null;
} {
  const dayStart = nowMillis - nowMillis % UTC_DAY_MILLIS;
  const minuteCutoff = nowMillis - AI_MEAL_ROLLING_WINDOW_MS;
  const retainedAttempts = attempts.filter((attempt) =>
    attempt >= dayStart || attempt > minuteCutoff,
  );
  const dailyCount = retainedAttempts.filter((attempt) => attempt >= dayStart).length;
  const recentAttempts = retainedAttempts
    .filter((attempt) => attempt > minuteCutoff)
    .sort((first, second) => first - second);

  const dailyLimit = getAIIntegerSetting("AI_MEAL_DAILY_LIMIT", AI_MEAL_DAILY_LIMIT);
  const minuteLimit = getAIIntegerSetting("AI_MEAL_MINUTE_LIMIT", AI_MEAL_MINUTE_LIMIT);
  const dailyRetry = dailyCount >= dailyLimit ? dayStart + UTC_DAY_MILLIS : 0;
  const minuteLimitAttempt = recentAttempts.at(-minuteLimit);
  const minuteRetry = minuteLimitAttempt === undefined ?
    0 : minuteLimitAttempt + AI_MEAL_ROLLING_WINDOW_MS;

  return {
    retainedAttempts,
    retryAtMillis: Math.max(dailyRetry, minuteRetry) || null,
  };
}

/** Claims one meal and reserves both the user quota and the first Gemini call */
export async function claimPendingAIMeal(
  mealReference: DocumentReference<DocumentData>,
  leaseId: string,
  languageCode: AIMealCallableInput["languageCode"],
  hasImage: boolean,
): Promise<AIMealGenerationClaim> {
  const claimReference = getAIMealGenerationClaimReference(mealReference);
  const quotaReference = claimReference.parent.parent!.collection("aiUsage").doc("mealGeneration");

  return mealReference.firestore.runTransaction<AIMealGenerationClaim>(async (transaction) => {
    const mealSnapshot = await transaction.get(mealReference);
    const mealData = mealSnapshot.data();

    if (
      !mealSnapshot.exists ||
      mealData?.isLoading !== true ||
      mealData.methodOfCreation !== "ai"
    ) {
      return {
        status: "not-ready",
      };
    }

    const claimSnapshot = await transaction.get(claimReference);
    const existingExpiration = claimSnapshot.data()?.expiresAt;

    if (
      existingExpiration instanceof Timestamp &&
      existingExpiration.toMillis() > claimSnapshot.readTime.toMillis()
    ) {
      return {
        status: "busy",
      };
    }

    const text = typeof mealData.originalText === "string" ? mealData.originalText.trim() : "";
    const descriptionLimit = getAIMealDescriptionLimit();
    if (text.length > descriptionLimit) {
      const message = languageCode === "en" ?
        `Use at most ${descriptionLimit} characters to describe your meal` :
        `Za opis obroka upotrijebi najviše ${descriptionLimit} znakova`;

      rejectPendingAIMeal(transaction, mealReference, claimSnapshot.exists ? claimReference : null, message);
      return { status: "invalid-input" };
    }

    if (text.length === 0 && !hasImage) {
      rejectPendingAIMeal(
        transaction,
        mealReference,
        claimSnapshot.exists ? claimReference : null,
        getMealGenerationError(languageCode),
      );
      return { status: "invalid-input" };
    }

    const quotaSnapshot = await transaction.get(quotaReference);
    const nowMillis = quotaSnapshot.readTime.toMillis();
    const quota = getAIMealQuota(quotaSnapshot.data()?.attempts ?? [], nowMillis);

    if (quota.retryAtMillis !== null) {
      const message = languageCode === "en" ?
        "AI meal limit reached. Try again later" :
        "Dosegnuto je ograničenje AI obroka. Pokušaj ponovno kasnije";

      rejectPendingAIMeal(transaction, mealReference, claimSnapshot.exists ? claimReference : null, message);

      return {
        status: "rate-limited",
        retryAtMillis: quota.retryAtMillis,
        message,
      };
    }

    const projectRetryAtMillis = await reserveProjectAICallInTransaction(mealReference.firestore, transaction);
    if (projectRetryAtMillis !== null) {
      const message = getProjectAIUnavailableMessage(languageCode);
      rejectPendingAIMeal(transaction, mealReference, claimSnapshot.exists ? claimReference : null, message);
      return {
        status: "project-rate-limited",
        retryAtMillis: projectRetryAtMillis,
        message,
      };
    }

    transaction.set(quotaReference, {
      attempts: [...quota.retainedAttempts, nowMillis],
    });

    transaction.set(claimReference, {
      leaseId,
      claimedAt: quotaSnapshot.readTime,
      expiresAt: Timestamp.fromMillis(
        nowMillis + AI_MEAL_GENERATION_LEASE_DURATION_MS,
      ),
    });

    return {
      status: "claimed",
      text: text || null,
    };
  });
}

/** Finishes a rejected meal and clears any expired claim within the same transaction */
export function rejectPendingAIMeal(
  transaction: Transaction,
  mealReference: DocumentReference<DocumentData>,
  expiredClaimReference: DocumentReference<DocumentData> | null,
  message: string,
): void {
  transaction.update(mealReference, {
    isLoading: false,
    errors: [message],
    aiGenerationLanguage: FieldValue.delete(),
    aiGenerationRequestedAt: FieldValue.delete(),
  });

  if (expiredClaimReference !== null) {
    transaction.delete(expiredClaimReference);
  }
}

/** Writes a terminal meal state only when the caller still owns its lease */
export async function finalizePendingAIMeal(
  mealReference: DocumentReference<DocumentData>,
  leaseId: string,
  updates: DocumentData,
): Promise<boolean> {
  const claimReference = getAIMealGenerationClaimReference(mealReference);

  return mealReference.firestore.runTransaction<boolean>(async (transaction) => {
    const claimSnapshot = await transaction.get(claimReference);

    if (claimSnapshot.data()?.leaseId !== leaseId) {
      return false;
    }

    const mealSnapshot = await transaction.get(mealReference);
    const mealData = mealSnapshot.data();

    if (
      mealSnapshot.exists &&
      mealData?.isLoading === true &&
      mealData.methodOfCreation === "ai"
    ) {
      transaction.update(mealReference, updates);
    }

    transaction.delete(claimReference);
    return mealSnapshot.exists;
  });
}

/** Uploads the image buffer without blocking Gemini generation */
export async function uploadAIMealImage(
  userId: string,
  mealId: string,
  image: InlineMealImage,
): Promise<UploadedMealImage> {
  const storagePath = `users/${userId}/meal-images/${mealId}.webp`;
  const file = getStorage().bucket(APP_STORAGE_BUCKET).file(storagePath);

  await file.save(image.buffer, {
    resumable: false,
    metadata: {
      contentType: image.contentType,
      metadata: {
        // Preserve compatibility with Firebase Storage getDownloadURL on mobile
        firebaseStorageDownloadTokens: randomUUID(),
        mealId,
        userId,
      },
    },
  });

  return {
    storagePath,
    blurHash: image.blurHash,
  };
}

/** Deletes an uploaded image when generation cannot use it */
export async function deleteAIMealImage(storagePath: string): Promise<void> {
  try {
    await getStorage()
      .bucket(APP_STORAGE_BUCKET)
      .file(storagePath)
      .delete({ ignoreNotFound: true });
  } catch (error) {
    // Cleanup must not prevent the meal from reaching its terminal state
    logger.error("Deleting unused AI meal image failed", {
      storagePath,
      error: error instanceof Error ? error.message.slice(0, 900) : "Unknown deletion error",
    });
  }
}

/** Finishes one expired callable request unless it already completed */
export async function failExpiredAIMealRequest(
  mealReference: DocumentReference<DocumentData>,
  cutoff: Timestamp,
): Promise<boolean> {
  const claimReference = getAIMealGenerationClaimReference(mealReference);

  return mealReference.firestore.runTransaction<boolean>(async (transaction) => {
    const mealSnapshot = await transaction.get(mealReference);
    const mealData = mealSnapshot.data();
    const requestedAt = mealData?.aiGenerationRequestedAt;

    if (
      !mealSnapshot.exists ||
      mealData?.isLoading !== true ||
      mealData.methodOfCreation !== "ai" ||
      !(requestedAt instanceof Timestamp) ||
      requestedAt.toMillis() > cutoff.toMillis()
    ) {
      return false;
    }

    transaction.update(mealReference, {
      isLoading: false,
      errors: [getMealGenerationError(mealData.aiGenerationLanguage === "hr" ? "hr" : "en")],
      aiGenerationLanguage: FieldValue.delete(),
      aiGenerationRequestedAt: FieldValue.delete(),
    });
    transaction.delete(claimReference);
    return true;
  });
}

/** Finds and finishes callable requests that remained loading after interruption */
export async function cleanupExpiredAIMealRequests(
  firestore: Firestore,
  now: Date,
): Promise<number> {
  const cutoff = Timestamp.fromMillis(
    now.getTime() - AI_MEAL_REQUEST_TIMEOUT_MS,
  );
  const snapshot = await firestore
    .collectionGroup("meals")
    .where("isLoading", "==", true)
    .where("methodOfCreation", "==", "ai")
    .where("aiGenerationRequestedAt", "<=", cutoff)
    .limit(AI_MEAL_CLEANUP_LIMIT)
    .get();
  const results = await Promise.all(
    snapshot.docs.map((document) => failExpiredAIMealRequest(
      document.ref,
      cutoff,
    )),
  );
  const failedCount = results.filter(Boolean).length;

  if (failedCount > 0) {
    logger.info("Finished abandoned AI meal requests", {
      failedCount,
    });
  }

  return failedCount;
}

/** Generates, uploads, and persists one callable AI meal request */
export async function processCallableAIMeal(
  userId: string,
  value: unknown,
): Promise<AIMealCallableResult> {
  const input = parseAIMealCallableInput(value);
  const mealReference = getFirestore()
    .collection("users")
    .doc(userId)
    .collection("meals")
    .doc(input.mealId);
  const leaseId = randomUUID();
  const claim = await claimPendingAIMeal(
    mealReference,
    leaseId,
    input.languageCode,
    input.image !== null,
  );

  if (claim.status === "busy") {
    return { success: true };
  }

  if (claim.status === "not-ready") {
    throw new HttpsError("failed-precondition", "AI meal is not ready for generation");
  }

  if (claim.status === "rate-limited" || claim.status === "project-rate-limited") {
    throw new HttpsError("resource-exhausted", claim.message, {
      retryAtMillis: claim.retryAtMillis,
      reason: claim.status,
    });
  }

  if (claim.status === "invalid-input") {
    return { success: false };
  }

  const generationPromise = generateMeal({
    text: claim.text,
    imageBase64: input.image?.base64 ?? null,
    imageContentType: input.image?.contentType ?? null,
  });
  const imageUploadPromise = input.image === null ?
    Promise.resolve<UploadedMealImage | null>(null) :
    uploadAIMealImage(userId, input.mealId, input.image);
  const [generationOutcome, imageUploadOutcome] = await Promise.allSettled([
    generationPromise,
    imageUploadPromise,
  ]);

  if (generationOutcome.status === "rejected") {
    if (
      imageUploadOutcome.status === "fulfilled" &&
      imageUploadOutcome.value !== null
    ) {
      await deleteAIMealImage(imageUploadOutcome.value.storagePath);
    }

    const failure = generationOutcome.reason;
    const noFoodInImage = failure instanceof NoFoodInImageError;
    const projectQuotaExceeded = failure instanceof ProjectAIQuotaExceeded;
    if (!noFoodInImage && !projectQuotaExceeded) {
      logger.error("Generating callable AI meal failed", {
        userId,
        mealId: input.mealId,
        errorType: failure instanceof Error ? failure.name : "unknown",
      });
    }

    const message = projectQuotaExceeded ? getProjectAIUnavailableMessage(input.languageCode) :
      noFoodInImage ? getNoFoodInImageError(input.languageCode) :
        getMealGenerationError(input.languageCode);
    await finalizePendingAIMeal(mealReference, leaseId, {
      isLoading: false,
      errors: [message],
      aiGenerationLanguage: FieldValue.delete(),
      aiGenerationRequestedAt: FieldValue.delete(),
    });

    if (projectQuotaExceeded) {
      throw new HttpsError("resource-exhausted", message, {
        retryAtMillis: failure.retryAtMillis,
        reason: "project-rate-limited",
      });
    }
    return { success: false };
  }

  const imageUploadFailed = imageUploadOutcome.status === "rejected";
  const uploadedImage = imageUploadOutcome.status === "fulfilled" ?
    imageUploadOutcome.value :
    null;

  if (imageUploadFailed) {
    logger.error("Uploading callable AI meal image failed", {
      userId,
      mealId: input.mealId,
      error: imageUploadOutcome.reason instanceof Error ?
        imageUploadOutcome.reason.message.slice(0, 900) :
        "Unknown image upload error",
    });
  }

  const finalized = await finalizePendingAIMeal(mealReference, leaseId, {
    ...generationOutcome.value.meal,
    imageStoragePath: uploadedImage?.storagePath ?? null,
    imageBlurHash: uploadedImage?.blurHash ?? null,
    methodOfCreation: generationOutcome.value.modelName,
    isLoading: false,
    errors: imageUploadFailed ? [getMealImageUploadError(input.languageCode)] : null,
    aiGenerationLanguage: FieldValue.delete(),
    aiGenerationRequestedAt: FieldValue.delete(),
  });

  if (!finalized && uploadedImage !== null) {
    await deleteAIMealImage(uploadedImage.storagePath);
  }

  return {
    success: finalized && !imageUploadFailed,
  };
}
