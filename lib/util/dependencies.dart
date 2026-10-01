// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../generated/codegen_loader.g.dart';
import '../services/ai_service.dart';
import '../services/cache_service.dart';
import '../services/firebase_service.dart';
import '../services/screen_service.dart';
import '../services/speech_to_text_service.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';

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
void unRegisterIfNotDisposed<T extends Object>({
  String? instanceName,
  void Function(T controller)? afterUnregister,
}) {
  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    getIt.unregister<T>(
      disposingFunction: afterUnregister,
      instanceName: instanceName,
    );
  }
}

Future<void> initializeBeforeAppStart() async => await Future.wait(
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

/// Initialize [EasyLocalization]
Future<void> initializeLocalization() async {
  try {
    await EasyLocalization.ensureInitialized();

    final controller = EasyLocalizationController(
      useOnlyLangCode: true,
      supportedLocales: const [
        Locale('hr'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('hr'),
      saveLocale: true,
      useFallbackTranslations: true,
      assetLoader: const CodegenLoader(),
      onLoadError: (e) {},
    );

    await controller.loadTranslations();

    Localization.load(
      controller.locale,
      translations: controller.translations,
      fallbackTranslations: controller.fallbackTranslations,
    );

    await initializeDateFormatting('en');
    await initializeDateFormatting('hr');
  } catch (e) {
    return;
  }
}

Future<void> initializeFirebase() async {
  if (firebase_core.Firebase.apps.isNotEmpty) {
    return;
  }

  await firebase_core.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Registers app services and loads saved preferences before the app starts
Future<void> registerServices() async {
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
        storage: FirebaseStorage.instance,
        googleSignIn: GoogleSignIn.instance,
        cache: getIt.get<CacheService>(),
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
      SpeechToTextService.new,
    );
  }

  ///
  /// AI
  ///
  if (!getIt.isRegistered<AIService>()) {
    getIt.registerLazySingleton(
      () => AIService(
        ai: FirebaseAI.googleAI(),
      ),
    );
  }

  ///
  /// SCREEN
  ///
  if (!getIt.isRegistered<ScreenService>()) {
    getIt.registerLazySingleton(
      ScreenService.new,
    );
  }

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
