import {randomUUID} from "node:crypto";
import {FieldValue, Firestore, Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {hasExhaustedJob, leaseMilliseconds, matchesInput, MealInput, MealOutcome} from "./meal";

export type JobIdentity = {userId: string; mealId: string};
export type MealJob = JobIdentity & {
  input: MealInput;
  state: "queued" | "processing" | "complete" | "failed" | "cancelled";
  submittedAt: Timestamp;
  nextAttemptAt?: Timestamp;
  leaseToken?: string;
  attempts: number;
};

// Resolve all job paths from the authenticated user and validated meal ID
export function getJobReferences(db: Firestore, identity: JobIdentity) {
  const user = db.collection("users").doc(identity.userId);
  return {
    user,
    job: user.collection("aiMealJobs").doc(identity.mealId),
    meal: user.collection("meals").doc(identity.mealId),
    limit: user.collection("aiMealLimits").doc("daily"),
  };
}

// Commit a durable job and loading meal together before contacting Cloud Tasks
export async function submitMeal(db: Firestore, userId: string, input: MealInput, dailyLimit: number): Promise<void> {
  const refs = getJobReferences(db, {userId, mealId: input.mealId});
  await db.runTransaction(async (transaction) => {
    const [job, user, meal, limit] = await transaction.getAll(refs.job, refs.user, refs.meal, refs.limit);
    if (!user.exists) throw new HttpsError("failed-precondition", "Your account is unavailable");
    if (job.exists) {
      if (!matchesInput(job.data()!.input, input)) {
        throw new HttpsError("already-exists", "This meal ID belongs to another request");
      }
      return;
    }
    if (meal.exists) throw new HttpsError("already-exists", "This meal already exists");
    const now = Timestamp.now();
    const day = now.toDate().toISOString().slice(0, 10);
    const count = limit.data()?.day === day ? Number(limit.data()?.count ?? 0) : 0;
    if (count >= dailyLimit) throw new HttpsError("resource-exhausted", "Daily AI meal limit reached");
    transaction.set(refs.limit, {day, count: count + 1});
    transaction.create(refs.job, {
      userId,
      mealId: input.mealId,
      input,
      state: "queued",
      submittedAt: now,
      nextAttemptAt: Timestamp.fromMillis(now.toMillis() + 60000),
      attempts: 0,
    } satisfies MealJob);
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
export async function claimJob(db: Firestore, identity: JobIdentity): Promise<MealJob | null> {
  const refs = getJobReferences(db, identity);
  return db.runTransaction(async (transaction) => {
    const [snapshot, user, meal] = await transaction.getAll(refs.job, refs.user, refs.meal);
    if (!snapshot.exists) return null;
    const job = snapshot.data() as MealJob;
    if (job.state !== "queued" && job.state !== "processing") return null;
    if (!user.exists || !meal.exists || meal.data()?.isLoading !== true) {
      transaction.update(refs.job, {state: "cancelled", nextAttemptAt: FieldValue.delete(), leaseToken: FieldValue.delete()});
      return null;
    }
    const now = Date.now();
    if (job.state === "processing" && job.nextAttemptAt && job.nextAttemptAt.toMillis() > now) return null;
    if (hasExhaustedJob(job.attempts, job.submittedAt.toMillis(), now)) {
      transaction.update(refs.job, {state: "failed", nextAttemptAt: FieldValue.delete(), leaseToken: FieldValue.delete()});
      transaction.update(refs.meal, {isLoading: false, errors: ["Meal processing timed out. Please add the meal again."]});
      return null;
    }
    const claimed: MealJob = {
      ...job,
      state: "processing",
      attempts: job.attempts + 1,
      leaseToken: randomUUID(),
      nextAttemptAt: Timestamp.fromMillis(now + leaseMilliseconds),
    };
    transaction.set(refs.job, claimed);
    return claimed;
  });
}

// Publish an outcome only while the worker still owns the lease and the meal exists
export async function finishJob(
  db: Firestore,
  job: MealJob,
  outcome: MealOutcome,
): Promise<void> {
  const refs = getJobReferences(db, job);
  await db.runTransaction(async (transaction) => {
    const [snapshot, user, meal] = await transaction.getAll(refs.job, refs.user, refs.meal);
    if (!snapshot.exists || snapshot.data()?.state !== "processing" || snapshot.data()?.leaseToken !== job.leaseToken) return;
    if (!user.exists || !meal.exists || meal.data()?.isLoading !== true) {
      transaction.update(refs.job, {state: "cancelled", nextAttemptAt: FieldValue.delete(), leaseToken: FieldValue.delete()});
      return;
    }
    if (outcome.retry && !hasExhaustedJob(job.attempts, job.submittedAt.toMillis(), Date.now())) {
      transaction.update(refs.job, {
        state: "queued",
        leaseToken: FieldValue.delete(),
        nextAttemptAt: Timestamp.fromMillis(Date.now() + 60000 * job.attempts),
      });
      return;
    }
    transaction.update(refs.job, {
      state: outcome.meal ? "complete" : "failed",
      leaseToken: FieldValue.delete(),
      nextAttemptAt: FieldValue.delete(),
    });
    transaction.update(refs.meal, {
      ...outcome.meal,
      isLoading: false,
      errors: outcome.meal ? null : [outcome.error ?? "Meal processing failed. Please add the meal again."],
    });
  });
}

// Reserve overdue work before enqueueing and expire jobs whose retry budget is exhausted
export async function reserveRecovery(db: Firestore, identity: JobIdentity): Promise<boolean> {
  const refs = getJobReferences(db, identity);
  return db.runTransaction(async (transaction) => {
    const [snapshot, user, meal] = await transaction.getAll(refs.job, refs.user, refs.meal);
    if (!snapshot.exists) return false;
    const job = snapshot.data() as MealJob;
    const now = Date.now();
    if (!job.nextAttemptAt || job.nextAttemptAt.toMillis() > now) return false;
    if (!user.exists || !meal.exists || meal.data()?.isLoading !== true) {
      transaction.update(refs.job, {state: "cancelled", nextAttemptAt: FieldValue.delete(), leaseToken: FieldValue.delete()});
      return false;
    }
    if (hasExhaustedJob(job.attempts, job.submittedAt.toMillis(), now)) {
      transaction.update(refs.job, {state: "failed", nextAttemptAt: FieldValue.delete(), leaseToken: FieldValue.delete()});
      transaction.update(refs.meal, {isLoading: false, errors: ["Meal processing timed out. Please add the meal again."]});
      return false;
    }
    transaction.update(refs.job, {
      state: "queued",
      leaseToken: FieldValue.delete(),
      nextAttemptAt: Timestamp.fromMillis(now + 5 * 60000),
    });
    return true;
  });
}
