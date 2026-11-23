import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../util/analytics.dart';

class AnalyticsService {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseAnalytics analytics;
  final FirebaseFunctions functions;

  AnalyticsService({
    required this.analytics,
    required this.functions,
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

  /// Counts a health-related feature interaction in the app's own aggregate totals
  Future<void> countHealthInteraction(HealthAnalyticsEvent event, {StepPermissionOutcome? outcome}) => sendEvent(
    () async {
      await functions.httpsCallable('countHealthInteraction').call<void>(
        {
          'event': event.eventName,
          if (outcome != null) 'outcome': outcome.name,
        },
      );
    },
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

  /// Records when a newly created meal is saved successfully
  Future<void> logMealSaved(MealAnalyticsMethod method) => sendEvent(
    () => analytics.logEvent(
      name: 'meal_saved',
      parameters: {
        'method': method.name,
      },
    ),
  );
}
