"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUserAIData = exports.recoverAIMeals = exports.processAIMeal = exports.createAIMeal = void 0;
const genai_1 = require("@google/genai");
const firestore_1 = require("firebase-admin/firestore");
const firebase_functions_1 = require("firebase-functions");
const firestore_2 = require("firebase-functions/v2/firestore");
const https_1 = require("firebase-functions/v2/https");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const tasks_1 = require("firebase-functions/v2/tasks");
const zod_1 = require("zod");
const jobs_1 = require("./jobs");
const meal_1 = require("./meal");
const runtime_1 = require("./runtime");
// Accept authenticated submissions and acknowledge once their durable Firestore job exists
exports.createAIMeal = (0, https_1.onCall)({ region: runtime_1.region, timeoutSeconds: 60, memory: "256MiB", maxInstances: 10 }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError("unauthenticated", "Sign in to add a meal");
    const parsed = meal_1.requestSchema.safeParse(request.data);
    if (!parsed.success)
        throw new https_1.HttpsError("invalid-argument", "Invalid meal request");
    const input = parsed.data;
    const identity = { userId: request.auth.uid, mealId: input.mealId };
    const existing = await (0, jobs_1.getJobReferences)(runtime_1.db, identity).job.get();
    if (existing.exists && !(0, meal_1.matchesInput)(existing.data().input, input)) {
        throw new https_1.HttpsError("already-exists", "This meal ID belongs to another request");
    }
    // A repeated request remains valid even if its image was deleted after completion
    if (!existing.exists && input.imageStoragePath) {
        try {
            await (0, runtime_1.validateImage)(input.imageStoragePath, identity.userId);
        }
        catch (error) {
            if (error instanceof https_1.HttpsError)
                throw error;
            throw new https_1.HttpsError("failed-precondition", "The meal image is unavailable. Please upload it again.");
        }
    }
    await (0, jobs_1.submitMeal)(runtime_1.db, identity.userId, input, runtime_1.dailyMealLimit.value());
    try {
        if (!existing.exists || existing.data()?.state === "queued")
            await (0, runtime_1.enqueueMeal)(identity);
    }
    catch {
        // The scheduled recovery function will enqueue this already committed job
        firebase_functions_1.logger.error("Meal queue submission failed; recovery will retry", identity);
    }
    return { mealId: input.mealId };
});
// Execute bounded model fallbacks and save the terminal result through the owned lease
exports.processAIMeal = (0, tasks_1.onTaskDispatched)({
    region: runtime_1.region,
    timeoutSeconds: 300,
    memory: "512MiB",
    secrets: [runtime_1.geminiApiKey],
    retryConfig: { maxAttempts: 3, minBackoffSeconds: 60, maxBackoffSeconds: 300 },
    rateLimits: { maxConcurrentDispatches: 5, maxDispatchesPerSecond: 2 },
    maxInstances: 5,
    concurrency: 1,
}, async (request) => {
    const identity = zod_1.z.object({ userId: zod_1.z.string().min(1).max(128).regex(/^[^/]+$/), mealId: meal_1.requestSchema.shape.mealId }).strict().parse(request.data);
    const job = await (0, jobs_1.claimJob)(runtime_1.db, identity);
    if (!job)
        return;
    try {
        const parts = await (0, runtime_1.getPromptParts)(job);
        const ai = new genai_1.GoogleGenAI({ apiKey: runtime_1.geminiApiKey.value(), httpOptions: { timeout: 25000, retryOptions: { attempts: 1 } } });
        const models = [...new Set(runtime_1.modelNames.value().split(",").map((name) => name.trim()).filter(Boolean))].slice(0, 6);
        const outcome = await (0, meal_1.generateWithFallback)(models, async (model) => {
            const response = await ai.models.generateContent({
                model,
                contents: [{ role: "user", parts }],
                config: {
                    systemInstruction: (0, meal_1.getSystemInstruction)(job.input.languageCode),
                    responseMimeType: "application/json",
                    responseJsonSchema: zod_1.z.toJSONSchema(meal_1.responseSchema),
                    maxOutputTokens: 8192,
                },
            });
            return response.text ?? "";
        }, (model, status) => firebase_functions_1.logger.warn("Meal model attempt failed", { ...identity, model, status }));
        await (0, jobs_1.finishJob)(runtime_1.db, job, outcome);
    }
    catch (error) {
        const status = Number(error.code);
        const permanent = error instanceof https_1.HttpsError || status === 404;
        firebase_functions_1.logger.error("Meal worker failed", { ...identity, permanent });
        await (0, jobs_1.finishJob)(runtime_1.db, job, { error: "Meal processing failed. Please add the meal again.", retry: !permanent });
    }
});
// Recover missed enqueue operations and expired worker leases without needing the app
exports.recoverAIMeals = (0, scheduler_1.onSchedule)({ region: runtime_1.region, schedule: "every 5 minutes", timeoutSeconds: 300, maxInstances: 1 }, async () => {
    const overdue = await runtime_1.db.collectionGroup("aiMealJobs").where("nextAttemptAt", "<=", firestore_1.Timestamp.now()).orderBy("nextAttemptAt").limit(100).get();
    for (const snapshot of overdue.docs) {
        const identity = snapshot.data();
        try {
            if (await (0, jobs_1.reserveRecovery)(runtime_1.db, identity))
                await (0, runtime_1.enqueueMeal)({ userId: identity.userId, mealId: identity.mealId });
        }
        catch {
            firebase_functions_1.logger.error("Meal recovery failed", { userId: identity.userId, mealId: identity.mealId });
        }
    }
});
// Remove server-only AI records when the existing account deletion flow removes its user document
exports.deleteUserAIData = (0, firestore_2.onDocumentDeleted)({ region: runtime_1.region, document: "users/{userId}", retry: true }, async (event) => {
    const user = runtime_1.db.collection("users").doc(event.params.userId);
    await runtime_1.db.recursiveDelete(user.collection("aiMealJobs"));
    await runtime_1.db.recursiveDelete(user.collection("aiMealLimits"));
});
//# sourceMappingURL=index.js.map