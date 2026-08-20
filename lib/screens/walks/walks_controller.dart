import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class WalksController
    extends
        ValueNotifier<
          ({
            int? steps,
            DateTime? stepsFetchedAt,
            bool isLoading,
            bool isAuthorized,
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
         steps: null,
         stepsFetchedAt: null,
         isLoading: false,
         isAuthorized: false,
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

  /// Requests permission and fetches the total steps recorded today
  Future<void> refreshSteps() async {
    if (value.isLoading) {
      return;
    }

    updateState(
      isLoading: true,
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
          isLoading: false,
          isAuthorized: false,
          error: permissionResult.error ?? 'Step access is unavailable.',
        );
        return;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      /// Get steps
      final steps = await health.getTotalStepsInInterval(startOfDay, now);

      /// Error fetching steps
      if (steps == null) {
        updateState(
          isLoading: false,
          isAuthorized: true,
          error: 'Steps could not be fetched.',
        );
        return;
      }

      /// Steps fetched succesfully
      updateState(
        steps: steps,
        stepsFetchedAt: now,
        isLoading: false,
        isAuthorized: true,
        clearError: true,
      );
    }
    /// Some error fetching steps
    catch (error) {
      updateState(
        isLoading: false,
        isAuthorized: false,
        error: error.toString(),
      );
    }
  }

  /// Updates `state`.
  void updateState({
    int? steps,
    DateTime? stepsFetchedAt,
    bool? isLoading,
    bool? isAuthorized,
    String? error,
    bool clearError = false,
  }) => value = (
    steps: steps ?? value.steps,
    stepsFetchedAt: stepsFetchedAt ?? value.stepsFetchedAt,
    isLoading: isLoading ?? value.isLoading,
    isAuthorized: isAuthorized ?? value.isAuthorized,
    error: clearError ? null : error ?? value.error,
  );
}
