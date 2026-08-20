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
            bool loginEmailValid,
            bool loginPasswordValid,
            bool registerEmailValid,
            bool registerPasswordValid,
            bool registerNameValid,
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
         loginEmailValid: false,
         loginPasswordValid: false,
         registerEmailValid: false,
         registerPasswordValid: false,
         registerNameValid: false,
         emailIsLoading: false,
         googleIsLoading: false,
         appleIsLoading: false,
       ));

  ///
  /// VARIABLES
  ///

  late final loginEmailTextEditingController = TextEditingController();
  late final loginPasswordTextEditingController = TextEditingController();

  late final registerEmailTextEditingController = TextEditingController();
  late final registerPasswordTextEditingController = TextEditingController();
  late final registerNameTextEditingController = TextEditingController();

  ///
  /// INIT
  ///

  void init() {
    /// Validation listeners
    loginEmailTextEditingController.addListener(
      validateTextFields,
    );
    loginPasswordTextEditingController.addListener(
      validateTextFields,
    );

    registerEmailTextEditingController.addListener(
      validateTextFields,
    );
    registerPasswordTextEditingController.addListener(
      validateTextFields,
    );
    registerNameTextEditingController.addListener(
      validateTextFields,
    );
  }

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    loginEmailTextEditingController.dispose();
    loginPasswordTextEditingController.dispose();

    registerEmailTextEditingController.dispose();
    registerPasswordTextEditingController.dispose();
    registerNameTextEditingController.dispose();
  }

  ///
  /// METHODS
  ///

  /// Triggered on every [TextField] change
  /// Validates values
  /// Updates login / register button state
  void validateTextFields() {
    /// Parse login values
    final loginEmail = loginEmailTextEditingController.text.trim();
    final loginPassword = loginPasswordTextEditingController.text.trim();

    /// Parse register values
    final registerEmail = registerEmailTextEditingController.text.trim();
    final registerPassword = registerPasswordTextEditingController.text.trim();
    final registerName = registerNameTextEditingController.text.trim();

    /// Validate values
    updateState(
      loginEmailValid: isValidEmail(loginEmail),
      loginPasswordValid: loginPassword.length >= 8,
      registerEmailValid: isValidEmail(registerEmail),
      registerPasswordValid: registerPassword.length >= 8,
      registerNameValid: registerName.isNotEmpty,
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

    /// Get relevant values
    final email = loginEmailTextEditingController.text.trim();
    final password = loginPasswordTextEditingController.text.trim();

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

  // TODO: Implement `forgetPasswordPressed()`

  /// Triggered when the user presses email register button
  Future<({User? user, String? error})> emailRegisterPressed() async {
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

    /// Get relevant values
    final email = registerEmailTextEditingController.text.trim();
    final password = registerPasswordTextEditingController.text.trim();
    final name = registerNameTextEditingController.text.trim();

    try {
      final registerResult = await firebase.registerUser(
        email: email,
        password: password,
        name: name,
      );

      /// Successful registration
      if (registerResult.user != null && registerResult.error == null) {
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
      /// Not successful registration
      else {
        log('EntranceController -> emailRegisterPressed() -> user == null');
        updateState(
          emailIsLoading: false,
        );
      }

      return registerResult;
    } catch (e) {
      log('EntranceController -> emailRegisterPressed() -> $e');
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
    bool? loginEmailValid,
    bool? loginPasswordValid,
    bool? registerEmailValid,
    bool? registerPasswordValid,
    bool? registerNameValid,
    bool? emailIsLoading,
    bool? googleIsLoading,
    bool? appleIsLoading,
  }) => value = (
    loginEmailValid: loginEmailValid ?? value.loginEmailValid,
    loginPasswordValid: loginPasswordValid ?? value.loginPasswordValid,
    registerEmailValid: registerEmailValid ?? value.registerEmailValid,
    registerPasswordValid: registerPasswordValid ?? value.registerPasswordValid,
    registerNameValid: registerNameValid ?? value.registerNameValid,
    emailIsLoading: emailIsLoading ?? value.emailIsLoading,
    googleIsLoading: googleIsLoading ?? value.googleIsLoading,
    appleIsLoading: appleIsLoading ?? value.appleIsLoading,
  );
}
