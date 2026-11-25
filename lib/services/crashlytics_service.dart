import 'dart:async';
import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseCrashlytics crashlytics;

  CrashlyticsService({
    required this.crashlytics,
  });

  ///
  /// METHODS
  ///

  /// Logs reporting failures locally so they do not trigger another crash report
  Future<void> sendReport(Future<void> Function() send) async {
    try {
      await send();
    } catch (error, stackTrace) {
      log(
        'Sending crash report failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Reports framework errors and uncaught errors on the main isolate
  void registerErrorHandlers() {
    FlutterError.onError = (details) => sendReport(
      () => crashlytics.recordFlutterFatalError(details),
    );

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      recordFatalError(
        error,
        stackTrace,
      );
      return true;
    };
  }

  /// Records an error that prevented normal app execution
  Future<void> recordFatalError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) => sendReport(
    () => crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: true,
    ),
  );

  /// Records handled errors using the error type and explicitly supplied diagnostic data
  Future<void> recordNonFatalError({
    required Object error,
    required StackTrace stackTrace,
    required String reason,
    Iterable<String> information = const [],
  }) => sendReport(
    () => crashlytics.recordError(
      error.runtimeType.toString(),
      stackTrace,
      reason: reason,
      information: information,
    ),
  );
}
