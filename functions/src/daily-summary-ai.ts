/**
 * Generates short localized daily meal summaries with Gemini
 */

import { GoogleGenAI } from "@google/genai";
import { getApp } from "firebase-admin/app";
import {
  DocumentData,
  Firestore,
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

/** Resolved remote configuration used for daily summary generation */
export interface DailySummaryAIConfiguration {
  modelNames: string[];
  dailySummarySystemInstruction: string;
  dailySummaryResponseSchema: Record<string, unknown>;
}

/** Shared model fallback used when config/ai/modelNames is unavailable */
export const DEFAULT_AI_MODEL_NAMES = [
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

/** Instructions keep meal data untrusted and require direct, evidence-based feedback */
export const DAILY_SUMMARY_SYSTEM_INSTRUCTION = `
Analyze supplied meal records from yesterday.
Write a direct, honest and simple summary of meals in English and Croatian, using a couple sentences.

Regarding Croatian, you can use 'ti', not 'vi' when referring to user.

If completed meal data is insufficient, say that briefly and encourage meal recording.
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
      "description": "Couple English sentences with direct, honest and simple summary of meals and a practical suggestion for the next day",
      "maxLength": 400
    },
    "hr": {
      "type": "string",
      "description": "Couple Croatian sentences with direct, honest and simple summary of meals and a practical suggestion for the next day",
      "maxLength": 400
    }
  }
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

/** Parses configured model names and falls back when the field is unusable */
export function parseDailySummaryModelNames(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return DEFAULT_AI_MODEL_NAMES;
  }

  const modelNames = value
    .filter((name: unknown): name is string => typeof name === "string")
    .map((name) => name.trim())
    .filter((name) => name.length > 0);

  return modelNames.length > 0 ? [...new Set(modelNames)] : DEFAULT_AI_MODEL_NAMES;
}

/** Parses the daily summary system instruction with its source-controlled fallback */
export function parseDailySummarySystemInstruction(value: unknown): string {
  return typeof value === "string" && value.trim().length > 0 ?
    value.trim() :
    DAILY_SUMMARY_SYSTEM_INSTRUCTION;
}

/** Decodes and validates the configurable daily summary JSON response schema */
export function parseDailySummaryResponseSchema(
  value: unknown,
): Record<string, unknown> {
  try {
    const decoded: unknown = typeof value === "string" ? JSON.parse(value) : value;

    if (
      typeof decoded !== "object" ||
      decoded === null ||
      Array.isArray(decoded)
    ) {
      return DAILY_SUMMARY_RESPONSE_SCHEMA;
    }

    const schema = decoded as Record<string, unknown>;
    const properties = schema.properties;
    const required = schema.required;

    if (
      schema.type !== "object" ||
      typeof properties !== "object" ||
      properties === null ||
      Array.isArray(properties) ||
      !Array.isArray(required) ||
      !required.includes("en") ||
      !required.includes("hr")
    ) {
      return DAILY_SUMMARY_RESPONSE_SCHEMA;
    }

    const propertyMap = properties as Record<string, unknown>;
    const en = propertyMap.en;
    const hr = propertyMap.hr;

    if (
      typeof en !== "object" ||
      en === null ||
      Array.isArray(en) ||
      (en as Record<string, unknown>).type !== "string" ||
      typeof hr !== "object" ||
      hr === null ||
      Array.isArray(hr) ||
      (hr as Record<string, unknown>).type !== "string"
    ) {
      return DAILY_SUMMARY_RESPONSE_SCHEMA;
    }

    return schema;
  } catch (error) {
    logger.warn("Daily summary response schema is invalid", {
      error: error instanceof Error ?
        error.message.slice(0, 500) :
        "Unknown schema error",
    });
    return DAILY_SUMMARY_RESPONSE_SCHEMA;
  }
}

/** Loads daily summary AI settings from config/ai with independent field fallbacks */
export async function getDailySummaryAIConfiguration(
  firestore: Firestore,
): Promise<DailySummaryAIConfiguration> {
  try {
    const snapshot = await firestore.doc("config/ai").get();
    const data = snapshot.data();

    return {
      modelNames: parseDailySummaryModelNames(data?.modelNames),
      dailySummarySystemInstruction: parseDailySummarySystemInstruction(
        data?.dailySummarySystemInstruction,
      ),
      dailySummaryResponseSchema: parseDailySummaryResponseSchema(
        data?.dailySummaryResponseSchema,
      ),
    };
  } catch (error) {
    logger.warn("Loading daily summary AI configuration failed", {
      error: error instanceof Error ?
        error.message.slice(0, 500) :
        "Unknown Firestore error",
    });

    return {
      modelNames: DEFAULT_AI_MODEL_NAMES,
      dailySummarySystemInstruction: DAILY_SUMMARY_SYSTEM_INSTRUCTION,
      dailySummaryResponseSchema: DAILY_SUMMARY_RESPONSE_SCHEMA,
    };
  }
}

/** Validates and normalizes one structured Gemini response */
export function parseDailySummaryResponse(text: string | undefined): GeneratedDailySummaryBodies {
  if (text === undefined) {
    throw new Error("Gemini returned no daily summary text");
  }

  const value: unknown = JSON.parse(text);
  const parsed = typeof value === "object" && value !== null ? value as Record<string, unknown> : {};
  const en = typeof parsed.en === "string" ? parsed.en.replace(/\s+/g, " ").trim() : "";
  const hr = typeof parsed.hr === "string" ? parsed.hr.replace(/\s+/g, " ").trim() : "";

  if (
    en.length === 0 ||
    hr.length === 0 ||
    en.length > DAILY_SUMMARY_BODY_MAX_LENGTH ||
    hr.length > DAILY_SUMMARY_BODY_MAX_LENGTH
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

/** Generates localized notification bodies, falling through configured models on errors */
export async function generateDailySummaryBodies(
  firestore: Firestore,
  meals: DailySummaryMeal[],
): Promise<GeneratedDailySummaryBodies> {
  const project = getDailySummaryProjectId();

  if (project === undefined) {
    throw new Error("Firebase project ID is unavailable for daily summary generation");
  }

  const ai = new GoogleGenAI({
    enterprise: true,
    project,
    location: DAILY_SUMMARY_AI_LOCATION,
  });
  const configuration = await getDailySummaryAIConfiguration(firestore);
  const prompt = buildDailySummaryPrompt(meals);
  const failures: string[] = [];

  for (const model of configuration.modelNames) {
    try {
      const response = await ai.models.generateContent({
        model,
        contents: prompt,
        config: {
          systemInstruction: configuration.dailySummarySystemInstruction,
          responseMimeType: "application/json",
          responseJsonSchema: configuration.dailySummaryResponseSchema,
          temperature: 0.4,
          maxOutputTokens: 512,
        },
      });

      return parseDailySummaryResponse(response.text);
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
