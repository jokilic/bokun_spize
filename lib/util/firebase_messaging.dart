import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Returns the current operating-system notification permission state
Future<AuthorizationStatus> getFirebaseMessagingPermissionStatus() async {
  try {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    // TODO: Remove this when done testing
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await FirebaseMessaging.instance.getToken();
      log('FCM token: $token');

      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      log('APNS token: $apnsToken');

      FirebaseMessaging.onMessage.listen((message) {
        log(
          'Foreground FCM received: '
          '${message.messageId}, ${message.notification?.title}',
        );
      });
    }

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
