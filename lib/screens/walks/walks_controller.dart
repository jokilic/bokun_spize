import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:health/health.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/durations.dart';
import '../../models/steps_with_date/steps_with_date.dart';
import '../../services/analytics_service.dart';
import '../../util/analytics.dart';
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
  final AnalyticsService analytics;
  final int graphCalendarDays;

  WalksController({
    required this.health,
    required this.analytics,
    required this.graphCalendarDays,
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

  final stepsHistory = const StepsHistory();

  Timer? stepsRefreshTimer;
  Stream<PedestrianStatus>? pedestrianStatusStream;
  StreamSubscription<PedestrianStatus>? pedestrianStatusSubscription;

  var isDisposed = false;
  var isStepsRefreshActive = false;
  var isRefreshingCurrentDaySteps = false;
  Object? lastStepRefreshErrorCode;
  DateTime? lastStepRefreshErrorLoggedAt;
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
    lastStepRefreshErrorCode = null;
    lastStepRefreshErrorLoggedAt = null;
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

      /// Fetch today's total and replace only today's entry
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
            steps: steps,
          ),
        );

      lastStepRefreshErrorCode = null;
      lastStepRefreshErrorLoggedAt = null;
      updateState(
        stepsWithDate: stepsWithDate,
      );
    } on HealthException catch (error) {
      logStepRefreshFailure(error.errorCode);

      /// A denied read cannot recover through the periodic refresh
      if (error.errorCode == HealthErrorCode.permissionDenied) {
        updateState(
          permissionAuthorized: false,
          error: getHealthErrorMessage(error),
        );
      }
    } catch (error) {
      logStepRefreshFailure(error.runtimeType);
    } finally {
      isRefreshingCurrentDaySteps = false;
    }
  }

  /// Logs new refresh failures immediately and repeated failures at most once per minute
  void logStepRefreshFailure(Object code) {
    if (!isStepsRefreshActive) {
      return;
    }

    final now = DateTime.now();
    final lastLoggedAt = lastStepRefreshErrorLoggedAt;
    if (code == lastStepRefreshErrorCode && lastLoggedAt != null && now.difference(lastLoggedAt) < const Duration(minutes: 1)) {
      return;
    }

    lastStepRefreshErrorCode = code;
    lastStepRefreshErrorLoggedAt = now;
    log(
      'Refreshing today steps failed',
      error: code,
    );
  }

  /// Requests read access to step data from `Apple Health` or `Health Connect`
  Future<({bool granted, String? error})> requestStepPermission() async {
    try {
      return await resolveStepPermission();
    } catch (_) {
      recordStepPermission(
        StepPermissionOutcome.error,
      );
      rethrow;
    }
  }

  /// Checks platform requirements and requests authorization if needed
  Future<({bool granted, String? error})> resolveStepPermission() async {
    /// Declare `types` and `permissions`
    const types = [HealthDataType.STEPS];
    const permissions = [HealthDataAccess.READ];

    /// Handle `Android` permissions
    if (defaultTargetPlatform == TargetPlatform.android) {
      final activityRecognitionPermission = await Permission.activityRecognition.request();

      if (!activityRecognitionPermission.isGranted) {
        recordStepPermission(StepPermissionOutcome.denied);
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
        recordStepPermission(
          StepPermissionOutcome.unavailable,
        );

        return (
          granted: false,
          error: 'walksErrorHealthConnectNotAvailable'.tr(),
        );
      }
    }

    /// Check the actual read permission state where the platform exposes it
    final hasPermission = await health.hasPermissions(
      types,
      permissions: permissions,
    );

    if (hasPermission == true) {
      return (granted: true, error: null);
    }

    /// `HealthKit` only reports whether another authorization sheet is needed
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final authorizationStatus = await health.getRequestStatusForAuthorization(
          types,
          permissions: permissions,
        );

        if (authorizationStatus == HealthAuthorizationRequestStatus.unnecessary) {
          return (granted: true, error: null);
        }
      } on PlatformException catch (error) {
        /// Fall back to the normal authorization request when HealthKit cannot determine the status
        log(
          'Step authorization status is unavailable',
          error: error,
        );
      }
    }

    /// Request authorization when access is missing or HealthKit can show its sheet
    final granted = await health.requestAuthorization(
      types,
      permissions: permissions,
    );

    /// HealthKit does not disclose whether the user granted read access
    recordStepPermission(
      defaultTargetPlatform == TargetPlatform.iOS
          ? (granted ? StepPermissionOutcome.unknown : StepPermissionOutcome.error)
          : (granted ? StepPermissionOutcome.granted : StepPermissionOutcome.denied),
    );

    return (
      granted: granted,
      error: granted ? null : 'walksErrorStepAccessNotGranted'.tr(),
    );
  }

  /// Counts an authorization outcome without recording step or activity data
  void recordStepPermission(StepPermissionOutcome outcome) {
    unawaited(
      analytics.countHealthInteraction(
        HealthAnalyticsEvent.stepPermissionResult,
        outcome: outcome,
      ),
    );
  }

  /// Requests access to older Android records while retaining ordinary step access
  Future<void> requestStepHistoryPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android || hasRequestedHistoryPermission) {
      return;
    }

    hasRequestedHistoryPermission = true;

    try {
      if (!await health.isHealthDataHistoryAvailable()) {
        unawaited(
          analytics.countHealthInteraction(
            HealthAnalyticsEvent.stepHistoryPermissionResult,
            outcome: StepPermissionOutcome.unavailable,
          ),
        );
      } else if (!await health.isHealthDataHistoryAuthorized()) {
        final granted = await health.requestHealthDataHistoryAuthorization();

        unawaited(
          analytics.countHealthInteraction(
            HealthAnalyticsEvent.stepHistoryPermissionResult,
            outcome: granted ? StepPermissionOutcome.granted : StepPermissionOutcome.denied,
          ),
        );
      }
    } catch (error) {
      unawaited(
        analytics.countHealthInteraction(
          HealthAnalyticsEvent.stepHistoryPermissionResult,
          outcome: StepPermissionOutcome.error,
        ),
      );

      log(
        'Step history permission is unavailable',
        error: error,
      );
    }
  }

  /// Requests permission and fetches the latest five calendar days before loading graph data
  Future<void> refreshSteps() async {
    if (isDisposed || value.isLoading || value.isHistoryLoading || isFetchingRemainingStepHistory) {
      return;
    }

    /// Clear previous data and enable both the list and graph loaders
    updateState(
      stepsWithDate: const [],
      permissionAuthorized: null,
      isLoading: true,
      isHistoryLoading: true,
      error: null,
    );

    try {
      /// Configure Health and request step access before fetching data
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

      /// Request access to older Android history when available
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
        today.day - 4,
      );

      final stepsByDate = <DateTime, StepsWithDate>{
        today: StepsWithDate(
          dateTime: today,
          steps: 0,
        ),
      };

      /// Fetch the latest five calendar days, including today
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

      /// Show the first results while keeping isHistoryLoading enabled
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

      /// Start the graph history fetch without awaiting it
      unawaited(
        fetchGraphStepHistory(
          today: today,
          historyEnd: recentHistoryStart,
        ),
      );
    } on HealthException catch (error) {
      log(
        'Fetching steps failed',
        error: error,
      );

      updateState(
        permissionAuthorized: error.errorCode == HealthErrorCode.permissionDenied ? false : value.permissionAuthorized,
        error: getHealthErrorMessage(error),
        isHistoryLoading: false,
      );
    } catch (error) {
      log(
        'Fetching steps failed',
        error: error,
      );

      updateState(
        error: 'walksErrorHealthDataUnavailable'.tr(),
        isHistoryLoading: false,
      );
    } finally {
      updateState(
        isLoading: false,
      );
    }
  }

  /// Completes the selected graph range before starting the remaining history fetch
  Future<void> fetchGraphStepHistory({
    required DateTime today,
    required DateTime historyEnd,
  }) async {
    if (isDisposed) {
      return;
    }

    try {
      final stepsByDate = <DateTime, StepsWithDate>{
        for (final entry in value.stepsWithDate ?? const <StepsWithDate>[]) entry.dateTime: entry,
      };
      DateTime? latestCompletedDate;

      /// Anchor the graph to the latest recorded day before today
      for (final entry in stepsByDate.values) {
        if (entry.steps > 0 && entry.dateTime.isBefore(today) && (latestCompletedDate == null || entry.dateTime.isAfter(latestCompletedDate))) {
          latestCompletedDate = entry.dateTime;
        }
      }

      /// Find the latest completed day directly when the initial window is empty
      if (latestCompletedDate == null) {
        final latestDate = await stepsHistory.getLatestStepDate(historyEnd);

        if (isDisposed) {
          return;
        }

        latestCompletedDate = latestDate == null ? null : DateUtils.dateOnly(latestDate);
      }

      if (latestCompletedDate == null) {
        updateState(
          isHistoryLoading: false,
        );
        return;
      }

      /// Include exactly graphCalendarDays calendar dates ending at the latest completed date
      final historyStart = DateTime(
        latestCompletedDate.year,
        latestCompletedDate.month,
        latestCompletedDate.day - (graphCalendarDays - 1),
      );

      /// Fetch only the graph interval not covered by the initial window
      if (historyStart.isBefore(historyEnd)) {
        final graphSteps = await stepsHistory.getDailySteps(
          historyStart,
          historyEnd,
        );

        if (isDisposed) {
          return;
        }

        for (final entry in graphSteps) {
          final date = DateUtils.dateOnly(entry.dateTime);

          if (entry.steps > 0 && date.isBefore(today)) {
            stepsByDate[date] = StepsWithDate(
              dateTime: date,
              steps: entry.steps,
            );
          }
        }
      }

      /// Preserve any current-day refresh completed while fetching graph data
      stepsByDate.addAll({
        for (final entry in value.stepsWithDate ?? const <StepsWithDate>[]) entry.dateTime: entry,
      });

      /// Publish the complete graph data and disable isHistoryLoading
      updateState(
        stepsWithDate: stepsByDate.values.toList()
          ..sort(
            (a, b) => a.dateTime.compareTo(
              b.dateTime,
            ),
          ),
        isHistoryLoading: false,
      );

      /// Start fetching history older than the completed graph range without awaiting it
      unawaited(
        fetchRemainingStepHistory(
          historyEnd: historyStart,
        ),
      );
    } catch (error) {
      log(
        'Fetching graph step history failed',
        error: error,
      );

      updateState(
        isHistoryLoading: false,
      );
    }
  }

  /// Fetches all accessible older history after the graph has finished loading
  Future<void> fetchRemainingStepHistory({
    required DateTime historyEnd,
  }) async {
    if (isDisposed || isFetchingRemainingStepHistory) {
      return;
    }

    isFetchingRemainingStepHistory = true;

    try {
      /// Use getEarliestStepDate to find the remaining history boundary
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

      /// Fetch the remaining daily totals in yearly batches with the graph already visible
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

        /// Publish every completed batch while preserving newer and live step data
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

        batchEnd = batchStart;
      }
    } catch (error) {
      log(
        'Fetching remaining step history failed',
        error: error,
      );
    } finally {
      isFetchingRemainingStepHistory = false;
    }
  }

  /// Fetches step data again after an error
  Future<void> retrySteps() {
    unawaited(
      analytics.countHealthInteraction(HealthAnalyticsEvent.walksRetryTapped),
    );

    return refreshSteps();
  }

  /// Maps structured health failures to safe messages for the walks screen
  String getHealthErrorMessage(HealthException error) {
    if (error.errorCode == HealthErrorCode.deviceLocked) {
      return 'walksErrorDeviceLocked'.tr();
    }

    if (error.isRetryable) {
      return 'walksErrorHealthDataTemporarilyUnavailable'.tr();
    }

    return switch (error.errorCode) {
      HealthErrorCode.permissionDenied => 'walksErrorStepAccessNotGranted'.tr(),
      HealthErrorCode.notSupported => 'walksErrorStepAccessUnavailable'.tr(),
      HealthErrorCode.invalidArgument || HealthErrorCode.dataTooLarge || HealthErrorCode.unknown => 'walksErrorHealthDataUnavailable'.tr(),
      _ => 'walksErrorHealthDataUnavailable'.tr(),
    };
  }

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
