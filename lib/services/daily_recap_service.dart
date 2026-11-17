import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../models/notification/notification_payload.dart';
import '../util/timezone.dart';
import 'storage_service.dart';

enum DailyActivitySyncStatus {
  available,
  permissionDenied,
  backgroundPermissionDenied,
  healthUnavailable,
  readFailed,
  skipped,
}

class DailyRecapService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final Health health;
  final StorageService storage;

  DailyRecapService({
    required this.auth,
    required this.firestore,
    required this.health,
    required this.storage,
  });

  static const retentionDays = 30;

  /// Requests step access and Android background-read access after explicit consent
  Future<bool> requestStepSyncPermission() async {
    try {
      await health.configure();

      if (defaultTargetPlatform == TargetPlatform.android && !(await health.isHealthConnectAvailable())) {
        return false;
      }

      const types = [HealthDataType.STEPS];
      const permissions = [HealthDataAccess.READ];
      final hasPermission = await health.hasPermissions(
        types,
        permissions: permissions,
      );
      final readAuthorized =
          hasPermission == true ||
          await health.requestAuthorization(
            types,
            permissions: permissions,
          );

      if (!readAuthorized) {
        return false;
      }

      if (defaultTargetPlatform != TargetPlatform.android) {
        return true;
      }

      final backgroundAvailable = await health.isHealthDataInBackgroundAvailable();

      if (!backgroundAvailable || await health.isHealthDataInBackgroundAuthorized()) {
        return true;
      }

      return await health.requestHealthDataInBackgroundAuthorization();
    } catch (error, stackTrace) {
      log(
        'Requesting daily recap step access failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Syncs the exact previous-day interval supplied by the notification server
  Future<DailyActivitySyncStatus> synchronizePayload(
    NotificationPayload payload, {
    required bool isBackground,
  }) async {
    final localDate = payload.localDate;
    final timezone = payload.timezone;
    final periodStart = payload.periodStart;
    final periodEnd = payload.periodEnd;

    if (localDate == null || timezone == null || periodStart == null || periodEnd == null) {
      return DailyActivitySyncStatus.skipped;
    }

    return synchronizePeriod(
      localDate: localDate,
      timezone: timezone,
      periodStart: periodStart,
      periodEnd: periodEnd,
      isBackground: isBackground,
    );
  }

  /// Opportunistically syncs yesterday whenever the foreground app becomes active
  Future<DailyActivitySyncStatus> synchronizePreviousDay() async {
    final timezone = await getLocalTimezoneIdentifier();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = DateTime(
      startOfToday.year,
      startOfToday.month,
      startOfToday.day - 1,
    );

    return synchronizePeriod(
      localDate: formatLocalDate(startOfYesterday),
      timezone: timezone,
      periodStart: startOfYesterday,
      periodEnd: startOfToday,
      isBackground: false,
    );
  }

  /// Reads one aggregate and writes only its daily total and source status
  Future<DailyActivitySyncStatus> synchronizePeriod({
    required String localDate,
    required String timezone,
    required DateTime periodStart,
    required DateTime periodEnd,
    required bool isBackground,
  }) async {
    final user = auth.currentUser;

    if (user == null || periodStart.isAfter(periodEnd) || periodStart.isAtSameMomentAs(periodEnd)) {
      return DailyActivitySyncStatus.skipped;
    }

    Map<String, dynamic>? settings;

    try {
      final settingsSnapshot = await firestore.collection('users').doc(user.uid).collection('notificationSettings').doc('preferences').get();
      settings = settingsSnapshot.data();
    } catch (error, stackTrace) {
      log(
        'Reading daily recap settings failed',
        error: error,
        stackTrace: stackTrace,
      );
      return DailyActivitySyncStatus.readFailed;
    }

    if (settings?['dailySummaryEnabled'] != true || settings?['dailyRecapStepsEnabled'] != true) {
      return DailyActivitySyncStatus.skipped;
    }

    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      return DailyActivitySyncStatus.skipped;
    }

    var status = DailyActivitySyncStatus.readFailed;
    int? steps;

    try {
      await health.configure();

      if (defaultTargetPlatform == TargetPlatform.android) {
        if (!(await health.isHealthConnectAvailable())) {
          status = DailyActivitySyncStatus.healthUnavailable;
        } else if (isBackground) {
          final backgroundAvailable = await health.isHealthDataInBackgroundAvailable();
          final backgroundAuthorized = backgroundAvailable && await health.isHealthDataInBackgroundAuthorized();

          if (!backgroundAuthorized) {
            status = DailyActivitySyncStatus.backgroundPermissionDenied;
          }
        }
      }

      if (status == DailyActivitySyncStatus.readFailed) {
        const types = [HealthDataType.STEPS];
        const permissions = [HealthDataAccess.READ];
        final hasPermission = await health.hasPermissions(
          types,
          permissions: permissions,
        );

        if (hasPermission == false) {
          status = DailyActivitySyncStatus.permissionDenied;
        } else {
          steps = await health.getTotalStepsInInterval(
            periodStart,
            periodEnd,
          );
          status = steps == null ? DailyActivitySyncStatus.readFailed : DailyActivitySyncStatus.available;
        }
      }
    } catch (error, stackTrace) {
      status = DailyActivitySyncStatus.readFailed;
      log(
        'Reading daily recap steps failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      await writeDailyActivity(
        userId: user.uid,
        localDate: localDate,
        timezone: timezone,
        status: status,
        steps: steps,
      );
    } catch (error, stackTrace) {
      log(
        'Writing daily recap activity failed',
        error: error,
        stackTrace: stackTrace,
      );
      return DailyActivitySyncStatus.readFailed;
    }

    return status;
  }

  /// Writes an idempotent per-day aggregate without allowing unavailable devices to replace valid data
  Future<void> writeDailyActivity({
    required String userId,
    required String localDate,
    required String timezone,
    required DailyActivitySyncStatus status,
    required int? steps,
  }) async {
    if (status == DailyActivitySyncStatus.skipped) {
      return;
    }

    final deviceId = await storage.getNotificationDeviceId();
    final document = firestore.collection('users').doc(userId).collection('dailyActivity').doc(localDate);
    final statusName = switch (status) {
      DailyActivitySyncStatus.available => 'available',
      DailyActivitySyncStatus.permissionDenied => 'permission_denied',
      DailyActivitySyncStatus.backgroundPermissionDenied => 'background_permission_denied',
      DailyActivitySyncStatus.healthUnavailable => 'health_unavailable',
      DailyActivitySyncStatus.readFailed => 'read_failed',
      DailyActivitySyncStatus.skipped => 'read_failed',
    };
    final data = <String, dynamic>{
      'localDate': localDate,
      'timezone': timezone,
      'status': statusName,
      'source': defaultTargetPlatform == TargetPlatform.iOS ? 'healthkit' : 'health_connect',
      'deviceId': deviceId,
      'capturedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(
          const Duration(days: retentionDays),
        ),
      ),
      'schemaVersion': 1,
      if (status == DailyActivitySyncStatus.available && steps != null) 'steps': steps,
    };

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final existing = snapshot.data();
      final belongsToAnotherDevice = existing?['deviceId'] != null && existing?['deviceId'] != deviceId;
      final existingIsAvailable = existing?['status'] == 'available';

      if ((existingIsAvailable && status != DailyActivitySyncStatus.available) ||
          (belongsToAnotherDevice && (existingIsAvailable || status != DailyActivitySyncStatus.available))) {
        return;
      }

      transaction.set(
        document,
        data,
      );
    });
  }

  /// Formats a local calendar date for Firestore document IDs
  String formatLocalDate(DateTime value) => '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
