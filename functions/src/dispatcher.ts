/**
 * Scheduled notification delivery pipeline
 *
 * Flow for each notification type:
 * 1 Query indexed settings documents whose next occurrence is due
 * 2 Reserve each occurrence and advance its schedule in one transaction
 * 3 Load active device registrations and group them by locale
 * 4 Send platform-specific FCM messages in supported batch sizes
 * 5 Persist delivery results and remove registrations confirmed as invalid
 *
 * The reservation happens before external delivery so overlapping executions
 * cannot send the same logical occurrence twice
 */

import {
  DocumentData,
  DocumentReference,
  Firestore,
  QueryDocumentSnapshot,
  Timestamp,
} from "firebase-admin/firestore";
import {
  Messaging,
  MulticastMessage,
} from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";

import {
  DEVICE_ACTIVE_DAYS,
  DUE_QUERY_LIMIT,
  FCM_MULTICAST_LIMIT,
  getSupportedLocale,
  NOTIFICATION_TYPES,
  NotificationDefinition,
  SupportedLocale,
} from "./notification-config";
import {
  getDate,
  getDispatchId,
  getLocalDate,
  getLocalDayBounds,
  getNextOccurrence,
  isNotificationDue,
} from "./scheduling";
import {getConfiguredNotificationDefinitions} from "./remote-notification-config";

/** Reason a reserved notification is completed without contacting FCM */
export type DispatchSkipReason = "weight_recorded" | "stale";

/** Immutable context created when a due occurrence is successfully reserved */
export interface ReservedDispatch {
  /** User preference document containing schedule state */
  settingsReference: DocumentReference<DocumentData>;

  /** Server-only idempotency and delivery audit document */
  dispatchReference: DocumentReference<DocumentData>;

  /** Behavior and field mapping for this notification type */
  definition: NotificationDefinition;

  /** Owning Firebase Authentication user ID used only in structured logs */
  userId: string;

  /** Timezone captured while the occurrence is reserved */
  timezone: string;

  /** Settings locale used when a device does not provide a supported locale */
  defaultLocale: SupportedLocale;

  /** Stable type and local-date key shared by Firestore and the FCM payload */
  idempotencyKey: string;

  /** Optional reason this occurrence was reserved but should not be delivered */
  skipReason: DispatchSkipReason | null;

  /** Common timestamp used for message metadata and active-device filtering */
  reservedAt: Date;

  /** Scheduled instant used to preserve the reminder's original expiration */
  dueAt: Date;
}

/** Active FCM token together with the Firestore document that owns it */
export interface DeviceRegistration {
  /** Document reference retained so invalid registrations can be deleted safely */
  reference: DocumentReference<DocumentData>;
  token: string;
  locale: SupportedLocale;
}

/** Aggregate result from one user delivery across locales and FCM chunks */
export interface DeliveryResult {
  successCount: number;
  failureCount: number;

  /** Bounded token-free diagnostics retained for failed FCM recipients */
  failureDetails: DeliveryFailureDetail[];

  /** Documents whose tokens FCM explicitly reports as unregistered */
  invalidDeviceReferences: DocumentReference<DocumentData>[];
}

/** Source and sanitized FCM error retained for one failed device */
export interface DeliveryFailureDetail {
  devicePath: string;
  source: "fcm_response" | "multicast_request";
  code: string;
  message: string;
}

/** Maximum failure records stored on one dispatch document */
export const DELIVERY_FAILURE_DETAIL_LIMIT = 20;

/** Maximum stored length for one sanitized FCM error message */
export const DELIVERY_FAILURE_MESSAGE_LIMIT = 500;

/** Queries only indexed timestamps that are due for one notification type */
export async function getDueSettings(
  firestore: Firestore,
  definition: NotificationDefinition,
  now: Date,
): Promise<QueryDocumentSnapshot<DocumentData>[]> {
  // This collection-group query reads preferences below every user without reading user documents
  const snapshot = await firestore
    .collectionGroup("notificationSettings")

    // Enabled and due fields match the composite indexes in firestore.indexes.json
    .where(definition.enabledField, "==", true)
    .where(definition.nextAtField, "<=", Timestamp.fromDate(now))

    // Oldest overdue occurrences are processed first when the query reaches its limit
    .orderBy(definition.nextAtField, "asc")
    .limit(DUE_QUERY_LIMIT)
    .get();

  return snapshot.docs;
}

/** Returns the owning user document for a notification settings reference */
export function getUserReference(
  settingsReference: DocumentReference<DocumentData>,
): DocumentReference<DocumentData> {
  // Expected path is users/{uid}/notificationSettings/preferences
  const userReference = settingsReference.parent.parent;

  // Fail closed if this helper is ever called with an unrelated collection path
  if (userReference === null || userReference.parent.id !== "users") {
    throw new Error(`Unexpected notification settings path: ${settingsReference.path}`);
  }

  return userReference;
}

/** Builds the bounded query used to detect a weight entry on one local day */
export function getLocalDateWeightQuery(
  userReference: DocumentReference<DocumentData>,
  localDateReference: Date,
  timezone: string,
) {
  const bounds = getLocalDayBounds(localDateReference, timezone);

  // The range is evaluated in UTC but represents exactly one local day, including DST days
  return userReference
    .collection("weightTracks")
    .where("dateTime", ">=", Timestamp.fromDate(bounds.start))
    .where("dateTime", "<", Timestamp.fromDate(bounds.end))
    .orderBy("dateTime", "desc")
    .limit(1);
}

/** Checks weight state immediately before FCM delivery to narrow dispatch races */
export async function hasWeightForReservedLocalDate(
  dispatch: ReservedDispatch,
): Promise<boolean> {
  if (!dispatch.definition.skipWhenWeightRecorded) {
    return false;
  }

  const userReference = getUserReference(dispatch.settingsReference);
  const snapshot = await getLocalDateWeightQuery(
    userReference,
    dispatch.dueAt,
    dispatch.timezone,
  ).get();

  return !snapshot.empty;
}

/** Reserves and advances a due occurrence in one transaction */
export async function reserveDueNotification(
  firestore: Firestore,
  settingsReference: DocumentReference<DocumentData>,
  definition: NotificationDefinition,
  now: Date,
): Promise<ReservedDispatch | null> {
  // Revalidate and reserve inside the transaction because the due query may become stale
  return firestore.runTransaction(async (transaction) => {
    const settingsSnapshot = await transaction.get(settingsReference);
    const settings = settingsSnapshot.data();

    // Another invocation may already have advanced or disabled this schedule
    if (settings === undefined || !isNotificationDue(settings, definition, now)) {
      return null;
    }

    const dueAt = getDate(settings[definition.nextAtField]);

    // Malformed timestamps are ignored rather than risking an invalid reservation
    if (dueAt === null) {
      return null;
    }

    const timezone = typeof settings.timezone === "string" ? settings.timezone : "UTC";
    const userReference = getUserReference(settingsReference);
    const nextAt = getNextOccurrence(now, timezone, definition);

    // One document per type and local date acts as the durable idempotency record
    const idempotencyKey = getDispatchId(definition, dueAt, timezone);
    const localDate = getLocalDate(dueAt, timezone);
    const dispatchReference = userReference.collection("notificationDispatches").doc(idempotencyKey);
    const dispatchSnapshot = await transaction.get(dispatchReference);

    // Existing documents mean this logical occurrence was already claimed
    if (dispatchSnapshot.exists) {
      // Preference or timezone changes can recreate a same-day due time after dispatch
      transaction.update(settingsReference, {
        [definition.nextAtField]: Timestamp.fromDate(nextAt),
      });
      return null;
    }

    const isStale = now.getTime() >= dueAt.getTime() + definition.ttlSeconds * 1000;
    const weightSnapshot = definition.skipWhenWeightRecorded && !isStale ? await transaction.get(
      getLocalDateWeightQuery(userReference, dueAt, timezone),
    ) : null;
    const skipReason: DispatchSkipReason | null = isStale
      ? "stale"
      : weightSnapshot !== null && !weightSnapshot.empty
        ? "weight_recorded"
        : null;

    // Create fails on duplicate IDs while the transaction retries on concurrent settings changes
    transaction.create(dispatchReference, {
      type: definition.type,
      idempotencyKey,
      localDate,
      dueAt: Timestamp.fromDate(dueAt),
      reservedAt: Timestamp.fromDate(now),
      status: skipReason === null ? "reserved" : `skipped_${skipReason}`,
      ...(skipReason === null ? {} : {
        skipReason,
        completedAt: Timestamp.fromDate(now),
      }),
    });

    // Advance immediately so the next scheduler run does not repeatedly select this occurrence
    transaction.update(settingsReference, {
      [definition.nextAtField]: Timestamp.fromDate(nextAt),
    });

    return {
      settingsReference,
      dispatchReference,
      definition,
      userId: userReference.id,
      timezone,
      defaultLocale: getSupportedLocale(settings.locale),
      idempotencyKey,
      skipReason,
      reservedAt: now,
      dueAt,
    };
  });
}

/** Loads every active registration for the reserved user */
export async function getActiveDevices(
  dispatch: ReservedDispatch,
): Promise<DeviceRegistration[]> {
  // Firestore TTL deletion is asynchronous so enforce the 30-day window in the query too
  const cutoff = new Date(dispatch.reservedAt.getTime() - DEVICE_ACTIVE_DAYS * 24 * 60 * 60 * 1000);
  const userReference = getUserReference(dispatch.settingsReference);
  const snapshot = await userReference
    .collection("notificationDevices")
    .where("lastActiveAt", ">=", Timestamp.fromDate(cutoff))
    .get();

  // Converts valid device snapshots into delivery registrations
  return snapshot.docs.flatMap((document) => {
    const data = document.data();

    // Ignore malformed registrations without exposing or attempting an empty token
    if (typeof data.token !== "string" || data.token.length === 0) {
      return [];
    }

    return [{
      reference: document.ref,
      token: data.token,

      // Device locale is more current and specific than the settings fallback
      locale: getSupportedLocale(data.locale ?? dispatch.defaultLocale),
    }];
  });
}

/** Groups registrations so each device receives copy in its current locale */
export function groupDevicesByLocale(
  devices: DeviceRegistration[],
): Map<SupportedLocale, DeviceRegistration[]> {
  const groups = new Map<SupportedLocale, DeviceRegistration[]>();

  // A multicast request uses one payload so different locale copy needs separate groups
  for (const device of devices) {
    const group = groups.get(device.locale) ?? [];
    group.push(device);
    groups.set(device.locale, group);
  }

  return groups;
}

/** Splits registrations into the maximum size supported by FCM multicast */
export function chunkDevices(devices: DeviceRegistration[]): DeviceRegistration[][] {
  const chunks: DeviceRegistration[][] = [];

  // Preserve registration order because FCM responses use matching array indexes
  for (let index = 0; index < devices.length; index += FCM_MULTICAST_LIMIT) {
    chunks.push(devices.slice(index, index + FCM_MULTICAST_LIMIT));
  }

  return chunks;
}

/** Reads a stable Firebase error code without assuming a specific error class */
export function getDeliveryErrorCode(error: unknown): string {
  if (
    typeof error === "object" &&
    error !== null &&
    "code" in error &&
    typeof error.code === "string"
  ) {
    return error.code;
  }

  return "unknown";
}

/** Creates bounded diagnostics without persisting the FCM registration token */
export function createDeliveryFailureDetail(
  device: DeviceRegistration,
  error: unknown,
  source: DeliveryFailureDetail["source"],
): DeliveryFailureDetail {
  const rawMessage = error instanceof Error
    ? error.message
    : "Unknown FCM delivery error";
  const sanitizedMessage = rawMessage
    .split(device.token)
    .join("[redacted]")
    .slice(0, DELIVERY_FAILURE_MESSAGE_LIMIT);

  return {
    devicePath: device.reference.path,
    source,
    code: getDeliveryErrorCode(error),
    message: sanitizedMessage,
  };
}

/** Adds one diagnostic while keeping the dispatch document size bounded */
export function recordDeliveryFailure(
  result: DeliveryResult,
  device: DeviceRegistration | undefined,
  error: unknown,
  source: DeliveryFailureDetail["source"],
): void {
  if (
    device === undefined ||
    result.failureDetails.length >= DELIVERY_FAILURE_DETAIL_LIMIT
  ) {
    return;
  }

  result.failureDetails.push(
    createDeliveryFailureDetail(device, error, source),
  );
}

/** Builds a platform-specific alert with expiration and collapse metadata */
export function buildMulticastMessage(
  dispatch: ReservedDispatch,
  locale: SupportedLocale,
  devices: DeviceRegistration[],
): MulticastMessage {
  const {definition} = dispatch;
  const copy = definition.copy[locale];

  // Preserve the original useful window when a scheduler run starts slightly late
  const expiration = Math.floor(dispatch.dueAt.getTime() / 1000) + definition.ttlSeconds;
  const remainingTtlSeconds = Math.max(
    1,
    expiration - Math.floor(dispatch.reservedAt.getTime() / 1000),
  );

  return {
    // Preserves response order so FCM failures map back to device documents
    tokens: devices.map((device) => device.token),
    notification: {
      title: copy.title,
      body: copy.body,
    },

    // Flutter reads these string values when a message is opened
    data: {
      type: definition.type,
      route: definition.route,
      sentAt: dispatch.reservedAt.toISOString(),
      idempotencyKey: dispatch.idempotencyKey,
    },

    // High transport priority delivers reminders promptly while TTL and collapse discard stale copies
    android: {
      priority: "high",
      ttl: remainingTtlSeconds * 1000,
      collapseKey: definition.type,
      notification: {
        channelId: definition.androidChannelId,
        priority: "high",
        tag: definition.type,
      },
    },

    // Alert push type and priority 10 are required for an immediate visible APNs notification
    apns: {
      headers: {
        "apns-push-type": "alert",
        "apns-priority": "10",
        "apns-expiration": String(expiration),
        "apns-collapse-id": definition.type,
      },
      payload: {
        aps: {
          sound: "default",
          threadId: definition.type,
        },
      },
    },

    // Web registrations receive equivalent urgency, expiration and replacement behavior
    webpush: {
      headers: {
        TTL: String(remainingTtlSeconds),
        Urgency: "high",
      },
      notification: {
        tag: definition.type,
      },
    },
  };
}

/** Sends one locale group and maps token failures back to device documents */
export async function sendDeviceGroup(
  messaging: Messaging,
  dispatch: ReservedDispatch,
  locale: SupportedLocale,
  devices: DeviceRegistration[],
): Promise<DeliveryResult> {
  const result: DeliveryResult = {
    successCount: 0,
    failureCount: 0,
    failureDetails: [],
    invalidDeviceReferences: [],
  };

  // Each chunk stays within the 500-recipient Firebase Admin API limit
  for (const chunk of chunkDevices(devices)) {
    try {
      const response = await messaging.sendEachForMulticast(
        buildMulticastMessage(dispatch, locale, chunk),
      );
      result.successCount += response.successCount;
      result.failureCount += response.failureCount;

      // Maps each FCM result to the corresponding registration
      response.responses.forEach((sendResponse, index) => {
        const device = chunk[index];

        if (!sendResponse.success) {
          recordDeliveryFailure(
            result,
            device,
            sendResponse.error,
            "fcm_response",
          );
        }

        if (
          device !== undefined &&
          sendResponse.error?.code === "messaging/registration-token-not-registered"
        ) {
          // Only definitive unregistered-token errors are safe to delete automatically
          result.invalidDeviceReferences.push(device.reference);
        }
      });
    } catch (error) {
      // A request-level failure counts the entire chunk but later chunks still continue
      result.failureCount += chunk.length;

      // Retain the shared request error against each affected device up to the audit limit
      chunk.forEach((device) => {
        recordDeliveryFailure(
          result,
          device,
          error,
          "multicast_request",
        );
      });

      logger.error("FCM multicast request failed", {
        error,
        userId: dispatch.userId,
        type: dispatch.definition.type,
        deviceCount: chunk.length,
      });
    }
  }

  return result;
}

/** Sends all locale groups while preserving results from successful groups */
export async function sendReservedNotification(
  messaging: Messaging,
  dispatch: ReservedDispatch,
  devices: DeviceRegistration[],
): Promise<DeliveryResult> {
  const total: DeliveryResult = {
    successCount: 0,
    failureCount: 0,
    failureDetails: [],
    invalidDeviceReferences: [],
  };

  // A failed locale group does not prevent delivery to devices in another locale
  for (const [locale, group] of groupDevicesByLocale(devices)) {
    const result = await sendDeviceGroup(messaging, dispatch, locale, group);
    total.successCount += result.successCount;
    total.failureCount += result.failureCount;
    total.failureDetails.push(
      ...result.failureDetails.slice(
        0,
        DELIVERY_FAILURE_DETAIL_LIMIT - total.failureDetails.length,
      ),
    );
    total.invalidDeviceReferences.push(...result.invalidDeviceReferences);
  }

  return total;
}

/** Deletes registrations that FCM confirms are no longer valid */
export async function deleteInvalidDevices(
  references: DocumentReference<DocumentData>[],
): Promise<void> {
  // Deletes invalid devices independently so one failure does not stop cleanup
  const deletions = await Promise.allSettled(
    references.map((reference) => reference.delete()),
  );

  // Logs document paths without exposing registration tokens
  deletions.forEach((deletion, index) => {
    if (deletion.status === "rejected") {
      logger.error("Deleting an invalid notification device failed", {
        error: deletion.reason,
        devicePath: references[index]?.path,
      });
    }
  });
}

/** Records aggregate delivery results on the idempotency document */
export async function completeDispatch(
  dispatch: ReservedDispatch,
  result: DeliveryResult,
  deviceCount: number,
): Promise<void> {
  // The dispatch document provides a server-only audit trail without storing tokens
  await dispatch.dispatchReference.update({
    status: result.failureCount === 0 ? "completed" : "completed_with_failures",
    completedAt: Timestamp.now(),
    deviceCount,
    successCount: result.successCount,
    failureCount: result.failureCount,
    ...(result.failureCount === 0 ? {} : {
      failureDetails: result.failureDetails,
      failureDetailsTruncated: result.failureDetails.length < result.failureCount,
    }),
  });
}

/** Completes a reservation that became unnecessary before FCM delivery */
export async function completeSkippedDispatch(
  dispatch: ReservedDispatch,
  skipReason: DispatchSkipReason,
): Promise<void> {
  await dispatch.dispatchReference.update({
    status: `skipped_${skipReason}`,
    skipReason,
    completedAt: Timestamp.now(),
  });
}

/** Processes one due settings document without exposing failures to other users */
export async function processDueSettings(
  firestore: Firestore,
  messaging: Messaging,
  settingsDocument: QueryDocumentSnapshot<DocumentData>,
  definition: NotificationDefinition,
  now: Date,
): Promise<void> {
  // Reservation may return null when another invocation already claimed this occurrence
  const dispatch = await reserveDueNotification(
    firestore,
    settingsDocument.ref,
    definition,
    now,
  );

  if (dispatch === null) {
    return;
  }

  // The reservation transaction already completed stale and pre-recorded occurrences
  if (dispatch.skipReason !== null) {
    return;
  }

  try {
    // Delivery is intentionally performed after the transaction to avoid external calls in retries
    const devices = await getActiveDevices(dispatch);

    // Recheck after device loading so entries committed near dispatch suppress the reminder
    if (await hasWeightForReservedLocalDate(dispatch)) {
      await completeSkippedDispatch(dispatch, "weight_recorded");
      return;
    }

    const result = await sendReservedNotification(messaging, dispatch, devices);

    // Record the outcome before cleaning invalid devices so cleanup cannot hide delivery success
    await completeDispatch(dispatch, result, devices.length);
    await deleteInvalidDevices(result.invalidDeviceReferences);
  } catch (error) {
    // Store a bounded error message without tokens or other registration data
    await dispatch.dispatchReference.update({
      status: "failed",
      completedAt: Timestamp.now(),
      error: error instanceof Error ? error.message.slice(0, 1000) : "Unknown delivery error",
    });
    throw error;
  }
}

/** Processes one indexed due query and logs failures independently */
export async function dispatchNotificationType(
  firestore: Firestore,
  messaging: Messaging,
  definition: NotificationDefinition,
  now: Date,
): Promise<void> {
  // One indexed query handles one due timestamp field and its matching enabled flag
  const dueSettings = await getDueSettings(firestore, definition, now);

  // Isolates each user's delivery outcome
  const outcomes = await Promise.allSettled(
    dueSettings.map((settingsDocument) => processDueSettings(
      firestore,
      messaging,
      settingsDocument,
      definition,
      now,
    )),
  );

  // Reports rejected deliveries after all users have been processed
  outcomes.forEach((outcome, index) => {
    if (outcome.status === "rejected") {
      logger.error("Notification delivery failed for one user", {
        error: outcome.reason,
        settingsPath: dueSettings[index]?.ref.path,
        type: definition.type,
      });
    }
  });
}

/** Dispatches every supported due notification type */
export async function dispatchDueNotifications(
  firestore: Firestore,
  messaging: Messaging,
  now: Date,
): Promise<void> {
  const definitions = await getConfiguredNotificationDefinitions(firestore);

  // Processes notification types independently
  const outcomes = await Promise.allSettled(
    NOTIFICATION_TYPES.map((type) => dispatchNotificationType(
      firestore,
      messaging,
      definitions[type],
      now,
    )),
  );

  // Reports query failures without masking successful notification types
  outcomes.forEach((outcome, index) => {
    if (outcome.status === "rejected") {
      logger.error("Notification due query failed", {
        error: outcome.reason,
        type: NOTIFICATION_TYPES[index],
      });
    }
  });
}
