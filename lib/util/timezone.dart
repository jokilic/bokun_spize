import 'dart:developer';

import 'package:flutter_timezone/flutter_timezone.dart';

/// Returns the device's current IANA timezone identifier
Future<String> getLocalTimezoneIdentifier({String fallback = 'UTC'}) async {
  try {
    final timezone = await FlutterTimezone.getLocalTimezone();
    return timezone.identifier;
  } catch (error) {
    log(
      'Reading local timezone failed',
      error: error,
    );
    return fallback;
  }
}
