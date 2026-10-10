import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
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
            bool isHistoryLoading,
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
         isHistoryLoading: false,
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

  static const initialStepsDays = 5;

  final stepsHistory = const StepsHistory();

  Timer? stepsRefreshTimer;
  Stream<PedestrianStatus>? pedestrianStatusStream;
  StreamSubscription<PedestrianStatus>? pedestrianStatusSubscription;

  var isDisposed = false;
  var isStepsRefreshActive = false;
  var isRefreshingCurrentDaySteps = false;
  var isFetchingRemainingStepHistory = false;
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
          error: 'walksErrorActivityPermissionNotGranted'.tr(),
        );
      }

      /// Start walking detection after permission succeeds, including after a retry
      startWalkingDetection();

      /// Check if `Health Connect` is available
      final healthConnectAvailable = await health.isHealthConnectAvailable();

      if (!healthConnectAvailable) {
        return (
          granted: false,
          error: 'walksErrorHealthConnectNotAvailable'.tr(),
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
      error: granted ? null : 'walksErrorStepAccessNotGranted'.tr(),
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

  /// Requests permission and fetches the most recent step data before loading older history
  Future<void> refreshSteps() async {
    if (isDisposed || value.isLoading || isFetchingRemainingStepHistory) {
      return;
    }

    updateState(
      stepsWithDate: const [],
      permissionAuthorized: null,
      isLoading: true,
      isHistoryLoading: true,
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
          isHistoryLoading: false,
          error: permissionResult.error ?? 'walksErrorStepAccessUnavailable'.tr(),
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

      final recentHistoryStart = DateTime(
        today.year,
        today.month,
        today.day - initialStepsDays + 1,
      );

      final stepsByDate = <DateTime, StepsWithDate>{
        today: StepsWithDate(
          dateTime: today,
          steps: 0,
        ),
      };

      final recentSteps = await stepsHistory.getDailySteps(
        recentHistoryStart,
        now,
      );

      if (isDisposed) {
        return;
      }

      for (final entry in recentSteps) {
        final date = DateUtils.dateOnly(
          entry.dateTime,
        );

        /// Keep only past days with recorded steps, but always include today
        if (entry.steps > 0 || date == today) {
          stepsByDate[date] = StepsWithDate(
            dateTime: date,
            steps: entry.steps,
          );
        }
      }

      /// Show the success state as soon as the five most recent calendar days are available
      updateState(
        stepsWithDate: stepsByDate.values.toList()
          ..sort(
            (a, b) => a.dateTime.compareTo(
              b.dateTime,
            ),
          ),
        permissionAuthorized: true,
        isLoading: false,
        error: null,
      );

      /// Trigger a fire-and-forget method which fetches remaining steps
      unawaited(
        fetchRemainingStepHistory(
          historyEnd: recentHistoryStart,
        ),
      );
    } catch (error) {
      updateState(
        error: error.toString(),
        isHistoryLoading: false,
      );
    } finally {
      updateState(
        isLoading: false,
      );
    }
  }

  /// Fetches all accessible history older than the initial five calendar days
  Future<void> fetchRemainingStepHistory({
    required DateTime historyEnd,
  }) async {
    if (isDisposed || isFetchingRemainingStepHistory) {
      return;
    }

    isFetchingRemainingStepHistory = true;

    try {
      final earliestDate = await stepsHistory.getEarliestStepDate(
        historyEnd,
      );

      if (isDisposed || earliestDate == null) {
        return;
      }

      final historyStart = DateUtils.dateOnly(
        earliestDate,
      );
      final historicalStepsByDate = <DateTime, StepsWithDate>{};
      var batchEnd = historyEnd;

      /// Fetch older totals in yearly batches without keeping the success screen loading
      while (batchEnd.isAfter(historyStart)) {
        if (isDisposed) {
          return;
        }

        final proposedStart = DateTime(
          batchEnd.year,
          batchEnd.month,
          batchEnd.day - 365,
        );
        final batchStart = proposedStart.isBefore(historyStart) ? historyStart : proposedStart;
        final batch = await stepsHistory.getDailySteps(
          batchStart,
          batchEnd,
        );

        if (isDisposed) {
          return;
        }

        for (final entry in batch) {
          if (entry.steps > 0) {
            final date = DateUtils.dateOnly(
              entry.dateTime,
            );

            historicalStepsByDate[date] = StepsWithDate(
              dateTime: date,
              steps: entry.steps,
            );
          }
        }

        batchEnd = batchStart;
      }

      final allStepsByDate = <DateTime, StepsWithDate>{
        ...historicalStepsByDate,
        for (final entry in value.stepsWithDate ?? const <StepsWithDate>[]) entry.dateTime: entry,
      };

      updateState(
        stepsWithDate: allStepsByDate.values.toList()
          ..sort(
            (a, b) => a.dateTime.compareTo(
              b.dateTime,
            ),
          ),
      );
    } catch (error) {
      log(
        'Fetching remaining step history failed',
        error: error,
      );
    } finally {
      isFetchingRemainingStepHistory = false;
      updateState(
        isHistoryLoading: false,
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
    bool? isHistoryLoading,
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
      isHistoryLoading: isHistoryLoading ?? value.isHistoryLoading,
      isWalking: isWalking ?? value.isWalking,
      error: identical(error, nullStateNoChange) ? value.error : error as String?,
    );
  }
}
