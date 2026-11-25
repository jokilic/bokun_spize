import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';

import '../util/analytics.dart';

class AnalyticsService {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseAnalytics analytics;

  AnalyticsService({
    required this.analytics,
  });

  ///
  /// METHODS
  ///

  /// Keeps analytics failures from interrupting account creation or meal flows
  Future<void> sendEvent(Future<void> Function() send) async {
    try {
      await send();
    } catch (error) {
      log(
        'Sending analytics event failed',
        error: error.runtimeType,
      );
    }
  }

  /// Records a product interaction with its fixed event parameters
  Future<void> record(
    AnalyticsEvent event, {
    Map<String, Object>? parameters,
  }) => sendEvent(
    () => analytics.logEvent(
      name: event.eventName,
      parameters: parameters,
    ),
  );

  /// Records a failed new meal save using a fixed failure reason
  Future<void> logMealSaveFailed(
    MealAnalyticsMethod method,
    MealSaveFailure reason,
  ) => record(
    AnalyticsEvent.mealSaveFailed,
    parameters: {
      'method': method.name,
      'reason': reason.eventValue ?? reason.name,
    },
  );

  /// Records a newly created account and its sign-up method
  Future<void> logSignUp({required String method}) => sendEvent(
    () => analytics.logSignUp(
      signUpMethod: method,
    ),
  );

  /// Records a successful sign-in and its authentication method
  Future<void> logLogin({required String method}) => sendEvent(
    () => analytics.logLogin(
      loginMethod: method,
    ),
  );

  /// Records a successful sign-out
  Future<void> logLogout() => sendEvent(
    () => analytics.logEvent(
      name: 'logout',
    ),
  );

  /// Records successful deletion of a Firebase Auth account
  Future<void> logDeleteAccount() => sendEvent(
    () => analytics.logEvent(
      name: 'delete_account',
    ),
  );

  /// Records when a user opens a flow for creating a meal
  Future<void> logAddMealOpened(MealAnalyticsMethod method) => sendEvent(
    () => analytics.logEvent(
      name: 'add_meal_opened',
      parameters: {
        'method': method.name,
      },
    ),
  );

  /// Records a successful new meal save with timing and any available generation metrics
  Future<void> logMealSaved(
    MealAnalyticsMethod method, {
    required Duration duration,
    required bool hasPhoto,
    AIMealGenerationMetrics? generation,
  }) => record(
    AnalyticsEvent.mealSaved,
    parameters: {
      'method': method.name,
      'duration_ms': duration.inMilliseconds,
      'has_photo': hasPhoto ? 1 : 0,
      if (generation != null) ...{
        'ai_attempt': generation.attempt,
        'ai_model': generation.model,
        'ai_generation_ms': generation.durationMs,
        'ai_backend_ms': generation.backendDurationMs,
        'food_count': generation.foodCount,
      },
    },
  );
}
