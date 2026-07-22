import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';

class EntranceController extends ValueNotifier<({bool googleIsLoading, bool appleIsLoading, bool anonymousIsLoading})> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  EntranceController({
    required this.firebase,
  }) : super((
         googleIsLoading: false,
         appleIsLoading: false,
         anonymousIsLoading: false,
       ));

  ///
  /// METHODS
  ///

  /// Triggered when the user presses Google login button
  Future<({User? user, String? error})> googleSignInPressed() async {
    final isLoading = value.googleIsLoading || value.appleIsLoading || value.anonymousIsLoading;

    if (isLoading) {
      return (
        user: null,
        error: 'Already loading',
      );
    }

    updateState(
      googleIsLoading: true,
    );

    try {
      final loginResult = await firebase.signInWithGoogle();

      /// Successful login
      if (loginResult.user != null && loginResult.error == null) {
        /// Store `isLoggedIn` into [Hive]
        // await hive.writeSettings(
        //   hive.getSettings().copyWith(
        //     isLoggedIn: true,
        //   ),
        // );

        /// Fetch all data from [Firebase] & store into [Hive]
        // await getFirebaseDataIntoHive();

        updateState(
          googleIsLoading: false,
        );
      }
      /// Not successful login
      else {
        log('EntranceController -> googleSignInPressed() -> user == null');
        updateState(
          googleIsLoading: false,
        );
      }

      return loginResult;
    } catch (e) {
      log('EntranceController -> googleSignInPressed() -> $e');
      updateState(
        googleIsLoading: false,
      );
      return (user: null, error: '$e');
    }
  }

  /// Triggered when the user presses Apple login button
  Future<({User? user, String? error})> appleSignInPressed() async {
    final isLoading = value.googleIsLoading || value.appleIsLoading || value.anonymousIsLoading;

    if (isLoading) {
      return (
        user: null,
        error: 'Already loading',
      );
    }

    updateState(
      appleIsLoading: true,
    );

    try {
      final loginResult = await firebase.signInWithApple();

      /// Successful login
      if (loginResult.user != null && loginResult.error == null) {
        /// Store `isLoggedIn` into [Hive]
        // await hive.writeSettings(
        //   hive.getSettings().copyWith(
        //     isLoggedIn: true,
        //   ),
        // );

        /// Fetch all data from [Firebase] & store into [Hive]
        // await getFirebaseDataIntoHive();

        updateState(
          appleIsLoading: false,
        );
      }
      /// Not successful login
      else {
        log('EntranceController -> appleSignInPressed() -> user == null');
        updateState(
          appleIsLoading: false,
        );
      }

      return loginResult;
    } catch (e) {
      log('EntranceController -> appleSignInPressed() -> $e');
      updateState(
        appleIsLoading: false,
      );
      return (user: null, error: '$e');
    }
  }

  /// Triggered when the user presses anonymous login button
  Future<({User? user, String? error})> anonymousSignInPressed() async {
    final isLoading = value.googleIsLoading || value.appleIsLoading || value.anonymousIsLoading;

    if (isLoading) {
      return (
        user: null,
        error: 'Already loading',
      );
    }

    updateState(
      anonymousIsLoading: true,
    );

    try {
      final loginResult = await firebase.signInAnonymously();

      /// Successful login
      if (loginResult.user != null && loginResult.error == null) {
        /// Store `isLoggedIn` into [Hive]
        // await hive.writeSettings(
        //   hive.getSettings().copyWith(
        //     isLoggedIn: true,
        //   ),
        // );

        /// Fetch all data from [Firebase] & store into [Hive]
        // await getFirebaseDataIntoHive();

        updateState(
          anonymousIsLoading: false,
        );
      }
      /// Not successful login
      else {
        log('EntranceController -> anonymousSignInPressed() -> user == null');
        updateState(
          anonymousIsLoading: false,
        );
      }

      return loginResult;
    } catch (e) {
      log('EntranceController -> anonymousSignInPressed() -> $e');
      updateState(
        anonymousIsLoading: false,
      );
      return (user: null, error: '$e');
    }
  }

  /// Updates `state`
  void updateState({
    bool? googleIsLoading,
    bool? appleIsLoading,
    bool? anonymousIsLoading,
  }) => value = (
    googleIsLoading: googleIsLoading ?? value.googleIsLoading,
    appleIsLoading: appleIsLoading ?? value.appleIsLoading,
    anonymousIsLoading: anonymousIsLoading ?? value.anonymousIsLoading,
  );
}
