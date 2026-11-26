/** Queues and resumes account deletion independently of the requesting device */

import type {Auth} from "firebase-admin/auth";
import {type DocumentReference, type Firestore, Timestamp} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

export const ACCOUNT_DELETION_JOBS = "accountDeletionJobs";
export const RECENT_AUTH_SECONDS = 5 * 60;
export const DELETION_DRAIN_MS = 5 * 60 * 1000;
export const DELETION_LEASE_MS = 10 * 60 * 1000;
export const FINAL_STORAGE_SWEEP_MS = 8 * 24 * 60 * 60 * 1000;

export type AccountDeletionPhase = "delete-auth" | "clean-data" | "final-sweep";

/** Validates the actual sign-in time rather than the token refresh time */
export function hasRecentAuthentication(authTime: number, now = Date.now()): boolean {
  const age = Math.floor(now / 1000) - authTime;
  return age >= 0 && age <= RECENT_AUTH_SECONDS;
}

/** Creates the write barrier and records the deletion request in one transaction */
export async function enqueueAccountDeletion(
  firestore: Firestore,
  userId: string,
  authAlreadyDeleted = false,
): Promise<void> {
  const reference = firestore.collection(ACCOUNT_DELETION_JOBS).doc(userId);
  await firestore.runTransaction(async (transaction) => {
    const job = await transaction.get(reference);
    if (!job.exists) {
      transaction.create(reference, {
        phase: authAlreadyDeleted ? "clean-data" : "delete-auth",
        nextAttemptAt: Timestamp.fromMillis(Date.now() + (authAlreadyDeleted ? DELETION_DRAIN_MS : 0)),
      });
    }
  });
}

/** Claims a due job for longer than the scheduler's maximum invocation time */
export async function claimAccountDeletion(
  reference: DocumentReference,
): Promise<AccountDeletionPhase | null> {
  return reference.firestore.runTransaction(async (transaction) => {
    const job = await transaction.get(reference);
    const now = Date.now();
    const nextAttemptAt = job.get("nextAttemptAt");
    if (!(nextAttemptAt instanceof Timestamp) || nextAttemptAt.toMillis() > now) {
      return null;
    }

    transaction.update(reference, {
      nextAttemptAt: Timestamp.fromMillis(now + DELETION_LEASE_MS),
    });
    return job.get("phase") as AccountDeletionPhase;
  });
}

/** Deletes Auth and treats an already-deleted user as a successful retry */
export async function deleteAuthAccount(auth: Auth, userId: string): Promise<void> {
  try {
    await auth.deleteUser(userId);
  } catch (error) {
    if (!(error instanceof Error && "code" in error && error.code === "auth/user-not-found")) {
      throw error;
    }
  }
}

/** Recursively removes the user subtree and support messages associated with the UID */
export async function deleteAccountDocuments(firestore: Firestore, userId: string): Promise<void> {
  await firestore.recursiveDelete(firestore.collection("users").doc(userId));

  const query = firestore.collection("contactMessages").where("userUid", "==", userId).limit(400);
  for (;;) {
    const messages = await query.get();
    if (messages.empty) {
      return;
    }

    const batch = firestore.batch();
    for (const message of messages.docs) {
      batch.delete(message.ref);
    }
    await batch.commit();
  }
}

/** Runs one durable phase and leaves interrupted work eligible for another attempt */
export async function processAccountDeletion(
  reference: DocumentReference,
  auth: Auth,
  deleteStorageObjects: (userId: string) => Promise<void>,
): Promise<void> {
  const phase = await claimAccountDeletion(reference);
  switch (phase) {
    case "delete-auth":
      await deleteAuthAccount(auth, reference.id);
      await reference.update({
        phase: "clean-data",
        nextAttemptAt: Timestamp.fromMillis(Date.now() + DELETION_DRAIN_MS),
      });
      break;
    case "clean-data":
      await deleteAccountDocuments(reference.firestore, reference.id);
      await deleteStorageObjects(reference.id);
      await reference.update({
        phase: "final-sweep",
        nextAttemptAt: Timestamp.fromMillis(Date.now() + FINAL_STORAGE_SWEEP_MS),
      });
      break;
    case "final-sweep":
      await deleteStorageObjects(reference.id);
      await reference.delete();
      break;
  }
}

/** Processes due jobs in order so a failing job cannot hold up the queue */
export async function resumeAccountDeletions(
  firestore: Firestore,
  auth: Auth,
  deleteStorageObjects: (userId: string) => Promise<void>,
): Promise<void> {
  const jobs = await firestore.collection(ACCOUNT_DELETION_JOBS)
    .where("nextAttemptAt", "<=", Timestamp.now())
    .orderBy("nextAttemptAt")
    .limit(10)
    .get();

  const results = await Promise.allSettled(jobs.docs.map((job) =>
    processAccountDeletion(job.ref, auth, deleteStorageObjects),
  ));
  for (const result of results) {
    if (result.status === "rejected") {
      const error = result.reason;
      logger.error("Account deletion will retry", {
        code: error instanceof Error && "code" in error ? error.code : undefined,
      });
    }
  }
}
