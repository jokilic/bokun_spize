"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.workerUrl = exports.googleAuth = exports.db = exports.dailyMealLimit = exports.modelNames = exports.geminiApiKey = exports.region = void 0;
exports.getWorkerUrl = getWorkerUrl;
exports.enqueueMeal = enqueueMeal;
exports.validateImage = validateImage;
exports.getPromptParts = getPromptParts;
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
const functions_1 = require("firebase-admin/functions");
const storage_1 = require("firebase-admin/storage");
const params_1 = require("firebase-functions/params");
const https_1 = require("firebase-functions/v2/https");
const google_auth_library_1 = require("google-auth-library");
const meal_1 = require("./meal");
(0, app_1.initializeApp)();
exports.region = "europe-west1";
exports.geminiApiKey = (0, params_1.defineSecret)("GEMINI_API_KEY");
exports.modelNames = (0, params_1.defineString)("AI_MEAL_MODELS", {
    default: "gemini-3.5-flash-lite,gemini-3.1-flash-lite,gemini-3.8-flash,gemini-3.7-flash,gemini-3.6-flash,gemini-3.5-flash",
});
exports.dailyMealLimit = (0, params_1.defineInt)("AI_MEAL_DAILY_LIMIT", { default: 50 });
exports.db = (0, firestore_1.getFirestore)();
exports.googleAuth = new google_auth_library_1.GoogleAuth({ scopes: ["https://www.googleapis.com/auth/cloud-platform"] });
// Resolve the deployed second-generation worker URL for authenticated Cloud Tasks delivery
async function getWorkerUrl() {
    if (exports.workerUrl)
        return exports.workerUrl;
    const projectId = await exports.googleAuth.getProjectId();
    const client = await exports.googleAuth.getClient();
    const response = await client.request({
        url: `https://cloudfunctions.googleapis.com/v2/projects/${projectId}/locations/${exports.region}/functions/processAIMeal`,
    });
    const url = response.data.serviceConfig?.uri;
    if (!url)
        throw new Error("AI meal worker URL is unavailable");
    exports.workerUrl = url;
    return url;
}
// Enqueue only the document identity so text and images stay out of task payloads
async function enqueueMeal(identity) {
    const uri = await getWorkerUrl();
    await (0, functions_1.getFunctions)().taskQueue(`locations/${exports.region}/functions/processAIMeal`).enqueue(identity, {
        uri,
        dispatchDeadlineSeconds: 300,
    });
}
// Verify ownership and metadata before accepting an uploaded meal image
async function validateImage(path, userId) {
    if (!(0, meal_1.isOwnedImagePath)(path, userId))
        throw new https_1.HttpsError("permission-denied", "Invalid meal image path");
    const [metadata] = await (0, storage_1.getStorage)().bucket().file(path).getMetadata();
    const extension = path.split(".").at(-1);
    const size = Number(metadata.size);
    if (!Number.isFinite(size) || size <= 0 || size >= meal_1.maxImageBytes || metadata.contentType !== meal_1.imageTypes[extension]) {
        throw new https_1.HttpsError("invalid-argument", "Invalid meal image");
    }
}
// Read the immutable uploaded object into the model's multimodal input
async function getPromptParts(job) {
    const parts = [];
    if (job.input.text)
        parts.push({ text: job.input.text });
    const path = job.input.imageStoragePath;
    if (path) {
        await validateImage(path, job.userId);
        const [bytes] = await (0, storage_1.getStorage)().bucket().file(path).download();
        if (bytes.length >= meal_1.maxImageBytes)
            throw new https_1.HttpsError("invalid-argument", "Meal image is too large");
        parts.push({ inlineData: { mimeType: meal_1.imageTypes[path.split(".").at(-1)], data: bytes.toString("base64") } });
    }
    return parts;
}
//# sourceMappingURL=runtime.js.map