/**
 * Generates short localized daily meal summaries with Gemini
 */

import { GoogleGenAI } from "@google/genai";
import { getApp } from "firebase-admin/app";
import {
  DocumentData,
  Timestamp,
} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

/** Complete Firestore meal record supplied to Gemini */
export interface DailySummaryMeal {
  documentId: string;
  data: DocumentData;
}

/** Localized bodies returned by the structured Gemini response */
export interface GeneratedDailySummaryBodies {
  en: string;
  hr: string;
}

/** Result of a successful daily summary model fallback attempt */
export interface GeneratedDailySummaryResult {
  bodies: GeneratedDailySummaryBodies;
  modelName: string;
}

/** Shared model fallback order used by AI generation */
export const AI_MODEL_NAMES = [
  "gemini-3.5-flash-lite",
  "gemini-3.1-flash-lite",
  "gemini-3.8-flash",
  "gemini-3.7-flash",
  "gemini-3.6-flash",
  "gemini-3.5-flash",
];

/** Global Vertex AI location supports the broadest Gemini model selection */
export const DAILY_SUMMARY_AI_LOCATION = "global";

/** Maximum length kept comfortably inside notification payload limits */
export const DAILY_SUMMARY_BODY_MAX_LENGTH = 400;

/** Output budget leaves room for model reasoning and two complete localized bodies */
export const DAILY_SUMMARY_MAX_OUTPUT_TOKENS = 4096;

/** Instructions keep meal data untrusted and require direct, evidence-based feedback */
export const DAILY_SUMMARY_SYSTEM_INSTRUCTION = `
You're a friendly and direct nutritionist.
You will get meal records from yesterday and your task is to analyse them.

Write a simple summary of meals in English and Croatian, using 3-4 short sentences.
Keep each localized summary at or below 400 characters.
Mention specific meals if you decide it's relevant.

If possible, add a suggestion on how to elevate your meal plan for today, in order to eat healthier.

Regarding Croatian, you can use 'ti', not 'vi' when referring to user.

If completed meal data is insufficient, mention that and encourage meal recording.
`.trim();

/** Structured response prevents model prose from leaking outside the notification fields */
export const DAILY_SUMMARY_RESPONSE_SCHEMA = {
  "type": "object",
  "title": "DailySummary",
  "propertyOrdering": ["en", "hr"],
  "required": ["en", "hr"],
  "additionalProperties": false,
  "properties": {
    "en": {
      "type": "string",
      "description": "English summary using 3-4 short sentences and at most 400 characters",
    },
    "hr": {
      "type": "string",
      "description": "Croatian summary using 3-4 short sentences and at most 400 characters",
    },
  },
};

/** Converts Firestore values into JSON the model can read without losing timestamps */
export function serializeDailySummaryValue(value: unknown): unknown {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (Array.isArray(value)) {
    return value.map(serializeDailySummaryValue);
  }

  if (typeof value === "object" && value !== null) {
    return Object.fromEntries(
      Object.entries(value).map(([key, childValue]) => [
        key,
        serializeDailySummaryValue(childValue),
      ]),
    );
  }

  return value;
}

/** Builds the model prompt from complete meal documents in chronological query order */
export function buildDailySummaryPrompt(meals: DailySummaryMeal[]): string {
  const records = meals.map((meal) => ({
    documentId: meal.documentId,
    ...serializeDailySummaryValue(meal.data) as Record<string, unknown>,
  }));

  return [
    "Create the localized daily summary from these complete meal records:",
    JSON.stringify(records),
  ].join("\n");
}

/** Normalizes and safely shortens one generated body for notification delivery */
export function normalizeDailySummaryBody(value: unknown): string {
  if (typeof value !== "string") {
    return "";
  }

  const normalized = value.replace(/\s+/g, " ").trim();

  if (normalized.length <= DAILY_SUMMARY_BODY_MAX_LENGTH) {
    return normalized;
  }

  const maximumContentLength = DAILY_SUMMARY_BODY_MAX_LENGTH - 1;
  const content = normalized.slice(0, maximumContentLength);
  const finalSpaceIndex = content.lastIndexOf(" ");
  const shortened = finalSpaceIndex > 0 ? content.slice(0, finalSpaceIndex) : content;

  return `${shortened.trimEnd()}…`;
}

/** Validates and normalizes one structured Gemini response */
export function parseDailySummaryResponse(text: string | undefined): GeneratedDailySummaryBodies {
  if (text === undefined) {
    throw new Error("Gemini returned no daily summary text");
  }

  const value: unknown = JSON.parse(text);
  const parsed = typeof value === "object" && value !== null ? value as Record<string, unknown> : {};
  const en = normalizeDailySummaryBody(parsed.en);
  const hr = normalizeDailySummaryBody(parsed.hr);

  if (
    en.length === 0 ||
    hr.length === 0
  ) {
    throw new Error("Gemini returned invalid daily summary bodies");
  }

  return { en, hr };
}

/** Resolves the Google Cloud project in deployed and emulator environments */
export function getDailySummaryProjectId(): string | undefined {
  return getApp().options.projectId ??
    process.env.GOOGLE_CLOUD_PROJECT ??
    process.env.GCLOUD_PROJECT;
}

/** Generates localized notification bodies and reports the successful fallback model */
export async function generateDailySummaryBodies(
  meals: DailySummaryMeal[],
): Promise<GeneratedDailySummaryResult> {
  const project = getDailySummaryProjectId();

  if (project === undefined) {
    throw new Error("Firebase project ID is unavailable for daily summary generation");
  }

  const ai = new GoogleGenAI({
    enterprise: true,
    project,
    location: DAILY_SUMMARY_AI_LOCATION,
  });
  const prompt = buildDailySummaryPrompt(meals);
  const failures: string[] = [];

  for (const model of AI_MODEL_NAMES) {
    try {
      const response = await ai.models.generateContent({
        model,
        contents: prompt,
        config: {
          systemInstruction: DAILY_SUMMARY_SYSTEM_INSTRUCTION,
          responseMimeType: "application/json",
          responseJsonSchema: DAILY_SUMMARY_RESPONSE_SCHEMA,
          temperature: 0.4,
          maxOutputTokens: DAILY_SUMMARY_MAX_OUTPUT_TOKENS,
        },
      });

      return {
        bodies: parseDailySummaryResponse(response.text),
        modelName: model,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown Gemini error";
      failures.push(`${model}: ${message}`);
      logger.warn("Daily summary model failed", {
        model,
        error: message.slice(0, 500),
      });
    }
  }

  throw new Error(`Generating the daily summary failed: ${failures.join(" | ").slice(0, 900)}`);
}
