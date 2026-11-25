import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/analytics_service.dart';
import '../services/cache_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/screen_service.dart';
import '../services/speech_to_text_service.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import 'firebase.dart';
import 'localization.dart';

final getIt = GetIt.instance;

/// Registers a class if it's not already initialized
/// Optionally runs a function with newly registered class
T registerIfNotInitialized<T extends Object>(
  T Function() factoryFunc, {
  String? instanceName,
  void Function(T controller)? afterRegister,
}) {
  if (!getIt.isRegistered<T>(instanceName: instanceName)) {
    getIt.registerLazySingleton<T>(
      factoryFunc,
      instanceName: instanceName,
      onCreated: afterRegister != null ? (instance) => afterRegister(instance) : null,
    );
  }

  return getIt.get<T>(instanceName: instanceName);
}

/// Unregisters a class if it's not already disposed
/// Optionally runs a function with newly unregistered class
Future<void> unRegisterIfNotDisposed<T extends Object>({
  String? instanceName,
  void Function(T controller)? afterUnregister,
}) async {
  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    await getIt.unregister<T>(
      disposingFunction: afterUnregister,
      instanceName: instanceName,
    );
  }
}

/// Initializes app dependencies
Future<void> initializeBeforeAppStart() async {
  await Future.wait(
    [
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      ),
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      ),
      initializeLocalization(),
      initializeFirebase(),
    ],
  );

  await initializeFirebaseAppCheck();
}

/// Registers app services and loads saved preferences before the app starts
Future<void> registerServices() async {
  ///
  /// ANALYTICS
  ///
  if (!getIt.isRegistered<AnalyticsService>()) {
    getIt.registerLazySingleton(
      () => AnalyticsService(
        analytics: FirebaseAnalytics.instance,
      ),
    );
  }

  ///
  /// CACHE
  ///
  if (!getIt.isRegistered<CacheService>()) {
    getIt.registerLazySingleton(
      () => CacheService(
        storage: FirebaseStorage.instance,
        imageCacheManager: CachedNetworkImageProvider.defaultCacheManager,
      ),
    );
  }

  ///
  /// FIREBASE
  ///
  if (!getIt.isRegistered<FirebaseService>()) {
    getIt.registerLazySingleton(
      () => FirebaseService(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instanceFor(
          region: 'europe-west8',
        ),
        storage: FirebaseStorage.instance,
        googleSignIn: GoogleSignIn.instance,
        cache: getIt.get<CacheService>(),
        analytics: getIt.get<AnalyticsService>(),
      ),
      onCreated: (service) => service.init(),
    );
  }

  ///
  /// STORAGE
  ///
  if (!getIt.isRegistered<StorageService>()) {
    getIt.registerLazySingletonAsync<StorageService>(
      () async {
        final storage = StorageService(
          sharedPreferences: SharedPreferencesAsync(),
        );
        await storage.init();
        return storage;
      },
    );
  }

  /// Load `StorageService` so `ThemeService` can access it synchronously
  await getIt.getAsync<StorageService>();

  ///
  /// SPEECH TO TEXT
  ///
  if (!getIt.isRegistered<SpeechToTextService>()) {
    getIt.registerLazySingleton(
      () => SpeechToTextService(
        analytics: getIt.get<AnalyticsService>(),
      ),
    );
  }

  ///
  /// SCREEN
  ///
  if (!getIt.isRegistered<ScreenService>()) {
    getIt.registerLazySingleton(
      () => ScreenService(
        analytics: getIt.get<AnalyticsService>(),
      ),
    );
  }

  ///
  /// NOTIFICATIONS
  ///
  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerLazySingletonAsync<NotificationService>(
      () async {
        final notification = NotificationService(
          messaging: FirebaseMessaging.instance,
          auth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
          storage: getIt.get<StorageService>(),
          screen: getIt.get<ScreenService>(),
          analytics: getIt.get<AnalyticsService>(),
          openedMessages: FirebaseMessaging.onMessageOpenedApp,
          openSystemSettingsCallback: openAppSettings,
        );

        await notification.init();

        getIt.get<FirebaseService>().beforeSignOut = () => notification.unregisterCurrentUser(
          unregisterMessaging: true,
        );

        return notification;
      },
    );
  }

  /// Load `NotificationService` so message handlers are ready before `runApp`
  await getIt.getAsync<NotificationService>();

  ///
  /// THEME
  ///
  if (!getIt.isRegistered<ThemeService>()) {
    getIt.registerLazySingleton(
      () => ThemeService(
        storage: getIt.get<StorageService>(),
      ),
    );
  }
}
