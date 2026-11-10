import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Initializes [Firebase]
Future<void> initializeFirebase() async {
  try {
    if (firebase_core.Firebase.apps.isNotEmpty) {
      return;
    }

    await firebase_core.Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    log(
      'Firebase initialization failed',
      error: error,
    );
  }
}

/// Initializes [Firebase App Check]
Future<void> initializeFirebaseAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode ? const AppleDebugProvider() : const AppleDeviceCheckProvider(),
    );
  } catch (error) {
    log(
      'Firebase App Check initialization failed',
      error: error,
    );
  }
}
