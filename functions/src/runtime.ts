import {Part} from "@google/genai";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getFunctions} from "firebase-admin/functions";
import {getStorage} from "firebase-admin/storage";
import {defineInt, defineSecret, defineString} from "firebase-functions/params";
import {HttpsError} from "firebase-functions/v2/https";
import {GoogleAuth} from "google-auth-library";
import {JobIdentity, MealJob} from "./jobs";
import {imageTypes, isOwnedImagePath, maxImageBytes} from "./meal";

initializeApp();

export const region = "europe-west1";
export const geminiApiKey = defineSecret("GEMINI_API_KEY");
export const modelNames = defineString("AI_MEAL_MODELS", {
  default: "gemini-3.5-flash-lite,gemini-3.1-flash-lite,gemini-3.8-flash,gemini-3.7-flash,gemini-3.6-flash,gemini-3.5-flash",
});
export const dailyMealLimit = defineInt("AI_MEAL_DAILY_LIMIT", {default: 50});
export const db = getFirestore();
export const googleAuth = new GoogleAuth({scopes: ["https://www.googleapis.com/auth/cloud-platform"]});
export let workerUrl: string | undefined;

// Resolve the deployed second-generation worker URL for authenticated Cloud Tasks delivery
export async function getWorkerUrl(): Promise<string> {
  if (workerUrl) return workerUrl;
  const projectId = await googleAuth.getProjectId();
  const client = await googleAuth.getClient();
  const response = await client.request<{serviceConfig?: {uri?: string}}>({
    url: `https://cloudfunctions.googleapis.com/v2/projects/${projectId}/locations/${region}/functions/processAIMeal`,
  });
  const url = response.data.serviceConfig?.uri;
  if (!url) throw new Error("AI meal worker URL is unavailable");
  workerUrl = url;
  return url;
}

// Enqueue only the document identity so text and images stay out of task payloads
export async function enqueueMeal(identity: JobIdentity): Promise<void> {
  const uri = await getWorkerUrl();
  await getFunctions().taskQueue(`locations/${region}/functions/processAIMeal`).enqueue(identity, {
    uri,
    dispatchDeadlineSeconds: 300,
  });
}

// Verify ownership and metadata before accepting an uploaded meal image
export async function validateImage(path: string, userId: string): Promise<void> {
  if (!isOwnedImagePath(path, userId)) throw new HttpsError("permission-denied", "Invalid meal image path");
  const [metadata] = await getStorage().bucket().file(path).getMetadata();
  const extension = path.split(".").at(-1)!;
  const size = Number(metadata.size);
  if (!Number.isFinite(size) || size <= 0 || size >= maxImageBytes || metadata.contentType !== imageTypes[extension]) {
    throw new HttpsError("invalid-argument", "Invalid meal image");
  }
}

// Read the immutable uploaded object into the model's multimodal input
export async function getPromptParts(job: MealJob): Promise<Part[]> {
  const parts: Part[] = [];
  if (job.input.text) parts.push({text: job.input.text});
  const path = job.input.imageStoragePath;
  if (path) {
    await validateImage(path, job.userId);
    const [bytes] = await getStorage().bucket().file(path).download();
    if (bytes.length >= maxImageBytes) throw new HttpsError("invalid-argument", "Meal image is too large");
    parts.push({inlineData: {mimeType: imageTypes[path.split(".").at(-1)!], data: bytes.toString("base64")}});
  }
  return parts;
}

