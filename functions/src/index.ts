import {GoogleGenAI} from "@google/genai";
import {Timestamp} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {onDocumentDeleted} from "firebase-functions/v2/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onTaskDispatched} from "firebase-functions/v2/tasks";
import {z} from "zod";
import {claimJob, finishJob, getJobReferences, JobIdentity, reserveRecovery, submitMeal} from "./jobs";
import {generateWithFallback, getSystemInstruction, matchesInput, requestSchema, responseSchema} from "./meal";
import {dailyMealLimit, db, enqueueMeal, geminiApiKey, getPromptParts, modelNames, region, validateImage} from "./runtime";

// Accept authenticated submissions and acknowledge once their durable Firestore job exists
export const createAIMeal = onCall({region, timeoutSeconds: 60, memory: "256MiB", maxInstances: 10}, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to add a meal");
  const parsed = requestSchema.safeParse(request.data);
  if (!parsed.success) throw new HttpsError("invalid-argument", "Invalid meal request");
  const input = parsed.data;
  const identity = {userId: request.auth.uid, mealId: input.mealId};
  const existing = await getJobReferences(db, identity).job.get();
  if (existing.exists && !matchesInput(existing.data()!.input, input)) {
    throw new HttpsError("already-exists", "This meal ID belongs to another request");
  }
  // A repeated request remains valid even if its image was deleted after completion
  if (!existing.exists && input.imageStoragePath) {
    try {
      await validateImage(input.imageStoragePath, identity.userId);
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      throw new HttpsError("failed-precondition", "The meal image is unavailable. Please upload it again.");
    }
  }
  await submitMeal(db, identity.userId, input, dailyMealLimit.value());
  try {
    if (!existing.exists || existing.data()?.state === "queued") await enqueueMeal(identity);
  } catch {
    // The scheduled recovery function will enqueue this already committed job
    logger.error("Meal queue submission failed; recovery will retry", identity);
  }
  return {mealId: input.mealId};
});

// Execute bounded model fallbacks and save the terminal result through the owned lease
export const processAIMeal = onTaskDispatched({
  region,
  timeoutSeconds: 300,
  memory: "512MiB",
  secrets: [geminiApiKey],
  retryConfig: {maxAttempts: 3, minBackoffSeconds: 60, maxBackoffSeconds: 300},
  rateLimits: {maxConcurrentDispatches: 5, maxDispatchesPerSecond: 2},
  maxInstances: 5,
  concurrency: 1,
}, async (request) => {
  const identity = z.object({userId: z.string().min(1).max(128).regex(/^[^/]+$/), mealId: requestSchema.shape.mealId}).strict().parse(request.data);
  const job = await claimJob(db, identity);
  if (!job) return;
  try {
    const parts = await getPromptParts(job);
    const ai = new GoogleGenAI({apiKey: geminiApiKey.value(), httpOptions: {timeout: 25000, retryOptions: {attempts: 1}}});
    const models = [...new Set(modelNames.value().split(",").map((name) => name.trim()).filter(Boolean))].slice(0, 6);
    const outcome = await generateWithFallback(
      models,
      async (model) => {
        const response = await ai.models.generateContent({
          model,
          contents: [{role: "user", parts}],
          config: {
            systemInstruction: getSystemInstruction(job.input.languageCode),
            responseMimeType: "application/json",
            responseJsonSchema: z.toJSONSchema(responseSchema),
            maxOutputTokens: 8192,
          },
        });
        return response.text ?? "";
      },
      (model, status) => logger.warn("Meal model attempt failed", {...identity, model, status}),
    );
    await finishJob(db, job, outcome);
  } catch (error) {
    const status = Number((error as {code?: number}).code);
    const permanent = error instanceof HttpsError || status === 404;
    logger.error("Meal worker failed", {...identity, permanent});
    await finishJob(db, job, {error: "Meal processing failed. Please add the meal again.", retry: !permanent});
  }
});

// Recover missed enqueue operations and expired worker leases without needing the app
export const recoverAIMeals = onSchedule({region, schedule: "every 5 minutes", timeoutSeconds: 300, maxInstances: 1}, async () => {
  const overdue = await db.collectionGroup("aiMealJobs").where("nextAttemptAt", "<=", Timestamp.now()).orderBy("nextAttemptAt").limit(100).get();
  for (const snapshot of overdue.docs) {
    const identity = snapshot.data() as JobIdentity;
    try {
      if (await reserveRecovery(db, identity)) await enqueueMeal({userId: identity.userId, mealId: identity.mealId});
    } catch {
      logger.error("Meal recovery failed", {userId: identity.userId, mealId: identity.mealId});
    }
  }
});

// Remove server-only AI records when the existing account deletion flow removes its user document
export const deleteUserAIData = onDocumentDeleted({region, document: "users/{userId}", retry: true}, async (event) => {
  const user = db.collection("users").doc(event.params.userId);
  await db.recursiveDelete(user.collection("aiMealJobs"));
  await db.recursiveDelete(user.collection("aiMealLimits"));
});
