import {DocumentReference} from "firebase-admin/firestore";
import {describe, expect, it} from "vitest";

import {
  deduplicateDevices,
  DeviceRegistration,
  getSanitizedDeliveryMessage,
} from "../src/dispatcher";

/** Creates a lightweight registration for sender unit tests */
function createDevice(
  deviceId: string,
  fid: string,
  locale: DeviceRegistration["locale"] = "en",
): DeviceRegistration {
  return {
    reference: {id: deviceId} as DocumentReference,
    fid,
    locale,
  };
}

/** Covers device selection behavior before FCM delivery */
describe("notification dispatcher", () => {
  /** Verifies a reused FID is targeted through its newest device document */
  it("keeps only the newest document for a reused registration", () => {
    const newestDevice = createDevice("newest-device", "shared-fid", "hr");
    const uniqueDevice = createDevice("unique-device", "unique-fid");
    const olderDevice = createDevice("older-device", "shared-fid");

    const devices = deduplicateDevices([
      newestDevice,
      uniqueDevice,
      olderDevice,
    ]);

    expect(devices).toEqual([
      newestDevice,
      uniqueDevice,
    ]);
  });

  /** Verifies shared request errors redact every affected registration before truncation */
  it("redacts all registration IDs in a multicast error", () => {
    const devices = [
      createDevice("first-device", "first-fid"),
      createDevice("second-device", "second-fid"),
    ];
    const error = new Error("Failed to send to first-fid and second-fid");

    expect(getSanitizedDeliveryMessage(error, devices, "Unknown error", 40))
      .toBe("Failed to send to [redacted] and [redact");
  });
});
