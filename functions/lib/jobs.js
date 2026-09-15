"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getJobReferences = getJobReferences;
exports.submitMeal = submitMeal;
exports.claimJob = claimJob;
exports.finishJob = finishJob;
exports.reserveRecovery = reserveRecovery;
const node_crypto_1 = require("node:crypto");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const meal_1 = require("./meal");
// Resolve all job paths from the authenticated user and validated meal ID
function getJobReferences(db, identity) {
    const user = db.collection("users").doc(identity.userId);
    return {
        user,
        job: user.collection("aiMealJobs").doc(identity.mealId),
        meal: user.collection("meals").doc(identity.mealId),
        limit: user.collection("aiMealLimits").doc("daily"),
    };
}
// Commit a durable job and loading meal together before contacting Cloud Tasks
async function submitMeal(db, userId, input, dailyLimit) {
    const refs = getJobReferences(db, { userId, mealId: input.mealId });
    await db.runTransaction(async (transaction) => {
        const [job, user, meal, limit] = await transaction.getAll(refs.job, refs.user, refs.meal, refs.limit);
        if (!user.exists)
            throw new https_1.HttpsError("failed-precondition", "Your account is unavailable");
        if (job.exists) {
            if (!(0, meal_1.matchesInput)(job.data().input, input)) {
                throw new https_1.HttpsError("already-exists", "This meal ID belongs to another request");
            }
            return;
        }
        if (meal.exists)
            throw new https_1.HttpsError("already-exists", "This meal already exists");
        const now = firestore_1.Timestamp.now();
        const day = now.toDate().toISOString().slice(0, 10);
        const count = limit.data()?.day === day ? Number(limit.data()?.count ?? 0) : 0;
        if (count >= dailyLimit)
            throw new https_1.HttpsError("resource-exhausted", "Daily AI meal limit reached");
        transaction.set(refs.limit, { day, count: count + 1 });
        transaction.create(refs.job, {
            userId,
            mealId: input.mealId,
            input,
            state: "queued",
            submittedAt: now,
            nextAttemptAt: firestore_1.Timestamp.fromMillis(now.toMillis() + 60000),
            attempts: 0,
        });
        transaction.create(refs.meal, {
            id: input.mealId,
            name: null,
            emoji: null,
            color: null,
            createdAt: input.createdAt,
            nutrition: null,
            foods: null,
            originalText: input.text,
            isLoading: true,
            errors: null,
            imageStoragePath: input.imageStoragePath,
        });
    });
}
// Claim a timed lease so duplicate queue deliveries cannot run the same attempt
async function claimJob(db, identity) {
    const refs = getJobReferences(db, identity);
    return db.runTransaction(async (transaction) => {
        const [snapshot, user, meal] = await transaction.getAll(refs.job, refs.user, refs.meal);
        if (!snapshot.exists)
            return null;
        const job = snapshot.data();
        if (job.state !== "queued" && job.state !== "processing")
            return null;
        if (!user.exists || !meal.exists || meal.data()?.isLoading !== true) {
            transaction.update(refs.job, { state: "cancelled", nextAttemptAt: firestore_1.FieldValue.delete(), leaseToken: firestore_1.FieldValue.delete() });
            return null;
        }
        const now = Date.now();
        if (job.state === "processing" && job.nextAttemptAt && job.nextAttemptAt.toMillis() > now)
            return null;
        if ((0, meal_1.hasExhaustedJob)(job.attempts, job.submittedAt.toMillis(), now)) {
            transaction.update(refs.job, { state: "failed", nextAttemptAt: firestore_1.FieldValue.delete(), leaseToken: firestore_1.FieldValue.delete() });
            transaction.update(refs.meal, { isLoading: false, errors: ["Meal processing timed out. Please add the meal again."] });
            return null;
        }
        const claimed = {
            ...job,
            state: "processing",
            attempts: job.attempts + 1,
            leaseToken: (0, node_crypto_1.randomUUID)(),
            nextAttemptAt: firestore_1.Timestamp.fromMillis(now + meal_1.leaseMilliseconds),
        };
        transaction.set(refs.job, claimed);
        return claimed;
    });
}
// Publish an outcome only while the worker still owns the lease and the meal exists
async function finishJob(db, job, outcome) {
    const refs = getJobReferences(db, job);
    await db.runTransaction(async (transaction) => {
        const [snapshot, user, meal] = await transaction.getAll(refs.job, refs.user, refs.meal);
        if (!snapshot.exists || snapshot.data()?.state !== "processing" || snapshot.data()?.leaseToken !== job.leaseToken)
            return;
        if (!user.exists || !meal.exists || meal.data()?.isLoading !== true) {
            transaction.update(refs.job, { state: "cancelled", nextAttemptAt: firestore_1.FieldValue.delete(), leaseToken: firestore_1.FieldValue.delete() });
            return;
        }
        if (outcome.retry && !(0, meal_1.hasExhaustedJob)(job.attempts, job.submittedAt.toMillis(), Date.now())) {
            transaction.update(refs.job, {
                state: "queued",
                leaseToken: firestore_1.FieldValue.delete(),
                nextAttemptAt: firestore_1.Timestamp.fromMillis(Date.now() + 60000 * job.attempts),
            });
            return;
        }
        transaction.update(refs.job, {
            state: outcome.meal ? "complete" : "failed",
            leaseToken: firestore_1.FieldValue.delete(),
            nextAttemptAt: firestore_1.FieldValue.delete(),
        });
        transaction.update(refs.meal, {
            ...outcome.meal,
            isLoading: false,
            errors: outcome.meal ? null : [outcome.error ?? "Meal processing failed. Please add the meal again."],
        });
    });
}
// Reserve overdue work before enqueueing and expire jobs whose retry budget is exhausted
async function reserveRecovery(db, identity) {
    const refs = getJobReferences(db, identity);
    return db.runTransaction(async (transaction) => {
        const [snapshot, user, meal] = await transaction.getAll(refs.job, refs.user, refs.meal);
        if (!snapshot.exists)
            return false;
        const job = snapshot.data();
        const now = Date.now();
        if (!job.nextAttemptAt || job.nextAttemptAt.toMillis() > now)
            return false;
        if (!user.exists || !meal.exists || meal.data()?.isLoading !== true) {
            transaction.update(refs.job, { state: "cancelled", nextAttemptAt: firestore_1.FieldValue.delete(), leaseToken: firestore_1.FieldValue.delete() });
            return false;
        }
        if ((0, meal_1.hasExhaustedJob)(job.attempts, job.submittedAt.toMillis(), now)) {
            transaction.update(refs.job, { state: "failed", nextAttemptAt: firestore_1.FieldValue.delete(), leaseToken: firestore_1.FieldValue.delete() });
            transaction.update(refs.meal, { isLoading: false, errors: ["Meal processing timed out. Please add the meal again."] });
            return false;
        }
        transaction.update(refs.job, {
            state: "queued",
            leaseToken: firestore_1.FieldValue.delete(),
            nextAttemptAt: firestore_1.Timestamp.fromMillis(now + 5 * 60000),
        });
        return true;
    });
}
//# sourceMappingURL=jobs.js.map