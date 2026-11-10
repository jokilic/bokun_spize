import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../models/notification/notification_payload.dart';
import '../util/firebase.dart';
import 'screen_service.dart';

enum NotificationType {
  weightReminder,
  dailySummary,
  announcement,
}

/// Handles data-only background messages without performing UI work
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await initializeFirebase();

    final payload = NotificationPayload.fromMessage(message);

    if (payload == null) {
      log(
        'Ignoring malformed or unknown background FCM payload for message ${message.messageId}',
      );
    }
  } catch (error, stackTrace) {
    log(
      'Handling a background FCM message failed',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

class NotificationService extends ValueNotifier<AuthorizationStatus> with WidgetsBindingObserver implements Disposable {
  ///
  /// CONSTRUCTOR
  ///
  final FirebaseMessaging messaging;
  final ScreenService screen;
  final Stream<RemoteMessage> foregroundMessages;
  final Stream<RemoteMessage> openedMessages;
  final Future<bool> Function() openSystemSettingsCallback;

  NotificationService({
    required this.messaging,
    required this.screen,
    required this.foregroundMessages,
    required this.openedMessages,
    required this.openSystemSettingsCallback,
  }) : super(AuthorizationStatus.notDetermined);

  ///
  /// INIT
  ///

  /// Initializes permission state, message listeners and foreground presentation
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    isInitialized = true;
    WidgetsBinding.instance.addObserver(this);

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (error, stackTrace) {
      log(
        'Registering the FCM background handler failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    await configureForegroundPresentation();
    subscribeToMessages();

    await refreshPermissionStatus();
    await handleInitialMessage();
  }

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    WidgetsBinding.instance.removeObserver(this);

    await foregroundMessageSubscription?.cancel();
    await openedMessageSubscription?.cancel();

    isInitialized = false;

    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  bool isInitialized = false;

  StreamSubscription<RemoteMessage>? foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? openedMessageSubscription;

  ///
  /// METHODS
  ///

  /// Refreshes permission state after returning from operating-system settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshPermissionStatus();
    }
  }

  /// Subscribes to foreground messages and notification interactions
  void subscribeToMessages() {
    try {
      foregroundMessageSubscription = foregroundMessages.listen(
        handleForegroundMessage,
        onError: handleMessageStreamError,
      );
    } catch (error) {
      log(
        'Subscribing to foreground FCM messages failed',
        error: error,
      );
    }

    try {
      openedMessageSubscription = openedMessages.listen(
        handleMessageInteraction,
        onError: handleMessageStreamError,
      );
    } catch (error) {
      log(
        'Subscribing to opened FCM messages failed',
        error: error,
      );
    }
  }

  /// Logs message stream failures without interrupting application startup
  void handleMessageStreamError(Object error) => log(
    'Listening to FCM messages failed',
    error: error,
  );

  /// Enables native foreground alerts on iOS without requesting permission
  Future<void> configureForegroundPresentation() async {
    try {
      final useNativePresentation = defaultTargetPlatform == TargetPlatform.iOS;

      await messaging.setForegroundNotificationPresentationOptions(
        alert: useNativePresentation,
        badge: useNativePresentation,
        sound: useNativePresentation,
      );
    } catch (error) {
      log(
        'Configuring FCM foreground presentation failed',
        error: error,
      );
    }
  }

  /// Requests notification permission after an explicit user action
  Future<AuthorizationStatus> requestPermission() async {
    try {
      final settings = await messaging.requestPermission();
      value = settings.authorizationStatus;
    } catch (error) {
      log(
        'Requesting notification permission failed',
        error: error,
      );
    }

    return value;
  }

  /// Reads and publishes the latest operating-system permission state
  Future<AuthorizationStatus> refreshPermissionStatus() async {
    try {
      final settings = await messaging.getNotificationSettings();
      value = settings.authorizationStatus;
    } catch (error) {
      log(
        'Reading notification permission failed',
        error: error,
      );
    }

    return value;
  }

  /// Opens this application's operating-system settings
  Future<bool> openSystemSettings() async {
    try {
      return await openSystemSettingsCallback();
    } catch (error) {
      log(
        'Opening application settings failed',
        error: error,
      );
      return false;
    }
  }

  /// Handles a notification received while the application is visible
  void handleForegroundMessage(RemoteMessage message) => parsePayload(message);

  /// Handles a notification that opened the application from the background
  void handleMessageInteraction(RemoteMessage message) {
    final payload = parsePayload(message);

    if (payload != null) {
      openPayload(payload);
    }
  }

  /// Handles the notification that launched a terminated application
  Future<void> handleInitialMessage() async {
    try {
      final message = await messaging.getInitialMessage();

      if (message != null) {
        handleMessageInteraction(message);
      }
    } catch (error) {
      log(
        'Reading the initial FCM message failed',
        error: error,
      );
    }
  }

  /// Parses a message payload and logs malformed or unknown data
  NotificationPayload? parsePayload(RemoteMessage message) {
    final payload = NotificationPayload.fromMessage(message);

    if (payload == null) {
      log(
        'Ignoring malformed or unknown FCM payload for message ${message.messageId}',
      );
    }

    return payload;
  }

  /// Opens the supported application destination from a parsed payload
  void openPayload(NotificationPayload payload) => screen.changeNavigationBarItem(
    payload.route,
  );
}
