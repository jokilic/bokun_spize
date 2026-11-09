import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Returns the current operating-system notification permission state
Future<AuthorizationStatus> getFirebaseMessagingPermissionStatus() async {
  try {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus;
  } catch (error) {
    log(
      'Reading notification permission failed',
      error: error,
    );
    return AuthorizationStatus.denied;
  }
}

/// Requests notification permission after an explicit user action
Future<AuthorizationStatus> requestFirebaseMessagingPermission() async {
  try {
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus;
  } catch (error) {
    log(
      'Requesting notification permission failed',
      error: error,
    );
    return AuthorizationStatus.denied;
  }
}
