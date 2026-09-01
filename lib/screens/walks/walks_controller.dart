import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/steps_with_date/steps_with_date.dart';
import '../../util/null_state.dart';

class WalksController
    extends
        ValueNotifier<
          ({
            List<StepsWithDate>? stepsWithDate,
            bool? permissionAuthorized,
            bool isLoading,
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
         permissionAuthorized: null,
         isLoading: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  Future<void> init() async => refreshSteps();

  ///
  /// VARIABLES
  ///

  final graphCalendarDayOptions = [3, 7, 14, 30];

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

  /// Requests permission and fetches the total steps recorded
  Future<void> refreshSteps() async {
    updateState(
      stepsWithDate: const [],
      permissionAuthorized: null,
      isLoading: true,
      error: null,
    );

    try {
      /// Configure `Health` plugin
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

      /// Permission is confirmed before step data starts loading
      updateState(
        permissionAuthorized: true,
      );

      final now = DateTime.now();
      final stepsWithDate = <StepsWithDate>[];

      /// Get steps for today and the previous days
      for (var dayOffset = 30; dayOffset >= 0; dayOffset--) {
        final startOfDay = DateTime(
          now.year,
          now.month,
          now.day - dayOffset,
        );
        final startOfNextDay = DateTime(
          startOfDay.year,
          startOfDay.month,
          startOfDay.day + 1,
        );

        final endOfInterval = startOfNextDay.isAfter(now) ? now : startOfNextDay;

        final steps = await health.getTotalStepsInInterval(
          startOfDay,
          endOfInterval,
        );

        /// Keep only past days with recorded steps, but always include today
        if (dayOffset > 0 && (steps == null || steps <= 0)) {
          continue;
        }

        stepsWithDate.add(
          StepsWithDate(
            dateTime: startOfDay,
            steps: steps ?? 0,
          ),
        );
      }

      /// Steps fetched succesfully
      updateState(
        stepsWithDate: stepsWithDate,
        permissionAuthorized: true,
        error: null,
      );
    }
    /// Some error fetching steps
    catch (error) {
      updateState(
        error: error.toString(),
      );
    } finally {
      updateState(
        isLoading: false,
      );
    }
  }

  /// Fetches step data again after an error
  Future<void> retrySteps() => refreshSteps();

  /// Updates `state`
  void updateState({
    List<StepsWithDate>? stepsWithDate,
    Object? permissionAuthorized = nullStateNoChange,
    bool? isLoading,
    Object? error = nullStateNoChange,
  }) => value = (
    stepsWithDate: stepsWithDate ?? value.stepsWithDate,
    permissionAuthorized: identical(permissionAuthorized, nullStateNoChange) ? value.permissionAuthorized : permissionAuthorized as bool?,
    isLoading: isLoading ?? value.isLoading,
    error: identical(error, nullStateNoChange) ? value.error : error as String?,
  );
}
