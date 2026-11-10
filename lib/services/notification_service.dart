import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/notification/notification_payload.dart';
import '../util/firebase.dart';
import 'screen_service.dart';

enum NotificationType {
  weightReminder,
  dailySummary,
  announcement,
}

class NotificationService extends ValueNotifier<AuthorizationStatus> with WidgetsBindingObserver implements Disposable {
  ///
  /// CONSTRUCTOR
  ///
  final FirebaseMessaging messaging;
  final ScreenService screen;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Stream<RemoteMessage> foregroundMessages;
  final Stream<RemoteMessage> openedMessages;
  final Future<bool> Function() openSystemSettingsCallback;

  NotificationService({
    required this.messaging,
    required this.screen,
    required this.scaffoldMessengerKey,
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

    foregroundBannerTimer?.cancel();

    await foregroundMessageSubscription?.cancel();
    await openedMessageSubscription?.cancel();

    isInitialized = false;

    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  StreamSubscription<RemoteMessage>? foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? openedMessageSubscription;
  Timer? foregroundBannerTimer;
  bool isInitialized = false;

  ///
  /// GETTERS
  ///

  /// Reports whether the operating system can currently deliver notifications
  bool get permissionGranted => switch (value) {
    AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
    AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently || AuthorizationStatus.notDetermined => false,
  };

  ///
  /// METHODS
  ///

  /// Subscribes to foreground messages and notification interactions
  void subscribeToMessages() {
    try {
      foregroundMessageSubscription = foregroundMessages.listen(
        handleForegroundMessage,
        onError: handleMessageStreamError,
      );
    } catch (error, stackTrace) {
      logNotificationError(
        'Subscribing to foreground FCM messages failed',
        error,
        stackTrace,
      );
    }

    try {
      openedMessageSubscription = openedMessages.listen(
        handleMessageInteraction,
        onError: handleMessageStreamError,
      );
    } catch (error, stackTrace) {
      logNotificationError(
        'Subscribing to opened FCM messages failed',
        error,
        stackTrace,
      );
    }
  }

  /// Enables native foreground alerts on iOS without requesting permission
  Future<void> configureForegroundPresentation() async {
    try {
      final useNativePresentation = defaultTargetPlatform == TargetPlatform.iOS;

      await messaging.setForegroundNotificationPresentationOptions(
        alert: useNativePresentation,
        badge: useNativePresentation,
        sound: useNativePresentation,
      );
    } catch (error, stackTrace) {
      logNotificationError(
        'Configuring FCM foreground presentation failed',
        error,
        stackTrace,
      );
    }
  }

  /// Requests notification permission after an explicit user action
  Future<AuthorizationStatus> requestPermission() async {
    try {
      final settings = await messaging.requestPermission();

      value = settings.authorizationStatus;
    } catch (error, stackTrace) {
      logNotificationError(
        'Requesting notification permission failed',
        error,
        stackTrace,
      );
    }

    return value;
  }

  /// Reads and publishes the latest operating-system permission state
  Future<AuthorizationStatus> refreshPermissionStatus() async {
    try {
      final settings = await messaging.getNotificationSettings();
      value = settings.authorizationStatus;
    } catch (error, stackTrace) {
      logNotificationError(
        'Reading notification permission failed',
        error,
        stackTrace,
      );
    }

    return value;
  }

  /// Opens this application's operating-system settings
  Future<bool> openSystemSettings() async {
    try {
      return await openSystemSettingsCallback();
    } catch (error, stackTrace) {
      logNotificationError(
        'Opening application settings failed',
        error,
        stackTrace,
      );
      return false;
    }
  }

  /// Refreshes permission state after returning from operating-system settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshPermissionStatus());
    }
  }

  /// Handles a notification received while the application is visible
  void handleForegroundMessage(RemoteMessage message) {
    final payload = parsePayload(message);

    if (defaultTargetPlatform == TargetPlatform.android) {
      showAndroidForegroundBanner(
        message,
        payload: payload,
      );
    }
  }

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
    } catch (error, stackTrace) {
      logNotificationError(
        'Reading the initial FCM message failed',
        error,
        stackTrace,
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

  /// Shows an in-app banner for a foreground Android notification
  void showAndroidForegroundBanner(
    RemoteMessage message, {
    required NotificationPayload? payload,
  }) {
    final notification = message.notification;
    final title = notification?.title ?? (message.data['title'] is String ? message.data['title'] as String : null);
    final body = notification?.body ?? (message.data['body'] is String ? message.data['body'] as String : null);
    final messenger = scaffoldMessengerKey.currentState;

    if (messenger == null || (title == null && body == null)) {
      return;
    }

    hideAndroidForegroundBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        leading: const Icon(Icons.notifications_rounded),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            if (body != null) Text(body),
          ],
        ),
        actions: [
          if (payload != null)
            IconButton(
              onPressed: () {
                hideAndroidForegroundBanner();
                openPayload(payload);
              },
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          IconButton(
            onPressed: hideAndroidForegroundBanner,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );

    foregroundBannerTimer = Timer(
      const Duration(seconds: 8),
      hideAndroidForegroundBanner,
    );
  }

  /// Hides the current Android foreground notification banner
  void hideAndroidForegroundBanner() {
    foregroundBannerTimer?.cancel();
    foregroundBannerTimer = null;
    scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
  }

  /// Logs message stream failures without interrupting application startup
  void handleMessageStreamError(Object error, StackTrace stackTrace) => logNotificationError(
    'Listening to FCM messages failed',
    error,
    stackTrace,
  );

  /// Logs a notification failure with its stack trace
  void logNotificationError(
    String message,
    Object error,
    StackTrace stackTrace,
  ) => log(
    message,
    error: error,
    stackTrace: stackTrace,
  );
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
