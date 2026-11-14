import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' hide NotificationSettings;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../models/notification/notification_device.dart';
import '../models/notification/notification_payload.dart';
import '../models/notification/notification_settings.dart';
import '../util/app_version.dart';
import '../util/device_info.dart';
import '../util/firebase.dart';
import '../util/timezone.dart';
import 'screen_service.dart';
import 'storage_service.dart';

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
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final StorageService storage;
  final ScreenService screen;
  final Stream<RemoteMessage> foregroundMessages;
  final Stream<RemoteMessage> openedMessages;
  final Future<bool> Function() openSystemSettingsCallback;

  NotificationService({
    required this.messaging,
    required this.auth,
    required this.firestore,
    required this.storage,
    required this.screen,
    required this.foregroundMessages,
    required this.openedMessages,
    required this.openSystemSettingsCallback,
  }) : super(AuthorizationStatus.notDetermined);

  ///
  /// INIT
  ///

  /// Initializes permission state, message listeners and foreground presentation
  Future<void> init() async {
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
    subscribeToRegistrations();
    subscribeToAuthenticationChanges();

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
    await registrationSubscription?.cancel();
    await unregistrationSubscription?.cancel();
    await authStateSubscription?.cancel();
    await notificationSettingsSubscription?.cancel();

    registrationRetryTimer?.cancel();

    isInitialized = false;

    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  bool isInitialized = false;

  StreamSubscription<RemoteMessage>? foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? openedMessageSubscription;

  StreamSubscription<String>? registrationSubscription;
  StreamSubscription<String>? unregistrationSubscription;
  StreamSubscription<User?>? authStateSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? notificationSettingsSubscription;

  Timer? registrationRetryTimer;
  Future<void> registrationSynchronization = Future<void>.value();

  NotificationSettings? notificationSettings;

  String? activeUserId;
  String? activeRegistrationId;
  String? activeAnnouncementTopic;
  String? registrationLocale;

  int registrationRetryAttempt = 0;
  bool announcementTopicsReconciled = false;
  bool announcementTopicLoaded = false;

  static const registrationRetryDelays = <Duration>[
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
  ];

  ///
  /// GETTERS
  ///

  /// Reports whether the current authorization can display notifications
  bool get canDeliverNotifications => value == AuthorizationStatus.authorized || value == AuthorizationStatus.provisional;

  /// Reports whether this platform requires an APNs token before FCM calls
  bool get requiresAPNSToken => !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS);

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

  ///
  /// REGISTRATION
  ///

  /// Listens for FCM registrations and associates their IDs with this installation
  void subscribeToRegistrations() {
    try {
      registrationSubscription = messaging.onRegistered.listen(
        handleRegistration,
        onError: handleRegistrationError,
      );
      unregistrationSubscription = messaging.onUnregistered.listen(
        handleUnregistration,
        onError: handleUnregistrationError,
      );
    } catch (error) {
      log(
        'Subscribing to FCM registrations failed',
        error: error,
      );
    }
  }

  /// Stores the latest direct-send registration ID without exposing it in logs
  void handleRegistration(String registrationId) {
    if (registrationId.isEmpty) {
      scheduleRegistrationRetry();
      return;
    }

    activeRegistrationId = registrationId;
    announcementTopicsReconciled = false;

    synchronizeRegistration(
      registrationId: registrationId,
    );
  }

  /// Clears a direct-send registration ID after FCM unregisters it
  void handleUnregistration(String registrationId) {
    if (activeRegistrationId == registrationId) {
      activeRegistrationId = null;
    }
  }

  /// Schedules another synchronization when the registration stream fails
  void handleRegistrationError(Object error) {
    log(
      'Listening to FCM registrations failed',
      error: error,
    );
    scheduleRegistrationRetry();
  }

  /// Logs unregistration stream failures without exposing registration IDs
  void handleUnregistrationError(Object error) => log(
    'Listening to FCM unregistrations failed',
    error: error,
  );

  ///
  /// AUTH
  ///

  /// Listens for sign-in changes so the installation follows the current user
  void subscribeToAuthenticationChanges() {
    try {
      authStateSubscription = auth.authStateChanges().listen(
        handleAuthenticationChanged,
        onError: handleAuthenticationStreamError,
      );
    } catch (error) {
      log(
        'Subscribing to authentication changes failed',
        error: error,
      );
    }
  }

  /// Re-associates the installation when the authenticated user changes
  Future<void> handleAuthenticationChanged(User? user) async {
    if (user == null) {
      if (activeUserId != null) {
        await unregisterCurrentUser(
          unregisterMessaging: true,
          removeDocument: false,
        );
      }
      return;
    }

    if (activeUserId == user.uid) {
      return;
    }

    if (activeUserId != null) {
      await unregisterCurrentUser(
        unregisterMessaging: true,
        removeDocument: false,
      );
    }

    activeUserId = user.uid;
    announcementTopicsReconciled = false;

    await listenToNotificationSettings(user.uid);

    if (canDeliverNotifications) {
      await synchronizeRegistration();
    }
  }

  /// Logs authentication listener failures without exposing user data
  void handleAuthenticationStreamError(Object error) => log(
    'Listening to authentication changes failed',
    error: error,
  );

  ///
  /// FOREGROUND MESSAGES
  ///

  /// Subscribes to foreground messages and taps that reopen the app
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

  /// Handles a notification received while the application is visible
  void handleForegroundMessage(RemoteMessage message) => parsePayload(message);

  /// Logs message stream failures without interrupting application startup
  void handleMessageStreamError(Object error) => log(
    'Listening to FCM messages failed',
    error: error,
  );

  /// Handles a notification that opened the application from the background
  void handleMessageInteraction(RemoteMessage message) {
    final payload = parsePayload(message);

    if (payload != null) {
      openPayload(payload);
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
    } catch (error) {
      log(
        'Configuring FCM foreground presentation failed',
        error: error,
      );
    }
  }

  ///
  /// PERMISSIONS
  ///

  /// Requests notification permission after an explicit user action
  Future<AuthorizationStatus> requestPermission() async {
    try {
      final settings = await messaging.requestPermission();
      value = settings.authorizationStatus;

      synchronizePermissionState();
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

      synchronizePermissionState();
    } catch (error) {
      log(
        'Reading notification permission failed',
        error: error,
      );
    }

    return value;
  }

  /// Creates or removes the registration after permission changes
  void synchronizePermissionState() {
    if (canDeliverNotifications) {
      synchronizeRegistration();
      return;
    }

    removeCurrentRegistration();
  }

  ///
  /// NOTIFICATION SETTINGS
  ///

  /// Starts listening to preferences that control announcement topic membership
  Future<void> listenToNotificationSettings(String userId) async {
    try {
      await notificationSettingsSubscription?.cancel();

      notificationSettings = null;
      notificationSettingsSubscription = firestore
          .collection('users')
          .doc(userId)
          .collection('notificationSettings')
          .doc('preferences')
          .snapshots()
          .listen(
            handleNotificationSettingsChanged,
            onError: handleNotificationSettingsError,
          );
    } catch (error) {
      log(
        'Listening to notification settings failed',
        error: error,
      );
    }
  }

  /// Applies preference changes to registration metadata and announcement topics
  void handleNotificationSettingsChanged(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    notificationSettings = data == null ? null : NotificationSettings.fromMap(data);
    registrationLocale = notificationSettings?.locale;

    unawaited(
      synchronizeRegistration(),
    );
  }

  /// Retries registration after preference synchronization errors
  void handleNotificationSettingsError(Object error) {
    log(
      'Listening to notification preferences for registration failed',
      error: error,
    );
    scheduleRegistrationRetry();
  }

  ///
  /// REGISTRATION
  ///

  /// Queues registration work so identifier and preference changes cannot race
  Future<void> synchronizeRegistration({
    String? registrationId,
    String? locale,
  }) {
    if (locale != null) {
      registrationLocale = locale;
    }

    return registrationSynchronization = registrationSynchronization.then(
      (_) => synchronizeRegistrationNow(
        registrationId: registrationId,
      ),
    );
  }

  /// Writes the latest installation metadata to its stable device document
  Future<void> synchronizeRegistrationNow({String? registrationId}) async {
    final user = auth.currentUser;

    if (!canDeliverNotifications || user == null || activeUserId != user.uid) {
      return;
    }

    try {
      if (!await hasRequiredAPNSToken()) {
        scheduleRegistrationRetry();
        return;
      }

      final currentRegistrationId = registrationId ?? activeRegistrationId;

      if (currentRegistrationId == null) {
        await messaging.register();
        scheduleRegistrationRetry();
        return;
      }

      if (currentRegistrationId.isEmpty) {
        scheduleRegistrationRetry();
        return;
      }

      final deviceId = await storage.getNotificationDeviceId();
      final locale = registrationLocale ?? notificationSettings?.locale ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode;

      final metadata = await Future.wait<Object?>([
        getAppVersion(),
        getDeviceInfo(),
        getLocalTimezoneIdentifier(
          fallback: notificationSettings?.timezone ?? 'UTC',
        ),
      ]);

      final appVersion = metadata[0] as String? ?? '--';
      final deviceInfo = metadata[1] as String? ?? '--';
      final timezone = metadata[2] as String? ?? '--';
      final deviceDocument = firestore.collection('users').doc(user.uid).collection('notificationDevices').doc(deviceId);

      final notificationDevice = NotificationDevice(
        fid: currentRegistrationId,
        locale: locale,
        timezone: timezone,
        appVersion: appVersion,
        deviceInfo: deviceInfo,
      );

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(deviceDocument);

        transaction.set(
          deviceDocument,
          notificationDevice.toMap(
            createdAt: snapshot.data()?['createdAt'] as Timestamp?,
          ),
        );
      });

      activeUserId = user.uid;
      registrationRetryAttempt = 0;
      registrationRetryTimer?.cancel();

      await synchronizeAnnouncementTopics(locale);
    } catch (error, stackTrace) {
      log(
        'Synchronizing the notification registration failed',
        error: error,
        stackTrace: stackTrace,
      );
      scheduleRegistrationRetry();
    }
  }

  /// Removes this installation from the current user's device collection
  Future<void> removeCurrentRegistration({bool unregisterMessaging = false}) async {
    final userId = auth.currentUser?.uid ?? activeUserId;

    registrationRetryTimer?.cancel();
    await unsubscribeFromAnnouncementTopics();

    if (userId != null && auth.currentUser?.uid == userId) {
      try {
        final deviceId = await storage.getNotificationDeviceId();

        await firestore.collection('users').doc(userId).collection('notificationDevices').doc(deviceId).delete();
      } catch (error, stackTrace) {
        log(
          'Removing the notification registration failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (unregisterMessaging) {
      try {
        activeRegistrationId = null;
        await messaging.unregister();
      } catch (error) {
        log(
          'Unregistering from FCM failed',
          error: error,
        );
      }
    }
  }

  /// Detaches this installation before logout or an authentication replacement
  Future<void> unregisterCurrentUser({
    bool unregisterMessaging = false,
    bool removeDocument = true,
  }) async {
    activeUserId = null;
    registrationRetryTimer?.cancel();
    registrationRetryAttempt = 0;

    await registrationSynchronization;
    await notificationSettingsSubscription?.cancel();
    notificationSettingsSubscription = null;

    if (removeDocument) {
      await removeCurrentRegistration(
        unregisterMessaging: unregisterMessaging,
      );
    } else {
      await unsubscribeFromAnnouncementTopics();

      if (unregisterMessaging) {
        try {
          activeRegistrationId = null;
          await messaging.unregister();
        } catch (error) {
          log(
            'Unregistering from FCM after authentication changed failed',
            error: error,
          );
        }
      }
    }

    notificationSettings = null;
  }

  /// Retries failed synchronization with a bounded exponential delay
  void scheduleRegistrationRetry() {
    if (!isInitialized || registrationRetryTimer?.isActive == true) {
      return;
    }

    final delayIndex = registrationRetryAttempt < registrationRetryDelays.length ? registrationRetryAttempt : registrationRetryDelays.length - 1;
    final delay = registrationRetryDelays[delayIndex];

    registrationRetryAttempt += 1;
    registrationRetryTimer = Timer(
      delay,
      () => unawaited(
        synchronizeRegistration(),
      ),
    );
  }

  /// Waits for Apple registration before using APIs that depend on the APNs token
  Future<bool> hasRequiredAPNSToken() async {
    if (!requiresAPNSToken) {
      return true;
    }

    try {
      final token = await messaging.getAPNSToken();
      return token != null;
    } catch (error, stackTrace) {
      log(
        'Reading APNs token availability failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  ///
  /// ANNOUNCEMENT TOPICS
  ///

  /// Reconciles the locale-specific announcement topic for this registration
  Future<void> synchronizeAnnouncementTopics(String locale) async {
    final desiredTopic = notificationSettings?.announcementsEnabled == true && canDeliverNotifications && auth.currentUser != null ? 'announcements_$locale' : null;

    if (!announcementTopicLoaded) {
      activeAnnouncementTopic = await storage.getNotificationAnnouncementTopic();
      announcementTopicLoaded = true;
    }

    if (announcementTopicsReconciled && activeAnnouncementTopic == desiredTopic) {
      return;
    }

    if (activeAnnouncementTopic == null && desiredTopic == null) {
      announcementTopicsReconciled = true;
      return;
    }

    if (!await hasRequiredAPNSToken()) {
      announcementTopicsReconciled = false;
      scheduleRegistrationRetry();
      return;
    }

    var operation = 'subscribe';
    var topicName = '';

    try {
      if (desiredTopic != null) {
        operation = 'subscribe';
        topicName = desiredTopic;
        await messaging.subscribeToTopic(desiredTopic);
      }

      if (activeAnnouncementTopic != null && activeAnnouncementTopic != desiredTopic) {
        operation = 'unsubscribe';
        topicName = activeAnnouncementTopic!;
        await messaging.unsubscribeFromTopic(activeAnnouncementTopic!);
      }

      operation = 'persist';
      topicName = desiredTopic ?? activeAnnouncementTopic ?? '';
      await storage.setNotificationAnnouncementTopic(desiredTopic);

      activeAnnouncementTopic = desiredTopic;
      announcementTopicsReconciled = true;
    } catch (error, stackTrace) {
      log(
        'Announcement topic $operation failed for $topicName',
        error: error,
        stackTrace: stackTrace,
      );
      scheduleRegistrationRetry();
    }
  }

  /// Removes all announcement topic memberships known by this client
  Future<void> unsubscribeFromAnnouncementTopics() async {
    if (!announcementTopicLoaded) {
      activeAnnouncementTopic = await storage.getNotificationAnnouncementTopic();
      announcementTopicLoaded = true;
    }

    final topic = activeAnnouncementTopic;

    if (topic == null) {
      announcementTopicsReconciled = false;
      return;
    }

    if (!await hasRequiredAPNSToken()) {
      activeAnnouncementTopic = null;
      announcementTopicsReconciled = false;
      await storage.setNotificationAnnouncementTopic(null);
      return;
    }

    try {
      await messaging.unsubscribeFromTopic(topic);
      await storage.setNotificationAnnouncementTopic(null);
    } catch (error, stackTrace) {
      log(
        'Unsubscribing from announcement topic $topic failed',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    activeAnnouncementTopic = null;
    announcementTopicsReconciled = false;
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
