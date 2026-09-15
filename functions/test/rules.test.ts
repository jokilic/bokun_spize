import assert from "node:assert/strict";
import {randomUUID} from "node:crypto";
import {after, before, test} from "node:test";
import {assertFails, assertSucceeds, initializeTestEnvironment, RulesTestEnvironment} from "@firebase/rules-unit-testing";
import {doc, getDoc, setDoc, updateDoc, deleteDoc} from "firebase/firestore";

export const emulatorAvailable = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
export let environment: RulesTestEnvironment;
export const userId = randomUUID();
export const mealId = randomUUID();
export const mealPath = `users/${userId}/meals/${mealId}`;
export const jobPath = `users/${userId}/aiMealJobs/${mealId}`;
export const meal = {
  id: mealId, name: null, emoji: null, color: null, createdAt: "2026-09-15T12:30:00.000",
  nutrition: null, foods: null, originalText: "Eggs", isLoading: true, errors: null, imageStoragePath: null,
};

before(async () => {
  if (!emulatorAvailable) return;
  const [host, port] = process.env.FIRESTORE_EMULATOR_HOST!.split(":");
  environment = await initializeTestEnvironment({projectId: "demo-bokun-spize", firestore: {host, port: Number(port)}});
});

after(async () => {
  if (environment) await environment.cleanup();
});

test("owners can create manual meals but cannot alter active AI meals or server records", {skip: !emulatorAvailable}, async () => {
  const owner = environment.authenticatedContext(userId).firestore();
  const outsider = environment.authenticatedContext("another-user").firestore();
  await assertSucceeds(setDoc(doc(owner, mealPath), meal));
  await assertSucceeds(updateDoc(doc(owner, mealPath), {isLoading: false, name: "Manual meal"}));
  await assertFails(getDoc(doc(outsider, mealPath)));
  await assertFails(setDoc(doc(owner, jobPath), {state: "complete"}));
  await assertFails(setDoc(doc(owner, `users/${userId}/aiMealLimits/daily`), {count: 0}));
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), jobPath), {state: "queued"});
    await updateDoc(doc(context.firestore(), mealPath), {isLoading: true});
  });
  await assertSucceeds(getDoc(doc(owner, mealPath)));
  await assertFails(getDoc(doc(owner, jobPath)));
  await assertFails(updateDoc(doc(owner, mealPath), {name: "Overwrite AI input"}));
  await assertSucceeds(deleteDoc(doc(owner, mealPath)));
  await assertFails(setDoc(doc(owner, mealPath), meal));
});

test("completed AI meals remain editable but deleted IDs cannot be recreated", {skip: !emulatorAvailable}, async () => {
  const owner = environment.authenticatedContext(userId).firestore();
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), jobPath), {state: "complete"});
    await setDoc(doc(context.firestore(), mealPath), {...meal, isLoading: false});
  });
  await assertSucceeds(updateDoc(doc(owner, mealPath), {name: "Edited meal"}));
  assert.equal((await getDoc(doc(owner, mealPath))).data()?.name, "Edited meal");
  await assertSucceeds(deleteDoc(doc(owner, mealPath)));
  await assertFails(setDoc(doc(owner, mealPath), meal));
});
