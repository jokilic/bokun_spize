import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/steps_with_date/steps_with_date.dart';

class WalksController
    extends
        ValueNotifier<
          ({
            List<StepsWithDate>? stepsWithDate,
            bool permissionAuthorized,
            String? error,
          })
        > {
  ///
  /// CONSTRUCTOR
  ///

  final Health health;

  WalksController({
    required this.health,
  }) : super((
         stepsWithDate: null,
         permissionAuthorized: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  Future<void> init() async => refreshSteps();

  ///
  /// METHODS
  ///

  /// Requests read access to step data from `Apple Health` or `Health Connect`
  Future<({bool granted, String? error})> requestStepPermission() async {
    /// Declare `types` and `permissions`
    const types = [HealthDataType.STEPS];
    const permissions = [HealthDataAccess.READ];

    /// Handle `Android` permissions
    if (defaultTargetPlatform == TargetPlatform.android) {
      final activityRecognitionPermission = await Permission.activityRecognition.request();

      if (!activityRecognitionPermission.isGranted) {
        return (
          granted: false,
          error: 'Activity recognition permission was not granted.',
        );
      }

      /// Check if `Health Connect` is available
      final healthConnectAvailable = await health.isHealthConnectAvailable();

      if (!healthConnectAvailable) {
        return (
          granted: false,
          error: 'Health Connect is not available on this device.',
        );
      }
    }

    /// Handle `iOS` permissions
    final hasPermission = await health.hasPermissions(
      types,
      permissions: permissions,
    );

    if (hasPermission == true) {
      return (granted: true, error: null);
    }

    /// Request `HealthKit` authorization
    final granted = await health.requestAuthorization(
      types,
      permissions: permissions,
    );

    return (
      granted: granted,
      error: granted ? null : 'Step access was not granted.',
    );
  }

  /// Requests permission and fetches the total steps recorded for the last 30 days
  Future<void> refreshSteps() async {
    updateState(
      clearError: true,
    );

    try {
      /// Configura `Health` plugin
      await health.configure();

      /// Request and handle permissions
      final permissionResult = await requestStepPermission();

      /// Permissions not granted, return error
      if (!permissionResult.granted) {
        updateState(
          permissionAuthorized: false,
          error: permissionResult.error ?? 'Step access is unavailable.',
        );
        return;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // TODO: I've created `List<StepsWithDate>`, can you update the state logic and instead of having only one day here, get last 30 days and fill out the state

      /// Get steps
      final steps = await health.getTotalStepsInInterval(startOfDay, now);

      /// Error fetching steps
      if (steps == null) {
        updateState(
          permissionAuthorized: true,
          error: 'Steps could not be fetched.',
        );
        return;
      }

      /// Steps fetched succesfully
      updateState(
        steps: steps,
        stepsFetchedAt: now,
        permissionAuthorized: true,
        clearError: true,
      );
    }
    /// Some error fetching steps
    catch (error) {
      updateState(
        permissionAuthorized: false,
        error: error.toString(),
      );
    }
  }

  /// Updates `state`.
  void updateState({
    List<StepsWithDate>? stepsWithDate,
    bool? permissionAuthorized,
    String? error,
    bool clearError = false,
  }) => value = (
    stepsWithDate: stepsWithDate ?? value.stepsWithDate,
    permissionAuthorized: permissionAuthorized ?? value.permissionAuthorized,
    error: clearError ? null : error ?? value.error,
  );
}
