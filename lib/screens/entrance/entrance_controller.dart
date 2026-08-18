import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/firebase_service.dart';
import '../../util/email.dart';

class EntranceController
    extends
        ValueNotifier<
          ({
            bool emailValid,
            bool passwordValid,
            bool emailIsLoading,
            bool googleIsLoading,
            bool appleIsLoading,
          })
        >
    implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  EntranceController({
    required this.firebase,
  }) : super((
         emailValid: false,
         passwordValid: false,
         emailIsLoading: false,
         googleIsLoading: false,
         appleIsLoading: false,
       ));

  ///
  /// VARIABLES
  ///

  late final emailTextEditingController = TextEditingController();
  late final passwordTextEditingController = TextEditingController();

  ///
  /// INIT
  ///

  void init() {
    /// Validation
    emailTextEditingController.addListener(
      validateEmailAndPassword,
    );

    /// Validation
    passwordTextEditingController.addListener(
      validateEmailAndPassword,
    );
  }

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
  }

  ///
  /// METHODS
  ///

  /// Triggered on every [TextField] change
  /// Validates email & password
  /// Updates login button state
  void validateEmailAndPassword() {
    /// Parse values
    final email = emailTextEditingController.text.trim();
    final password = passwordTextEditingController.text.trim();

    /// Validate values
    updateState(
      emailValid: isValidEmail(email),
      passwordValid: password.length >= 8,
    );
  }

  /// Triggered when the user presses email login button
  Future<({User? user, String? error})> emailSignInPressed() async {
    final isLoading = value.emailIsLoading || value.googleIsLoading || value.appleIsLoading;

    if (isLoading) {
      return (
        user: null,
        error: 'Already loading',
      );
    }

    updateState(
      emailIsLoading: true,
    );

    final email = emailTextEditingController.text.trim();
    final password = passwordTextEditingController.text.trim();

    try {
      final loginResult = await firebase.loginUser(
        email: email,
        password: password,
      );

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
          emailIsLoading: false,
        );
      }
      /// Not successful login
      else {
        log('EntranceController -> emailSignInPressed() -> user == null');
        updateState(
          emailIsLoading: false,
        );
      }

      return loginResult;
    } catch (e) {
      log('EntranceController -> emailSignInPressed() -> $e');
      updateState(
        emailIsLoading: false,
      );
      return (user: null, error: '$e');
    }
  }

  /// Triggered when the user presses Google login button
  Future<({User? user, String? error})> googleSignInPressed() async {
    final isLoading = value.emailIsLoading || value.googleIsLoading || value.appleIsLoading;

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
    final isLoading = value.emailIsLoading || value.googleIsLoading || value.appleIsLoading;

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

  /// Updates `state`
  void updateState({
    bool? emailValid,
    bool? passwordValid,
    bool? emailIsLoading,
    bool? googleIsLoading,
    bool? appleIsLoading,
  }) => value = (
    emailValid: emailValid ?? value.emailValid,
    passwordValid: passwordValid ?? value.passwordValid,
    emailIsLoading: emailIsLoading ?? value.emailIsLoading,
    googleIsLoading: googleIsLoading ?? value.googleIsLoading,
    appleIsLoading: appleIsLoading ?? value.appleIsLoading,
  );
}
