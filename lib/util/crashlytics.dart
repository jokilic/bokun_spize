import 'package:get_it/get_it.dart';

import '../services/crashlytics_service.dart';

/// Sends a handled error in the background when app startup has registered Crashlytics
void reportHandledError({
  required Object error,
  required StackTrace stackTrace,
  required String reason,
  Iterable<String> information = const [],
}) {
  final crashlytics = GetIt.instance.maybeGet<CrashlyticsService>();

  if (crashlytics != null) {
    crashlytics.recordNonFatalError(
      error: error,
      stackTrace: stackTrace,
      reason: reason,
      information: information,
    );
  }
}
