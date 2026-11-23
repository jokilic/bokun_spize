/**
 * Generates compact localized meals from text and inline images with Gemini
 */

import {GoogleGenAI, Part} from "@google/genai";
import {randomUUID} from "node:crypto";
import {getApp} from "firebase-admin/app";
import {
  DocumentData,
  DocumentReference,
  FieldValue,
  Firestore,
  getFirestore,
  Timestamp,
} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import * as logger from "firebase-functions/logger";
import {HttpsError} from "firebase-functions/v2/https";

import {AI_MODEL_NAMES} from "./daily-summary-ai";

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

/** Transaction result used to coordinate duplicate callable requests */
export interface AIMealGenerationClaim {
  status: "claimed" | "busy" | "not-ready";
  mealData: DocumentData | null;
}

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

/** Inline images are already compressed to WebP by the Flutter app */
export const MEAL_IMAGE_CONTENT_TYPE = "image/webp";

/** Raw image limit leaves room below callable limits after Base64 encoding */
export const MAX_INLINE_MEAL_IMAGE_BYTES = 5 * 1024 * 1024;

/** Lease outlives the function timeout while allowing crashed jobs to recover */
export const AI_MEAL_GENERATION_LEASE_DURATION_MS = 10 * 60 * 1000;

/** Maximum time before an interrupted callable request is marked failed */
export const AI_MEAL_REQUEST_TIMEOUT_MS = 15 * 60 * 1000;

/** Maximum abandoned requests processed by one cleanup occurrence */
export const AI_MEAL_CLEANUP_LIMIT = 200;

/** Instructions preserve extraction while preventing duplicated shared values */
export const MEAL_SYSTEM_INSTRUCTION = `
You will receive text and / or an image describing what the user ate.
Estimate nutrition and extract foods.
If quantity is unclear, make a reasonable estimate.
If nutrition is unknown, estimate based on typical values.
The user's text may be written in any language. Understand it in its original language.
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
    en: {type: "string", description: "English value"},
    hr: {type: "string", description: "Croatian value"},
  },
};

/** Reusable schema for nutrition values */
export const NUTRITION_RESPONSE_SCHEMA: Record<string, unknown> = {
  type: "object",
  propertyOrdering: ["calories", "protein", "carbs", "fat"],
  required: ["calories", "protein", "carbs", "fat"],
  additionalProperties: false,
  properties: {
    calories: {type: "number", description: "Calories in kcal"},
    protein: {type: "number", description: "Protein in g"},
    carbs: {type: "number", description: "Carbs in g"},
    fat: {type: "number", description: "Fat in g"},
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
          quantity: {type: "number", description: "Quantity of food"},
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

/** Parses one complete English and Croatian text pair */
export function parseGeneratedLocalizedText(
  value: unknown,
  propertyName: string,
  maximumLength: number,
): GeneratedLocalizedText {
  const localizedText = asRecord(value);

  if (localizedText === null) {
    throw new Error(`Gemini returned invalid localized ${propertyName}`);
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

/** Parses and validates one compact generated food */
export function parseGeneratedFood(value: unknown): GeneratedFood {
  const food = asRecord(value);

  if (food === null) {
    throw new Error("Gemini returned invalid food data");
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
    parts.push({text: input.text});
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

/** Generates a compact structured meal while falling through models on errors */
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
  const failures: string[] = [];

  for (const model of AI_MODEL_NAMES) {
    try {
      const response = await ai.models.generateContent({
        model,
        contents: [{role: "user", parts}],
        config: {
          systemInstruction: MEAL_SYSTEM_INSTRUCTION,
          responseMimeType: "application/json",
          responseJsonSchema: MEAL_RESPONSE_SCHEMA,
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

/** Atomically claims one loading AI meal or reports an active competing lease */
export async function claimPendingAIMeal(
  mealReference: DocumentReference<DocumentData>,
  leaseId: string,
  now: Date,
): Promise<AIMealGenerationClaim> {
  const claimReference = getAIMealGenerationClaimReference(mealReference);

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
      .delete({ignoreNotFound: true});
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
    new Date(),
  );

  if (claim.status === "busy") {
    return {success: true};
  }

  if (claim.status === "not-ready") {
    throw new HttpsError("failed-precondition", "AI meal is not ready for generation");
  }

  const mealData = claim.mealData!;
  const originalText = typeof mealData.originalText === "string" ? mealData.originalText.trim() : "";
  const generationPromise = generateMeal({
    text: originalText.length > 0 ? originalText : null,
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

    logger.error("Generating callable AI meal failed", {
      userId,
      mealId: input.mealId,
      error: generationOutcome.reason instanceof Error ?
        generationOutcome.reason.message.slice(0, 900) :
        "Unknown meal generation error",
    });

    await finalizePendingAIMeal(mealReference, leaseId, {
      isLoading: false,
      errors: [getMealGenerationError(input.languageCode)],
      aiGenerationLanguage: FieldValue.delete(),
      aiGenerationRequestedAt: FieldValue.delete(),
    });
    return {success: false};
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
