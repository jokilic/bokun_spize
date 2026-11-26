import {randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import type {Auth} from "firebase-admin/auth";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {afterAll, describe, expect, it, vi} from "vitest";
import {
  ACCOUNT_DELETION_JOBS,
  enqueueAccountDeletion,
  hasRecentAuthentication,
  processAccountDeletion,
} from "../src/account-deletion";

/** Exercises the five-minute window against the original authentication time */
it("requires recent authentication", () => {
  const now = 1_000_000;
  expect(hasRecentAuthentication(700, now)).toBe(true);
  expect(hasRecentAuthentication(699, now)).toBe(false);
  expect(hasRecentAuthentication(1001, now)).toBe(false);
});

describe.skipIf(process.env.FIRESTORE_EMULATOR_HOST === undefined)("account deletion queue", () => {
  const app = initializeApp({projectId: "demo-account-deletion"}, "account-deletion-tests");
  const firestore = getFirestore(app);

  /** Releases the emulator client */
  afterAll(async () => {
    await firestore.terminate();
    await deleteApp(app);
  });

  /** Verifies concurrent requests, Auth retries, nested data removal, and resumable storage cleanup */
  it("resumes an interrupted deletion and leaves unrelated data intact", async () => {
    const userId = randomUUID();
    const job = firestore.collection(ACCOUNT_DELETION_JOBS).doc(userId);
    const user = firestore.collection("users").doc(userId);
    const nested = user.collection("mealGenerationClaims").doc("missing-parent").collection("leases").doc("orphan");
    const quota = user.collection("aiUsage").doc("mealGeneration");
    const contact = firestore.collection("contactMessages").doc(userId);
    const unrelated = firestore.collection("contactMessages").doc(randomUUID());
    await Promise.all([
      nested.set({leaseId: "test"}),
      quota.set({attempts: []}),
      contact.set({userUid: userId}),
      unrelated.set({userUid: "another-user"}),
    ]);

    await Promise.all([
      enqueueAccountDeletion(firestore, userId),
      enqueueAccountDeletion(firestore, userId),
    ]);
    const deleteUser = vi.fn().mockRejectedValue(Object.assign(new Error("Already deleted"), {
      code: "auth/user-not-found",
    }));
    const auth = {deleteUser} as unknown as Auth;
    const deleteStorage = vi.fn<(userId: string) => Promise<void>>()
      .mockRejectedValueOnce(new Error("Storage unavailable"))
      .mockResolvedValue(undefined);

    await Promise.all([
      processAccountDeletion(job, auth, deleteStorage),
      processAccountDeletion(job, auth, deleteStorage),
    ]);
    expect(deleteUser).toHaveBeenCalledExactlyOnceWith(userId);
    await enqueueAccountDeletion(firestore, userId, true);
    expect((await job.get()).get("phase")).toBe("clean-data");

    await job.update({nextAttemptAt: Timestamp.fromMillis(0)});
    await expect(processAccountDeletion(job, auth, deleteStorage)).rejects.toThrow("Storage unavailable");
    expect((await nested.get()).exists).toBe(false);
    expect((await quota.get()).exists).toBe(false);
    expect((await contact.get()).exists).toBe(false);
    expect((await unrelated.get()).exists).toBe(true);

    await processAccountDeletion(job, auth, deleteStorage);
    expect(deleteStorage).toHaveBeenCalledTimes(1);
    await job.update({nextAttemptAt: Timestamp.fromMillis(0)});
    await processAccountDeletion(job, auth, deleteStorage);
    expect((await job.get()).get("phase")).toBe("final-sweep");

    await job.update({nextAttemptAt: Timestamp.fromMillis(0)});
    await processAccountDeletion(job, auth, deleteStorage);
    expect(deleteStorage.mock.calls).toEqual([[userId], [userId], [userId]]);
    expect((await job.get()).exists).toBe(false);
    await unrelated.delete();
  }, 30_000);
});
