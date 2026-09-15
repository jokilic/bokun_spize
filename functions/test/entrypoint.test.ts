import assert from "node:assert/strict";
import {test} from "node:test";

test("function entrypoints load with the installed server SDKs", async () => {
  process.env.FIREBASE_CONFIG = JSON.stringify({projectId: "demo-bokun-spize", storageBucket: "demo-bokun-spize.appspot.com"});
  const functions = await import("../src/index");
  for (const name of ["createAIMeal", "processAIMeal", "recoverAIMeals", "deleteUserAIData"] as const) {
    assert.equal(typeof functions[name], "function");
  }
  // Only trigger exports belong in the entrypoint that Firebase recursively inspects
  assert.deepEqual(Object.keys(functions).filter((name) => name !== "default").sort(), ["createAIMeal", "deleteUserAIData", "processAIMeal", "recoverAIMeals"]);
});
