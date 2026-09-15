import assert from "node:assert/strict";
import {randomUUID} from "node:crypto";
import {after, test} from "node:test";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {claimJob, finishJob, getJobReferences, reserveRecovery, submitMeal} from "../src/jobs";
import {MealInput, maxJobAgeMilliseconds, parseGeneratedMeal} from "../src/meal";

export const emulatorAvailable = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
export const app = emulatorAvailable ? initializeApp({projectId: "demo-bokun-spize"}, "job-tests") : null;
export const db = app ? getFirestore(app) : null;
export const users: string[] = [];

// Create an isolated account and request for each state-transition test
export async function createFixture() {
  const userId = randomUUID();
  const input: MealInput = {
    mealId: randomUUID(), text: "Two eggs", imageStoragePath: null,
    createdAt: "2026-09-15T12:30:00.000", languageCode: "hr",
  };
  users.push(userId);
  const identity = {userId, mealId: input.mealId};
  const refs = getJobReferences(db!, identity);
  await refs.user.set({name: "Test"});
  return {userId, input, identity, refs};
}

after(async () => {
  for (const userId of users) await db!.recursiveDelete(db!.collection("users").doc(userId));
  if (app) await deleteApp(app);
});

test("concurrent duplicate submissions create one job and charge quota once", {skip: !emulatorAvailable}, async () => {
  const {userId, input, refs} = await createFixture();
  await Promise.all([submitMeal(db!, userId, input, 1), submitMeal(db!, userId, input, 1)]);
  assert.equal((await refs.limit.get()).data()?.count, 1);
  assert.equal((await refs.meal.get()).data()?.isLoading, true);
  await assert.rejects(submitMeal(db!, userId, {...input, text: "Other food"}, 1), {code: "already-exists"});
  await assert.rejects(submitMeal(db!, userId, {...input, mealId: randomUUID()}, 1), {code: "resource-exhausted"});
});

test("duplicate deliveries claim one lease and success updates the existing meal", {skip: !emulatorAvailable}, async () => {
  const {userId, input, identity, refs} = await createFixture();
  await submitMeal(db!, userId, input, 50);
  const claims = await Promise.all([claimJob(db!, identity), claimJob(db!, identity)]);
  assert.equal(claims.filter(Boolean).length, 1);
  const meal = parseGeneratedMeal(JSON.stringify({meal: {
    name: "Eggs", emoji: "🥚", color: "#FFFFFF", nutrition: {calories: 140, protein: 12, carbs: 1, fat: 10},
    foods: [{name: "Eggs", quantity: 2, unit: "piece", nutrition: {calories: 140, protein: 12, carbs: 1, fat: 10}}],
  }}))!;
  await finishJob(db!, claims.find(Boolean)!, {meal});
  assert.equal((await refs.meal.get()).data()?.name, "Eggs");
  assert.equal((await refs.meal.get()).data()?.isLoading, false);
  assert.equal((await refs.job.get()).data()?.nextAttemptAt, undefined);
  assert.equal(await claimJob(db!, identity), null);
});

test("deletion during processing never restores the meal or reuses its ID", {skip: !emulatorAvailable}, async () => {
  const {userId, input, identity, refs} = await createFixture();
  await submitMeal(db!, userId, input, 50);
  const job = await claimJob(db!, identity);
  await refs.meal.delete();
  await finishJob(db!, job!, {error: "Test failure"});
  await submitMeal(db!, userId, input, 50);
  assert.equal((await refs.meal.get()).exists, false);
  assert.equal((await refs.job.get()).data()?.state, "cancelled");
});

test("expired leases recover and old workers cannot overwrite a newer outcome", {skip: !emulatorAvailable}, async () => {
  const {userId, input, identity, refs} = await createFixture();
  await submitMeal(db!, userId, input, 50);
  const oldJob = await claimJob(db!, identity);
  await refs.job.update({nextAttemptAt: Timestamp.fromMillis(Date.now() - 1000)});
  assert.equal(await reserveRecovery(db!, identity), true);
  const newJob = await claimJob(db!, identity);
  await finishJob(db!, oldJob!, {error: "Stale failure"});
  assert.equal((await refs.meal.get()).data()?.isLoading, true);
  await finishJob(db!, newJob!, {error: "Current failure"});
  assert.deepEqual((await refs.meal.get()).data()?.errors, ["Current failure"]);
});

test("recovery handles missing enqueue and eventually finishes jobs after the retry limit", {skip: !emulatorAvailable}, async () => {
  const {userId, input, identity, refs} = await createFixture();
  await submitMeal(db!, userId, input, 50);
  for (let attempt = 1; attempt <= 3; attempt++) {
    await refs.job.update({nextAttemptAt: Timestamp.fromMillis(Date.now() - 1000)});
    assert.equal(await reserveRecovery(db!, identity), true);
    const job = await claimJob(db!, identity);
    assert.equal(job?.attempts, attempt);
    await finishJob(db!, job!, {error: "Provider unavailable", retry: true});
  }
  assert.equal((await refs.job.get()).data()?.state, "failed");
  assert.equal((await refs.meal.get()).data()?.isLoading, false);
});

test("jobs that never reach a worker expire and deleted accounts cannot submit", {skip: !emulatorAvailable}, async () => {
  const {userId, input, identity, refs} = await createFixture();
  await submitMeal(db!, userId, input, 50);
  await refs.job.update({submittedAt: Timestamp.fromMillis(Date.now() - maxJobAgeMilliseconds - 1000), nextAttemptAt: Timestamp.fromMillis(0)});
  assert.equal(await reserveRecovery(db!, identity), false);
  assert.equal((await refs.meal.get()).data()?.isLoading, false);
  await refs.user.delete();
  await assert.rejects(submitMeal(db!, userId, {...input, mealId: randomUUID()}, 50), {code: "failed-precondition"});
});
