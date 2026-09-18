import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/durations.dart';
import '../../models/steps_with_date/steps_with_date.dart';
import '../../util/null_state.dart';
import '../../util/steps_history.dart';

class WalksController
    extends
        ValueNotifier<
          ({
            List<StepsWithDate>? stepsWithDate,
            bool? permissionAuthorized,
            bool isWalking,
            bool isLoading,
            String? error,
          })
        >
    implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final Health health;

  WalksController({
    required this.health,
  }) : super((
         stepsWithDate: null,
         permissionAuthorized: null,
         isWalking: false,
         isLoading: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  void init() {
    resumeStepsRefresh();
    refreshSteps();
  }

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    isDisposed = true;
    pauseStepsRefresh();

    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  final graphCalendarDayOptions = [3, 7, 14, 30, 60, 90];

  final stepsHistory = const StepsHistory();

  Timer? stepsRefreshTimer;
  Stream<PedestrianStatus>? pedestrianStatusStream;
  StreamSubscription<PedestrianStatus>? pedestrianStatusSubscription;

  var isDisposed = false;
  var isStepsRefreshActive = false;
  var isRefreshingCurrentDaySteps = false;
  var hasRequestedHistoryPermission = false;

  ///
  /// METHODS
  ///

  /// Listens for walking changes
  void startWalkingDetection() {
    if (isDisposed || !isStepsRefreshActive || pedestrianStatusSubscription != null) {
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    runZonedGuarded(
      () async {
        /// Initial permission requests are handled by `requestStepPermission()`
        if (defaultTargetPlatform == TargetPlatform.android && !(await Permission.activityRecognition.status).isGranted) {
          return;
        }

        /// The screen may have paused or another call may have subscribed while checking permission
        if (isDisposed || !isStepsRefreshActive || pedestrianStatusSubscription != null) {
          return;
        }

        /// Reuse the stream because pedometer 4.2.0 creates an internal Android listener on each getter call
        pedestrianStatusStream ??= Pedometer.pedestrianStatusStream;
        pedestrianStatusSubscription = pedestrianStatusStream!.listen(
          onPedestrianStatusChanged,
          onError: onPedestrianStatusError,
        );
      },
      onPedestrianStatusError,
    );
  }

  /// Updates walking state
  void onPedestrianStatusChanged(PedestrianStatus status) {
    if (!isStepsRefreshActive) {
      return;
    }

    updateState(
      isWalking: status.status == 'walking',
    );
  }

  /// Resets walking state when data is unavailable
  void onPedestrianStatusError(Object error, StackTrace stackTrace) {
    if (isDisposed) {
      return;
    }

    updateState(
      isWalking: false,
    );

    log(
      'Walking detection failed',
      error: error,
    );
  }

  /// Starts step refreshes and walking detection while [WalksScreen] is active
  void resumeStepsRefresh() {
    if (isDisposed || isStepsRefreshActive) {
      return;
    }

    isStepsRefreshActive = true;
    startWalkingDetection();

    /// Refresh immediately when returning to an already loaded [WalksScreen]
    if (value.stepsWithDate != null && value.permissionAuthorized == true && !value.isLoading) {
      refreshCurrentDaySteps();
    }

    stepsRefreshTimer = Timer.periodic(
      BokunSpizeDurations.stepsRefreshInterval,
      (_) {
        if (value.isWalking && value.permissionAuthorized == true && !value.isLoading) {
          refreshCurrentDaySteps();
        }
      },
    );
  }

  /// Stops step refreshes and the walking subscription while [WalksScreen] is inactive
  void pauseStepsRefresh() {
    isStepsRefreshActive = false;
    stepsRefreshTimer?.cancel();
    stepsRefreshTimer = null;

    pedestrianStatusSubscription?.cancel();
    pedestrianStatusSubscription = null;

    updateState(
      isWalking: false,
    );
  }

  /// Fetches and updates only the current day steps
  Future<void> refreshCurrentDaySteps() async {
    if (isDisposed || !isStepsRefreshActive || isRefreshingCurrentDaySteps || value.isLoading) {
      return;
    }

    isRefreshingCurrentDaySteps = true;

    try {
      final now = DateTime.now();
      final startOfDay = DateUtils.dateOnly(now);

      final steps = await health.getTotalStepsInInterval(
        startOfDay,
        now,
      );

      /// Ignore a result completed after leaving [WalksScreen]
      if (isDisposed || !isStepsRefreshActive || value.isLoading) {
        return;
      }

      final stepsWithDate = [...?value.stepsWithDate]
        ..removeWhere(
          (stepWithDate) => DateUtils.isSameDay(
            stepWithDate.dateTime,
            startOfDay,
          ),
        )
        ..add(
          StepsWithDate(
            dateTime: startOfDay,
            steps: steps ?? 0,
          ),
        );

      updateState(
        stepsWithDate: stepsWithDate,
      );
    } catch (error) {
      log(
        'Refreshing today steps failed',
        error: error,
      );
    } finally {
      isRefreshingCurrentDaySteps = false;
    }
  }

  /// Requests read access to step data from `Apple Health` or `Health Connect`
  Future<({bool granted, String? error})> requestStepPermission() async {
    /// Declare `types` and `permissions`
    const types = [HealthDataType.STEPS];
    const permissions = [HealthDataAccess.READ];

    /// Handle `Android` permissions
    if (defaultTargetPlatform == TargetPlatform.android) {
      final activityRecognitionPermission = await Permission.activityRecognition.request();

      if (!activityRecognitionPermission.isGranted) {
        updateState(
          isWalking: false,
        );

        return (
          granted: false,
          error: 'Activity recognition permission was not granted.',
        );
      }

      /// Start walking detection after permission succeeds, including after a retry
      startWalkingDetection();

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

  /// Requests access to older Android records while retaining ordinary step access
  Future<void> requestStepHistoryPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android || hasRequestedHistoryPermission) {
      return;
    }

    hasRequestedHistoryPermission = true;

    try {
      if (await health.isHealthDataHistoryAvailable() && !(await health.isHealthDataHistoryAuthorized())) {
        await health.requestHealthDataHistoryAuthorization();
      }
    } catch (error) {
      log(
        'Step history permission is unavailable',
        error: error,
      );
    }
  }

  /// Requests permission and fetches all accessible history in batches of calendar days
  Future<void> refreshSteps() async {
    if (isDisposed || value.isLoading) {
      return;
    }

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

      await requestStepHistoryPermission();

      if (isDisposed) {
        return;
      }

      /// Permission is confirmed before step data starts loading
      updateState(
        permissionAuthorized: true,
      );

      final now = DateTime.now();
      final today = DateUtils.dateOnly(now);
      final earliestDate = await stepsHistory.getEarliestStepDate(now);
      final historyStart = DateUtils.dateOnly(earliestDate ?? today);
      final stepsByDate = <DateTime, StepsWithDate>{
        today: StepsWithDate(dateTime: today, steps: 0),
      };
      var batchEnd = now;

      /// Load recent totals first and continue through empty periods to the oldest record
      while (batchEnd.isAfter(historyStart)) {
        if (isDisposed) {
          return;
        }

        final proposedStart = DateTime(batchEnd.year, batchEnd.month, batchEnd.day - 365);
        final batchStart = proposedStart.isBefore(historyStart) ? historyStart : proposedStart;
        final batch = await stepsHistory.getDailySteps(batchStart, batchEnd);

        if (isDisposed) {
          return;
        }

        for (final entry in batch) {
          final date = DateUtils.dateOnly(entry.dateTime);

          /// Keep only past days with recorded steps, but always include today
          if (entry.steps > 0 || date == today) {
            stepsByDate[date] = StepsWithDate(dateTime: date, steps: entry.steps);
          }
        }

        updateState(
          stepsWithDate: stepsByDate.values.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime)),
        );

        batchEnd = batchStart;
      }

      /// Preserve today even when the health store has no recorded steps
      updateState(
        stepsWithDate: stepsByDate.values.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime)),
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
    bool? isWalking,
    Object? error = nullStateNoChange,
  }) {
    if (isDisposed) {
      return;
    }

    value = (
      stepsWithDate: stepsWithDate ?? value.stepsWithDate,
      permissionAuthorized: identical(permissionAuthorized, nullStateNoChange) ? value.permissionAuthorized : permissionAuthorized as bool?,
      isLoading: isLoading ?? value.isLoading,
      isWalking: isWalking ?? value.isWalking,
      error: identical(error, nullStateNoChange) ? value.error : error as String?,
    );
  }
}
