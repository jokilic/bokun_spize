import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../services/ai_service.dart';
import '../services/cache_service.dart';
import '../services/firebase_service.dart';
import '../services/screen_service.dart';
import '../services/speech_to_text_service.dart';
import '../services/storage_service.dart';

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
    initializeDateFormatting('en'),
    initializeFirebase(),
  ],
);

Future<void> initializeFirebase() async {
  if (firebase_core.Firebase.apps.isNotEmpty) {
    return;
  }

  await firebase_core.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Registers app services without performing feature-specific startup work
void registerServices() {
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
    );
  }

  ///
  /// STORAGE
  ///
  if (!getIt.isRegistered<StorageService>()) {
    getIt.registerLazySingleton(
      () => StorageService(
        sharedPreferences: SharedPreferencesAsync(),
      ),
      onCreated: (storage) => storage.init(),
    );
  }

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
        firebaseService: getIt.get<FirebaseService>(),
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
}
