import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

import '../models/contact_message/contact_message.dart';
import '../models/meal/ai_meal_quota_error.dart';
import '../models/meal/meal.dart';
import '../models/notification/daily_summary.dart';
import '../models/notification/notification_settings.dart';
import '../models/user_metrics/user_metrics.dart';
import '../models/weight_track/weight_track.dart';
import '../util/analytics.dart';
import '../util/crashlytics.dart';
import '../util/meal_image.dart';
import '../util/meal_parse.dart';
import '../util/timezone.dart';
import '../util/typedefs.dart';
import '../util/weight_track_parse.dart';
import 'analytics_service.dart';
import 'cache_service.dart';

enum AuthProvider {
  google,
  apple,
  email,
  anonymous,
}

class FirebaseService {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final FirebaseStorage storage;
  final GoogleSignIn googleSignIn;
  final CacheService cache;
  Future<void> Function()? beforeSignOut;
  final AnalyticsService analytics;

  FirebaseService({
    required this.auth,
    required this.firestore,
    required this.functions,
    required this.storage,
    required this.googleSignIn,
    required this.cache,
    required this.analytics,
    this.beforeSignOut,
  });

  ///
  /// INIT
  ///

  /// Resolves abandoned loading meals from the manual image flow
  void init() => deleteAbandonedManualMeals();

  ///
  /// GETTERS
  ///

  String? get userUid => auth.currentUser?.uid;
  String? get userEmail => auth.currentUser?.email;
  String? get userPhoto => auth.currentUser?.photoURL;

  /// Returns the sign-in provider for the current user
  /// Possible values: 'google.com', 'apple.com', 'password', or null
  AuthProvider? get authProvider {
    final user = auth.currentUser;

    if (user == null) {
      return null;
    }

    for (final provider in user.providerData) {
      if (provider.providerId == 'google.com') {
        return AuthProvider.google;
      }
      if (provider.providerId == 'apple.com') {
        return AuthProvider.apple;
      }
    }

    if (user.isAnonymous) {
      return AuthProvider.anonymous;
    }

    if (user.providerData.any((provider) => provider.providerId == 'password')) {
      return AuthProvider.email;
    }

    return null;
  }

  ///
  /// METHODS
  ///

  /// Returns the current user's notification preferences document
  DocumentReference<Map<String, dynamic>>? get notificationSettingsDocument {
    final user = auth.currentUser;

    if (user == null) {
      return null;
    }

    return firestore.collection('users').doc(user.uid).collection('notificationSettings').doc('preferences');
  }

  /// Fetches `NotificationSettings` updates the current `locale` and `timezone` if different
  Future<NotificationSettings> getAndRefreshNotificationSettings({
    required Locale locale,
  }) async {
    /// Get current `NotificationSettings` from [Firebase]
    final storedSettings = await getNotificationSettings();

    /// Get current `timezone`
    final timezone = await getLocalTimezoneIdentifier(
      fallback: storedSettings?.timezone ?? 'UTC',
    );

    final settings =
        storedSettings ??
        NotificationSettings.defaults(
          timezone: timezone,
          locale: locale.languageCode,
        );
    final synchronizedSettings = settings.copyWith(
      timezone: timezone,
      locale: locale.languageCode,
    );

    /// Update new `NotificationSettings` in [Firebase]
    if (storedSettings == null || storedSettings.timezone != timezone || storedSettings.locale != locale.languageCode) {
      await writeNotificationSettings(
        settings: synchronizedSettings,
      );
    }

    return synchronizedSettings;
  }

  /// Fetches notification settings for the current user
  Future<NotificationSettings?> getNotificationSettings() async {
    try {
      final document = notificationSettingsDocument;

      if (document == null) {
        return null;
      }

      final snapshot = await document.get();
      final data = snapshot.data();

      return data == null ? null : NotificationSettings.fromMap(data);
    } catch (error) {
      log(
        'Getting notification settings failed',
        error: error,
      );
      return null;
    }
  }

  /// Listens for real-time notification settings changes for the current user
  Stream<NotificationSettings?> listenToNotificationSettings() async* {
    final document = notificationSettingsDocument;

    if (document == null) {
      yield null;
      return;
    }

    try {
      await for (final snapshot in document.snapshots()) {
        final data = snapshot.data();

        yield data == null ? null : NotificationSettings.fromMap(data);
      }
    } catch (error) {
      log(
        'Listening to notification settings failed',
        error: error,
      );
      yield null;
    }
  }

  /// Writes client-managed notification preferences while preserving scheduling metadata
  Future<bool> writeNotificationSettings({required NotificationSettings settings}) async {
    try {
      final document = notificationSettingsDocument;

      if (document == null) {
        return false;
      }

      await document.set(
        settings.toMap(),
        SetOptions(merge: true),
      );

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Writing notification settings failed',
      );
      return false;
    }
  }

  /// Adds a contact message to the root `contactMessages` collection in [Firebase]
  Future<bool> writeContactMessage({required ContactMessage contactMessage}) async {
    try {
      await firestore
          .collection('contactMessages')
          .doc(contactMessage.id)
          .set(
            contactMessage.toMap(),
          );

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Writing contact message failed',
      );
      return false;
    }
  }

  /// Deletes a `contactMessage` from [Firebase]
  Future<bool> deleteContactMessage({required ContactMessage contactMessage}) async {
    try {
      await firestore
          .collection('contactMessages')
          .doc(
            contactMessage.id,
          )
          .delete();

      return true;
    } catch (error) {
      log(
        'Deleting contact message failed',
        error: error,
      );
      return false;
    }
  }

  /// Listens for real-time changes to `contactMessages` in [Firebase]
  Stream<List<ContactMessage>> listenToContactMessages() async* {
    try {
      Query<Map<String, dynamic>> query = firestore.collection('contactMessages');

      query = query.orderBy(
        'createdAt',
        descending: true,
      );

      await for (final snapshot in query.snapshots()) {
        yield snapshot.docs.map((document) {
          final data = document.data();
          final createdAt = data['createdAt'];

          return ContactMessage.fromMap(
            data,
            id: document.id,
            createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.parse(createdAt as String),
          );
        }).toList();
      }
    } catch (error) {
      log(
        'Listening to contact messages failed',
        error: error,
      );
      yield const <ContactMessage>[];
    }
  }

  /// Listens for real-time changes to the current user's `dailySummaries` in [Firebase]
  Stream<List<DailySummary>> listenToDailySummaries() async* {
    final user = auth.currentUser;

    if (user == null) {
      yield const <DailySummary>[];
      return;
    }

    try {
      final query = firestore
          .collection('users')
          .doc(user.uid)
          .collection('dailySummaries')
          .orderBy(
            'summaryAt',
            descending: true,
          );

      await for (final snapshot in query.snapshots()) {
        yield snapshot.docs
            .map(
              (document) => DailySummary.fromMap(
                document.data(),
                id: document.id,
              ),
            )
            .toList();
      }
    } catch (error) {
      log(
        'Listening to daily summaries failed',
        error: error,
      );
      yield const <DailySummary>[];
    }
  }

  /// Deletes a `dailySummary` belonging to the current user from [Firebase]
  Future<bool> deleteDailySummary({required DailySummary dailySummary}) async {
    final user = auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      await firestore.collection('users').doc(user.uid).collection('dailySummaries').doc(dailySummary.id).delete();

      return true;
    } catch (error) {
      log(
        'Deleting daily summary failed',
        error: error,
      );
      return false;
    }
  }

  /// Removes user-scoped resources before logging out of [Firebase]
  Future<void> logOut() async {
    final wasSignedIn = auth.currentUser != null;

    await beforeSignOut?.call();
    await auth.signOut();

    if (wasSignedIn) {
      unawaited(
        analytics.logLogout(),
      );
    }
  }

  /// Logs user into [Firebase]
  Future<({User? user, String? error})> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        unawaited(
          analytics.logLogin(
            method: AuthProvider.email.name,
          ),
        );
      }

      return (
        user: user,
        error: null,
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      final errorMessage = switch (error.code) {
        'invalid-email' => 'firebaseErrorEmailInvalid'.tr(),
        'user-disabled' => 'firebaseErrorUserDisabled'.tr(),
        'user-not-found' => 'firebaseErrorUserNotFound'.tr(),
        'wrong-password' => 'firebaseErrorPasswordWrong'.tr(),
        'invalid-credential' => 'firebaseErrorInvalidCredential'.tr(),
        'too-many-requests' => 'firebaseErrorTooManyRequests'.tr(),
        'operation-not-allowed' => 'firebaseErrorOperationNotAllowed'.tr(),
        _ => 'firebaseErrorLoginError'.tr(),
      };

      logFirebaseAuthFailure('Email sign in failed', error, stackTrace);
      return (
        user: null,
        error: errorMessage,
      );
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Email sign in failed',
      );
      return (
        user: null,
        error: 'firebaseErrorLoginError'.tr(),
      );
    }
  }

  /// Sends a password reset email through [Firebase]
  Future<({bool success, String? error})> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await auth.sendPasswordResetEmail(email: email);

      unawaited(
        analytics.record(
          AnalyticsEvent.passwordResetRequested,
        ),
      );

      return (
        success: true,
        error: null,
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      final errorMessage = switch (error.code) {
        'invalid-email' => 'firebaseErrorEmailInvalid'.tr(),
        'user-disabled' => 'firebaseErrorUserDisabled'.tr(),
        'user-not-found' => 'firebaseErrorUserNotFound'.tr(),
        'too-many-requests' => 'firebaseErrorTooManyRequests'.tr(),
        'operation-not-allowed' => 'firebaseErrorOperationNotAllowed'.tr(),
        _ => 'firebaseErrorPasswordResetError'.tr(),
      };

      logFirebaseAuthFailure('Password reset email failed', error, stackTrace);
      return (
        success: false,
        error: errorMessage,
      );
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Password reset email failed',
      );
      return (
        success: false,
        error: 'firebaseErrorPasswordResetError'.tr(),
      );
    }
  }

  /// Signs user in with Google and authenticates with [Firebase]
  Future<({User? user, String? error})> signInWithGoogle() async {
    try {
      await googleSignIn.initialize();

      if (!googleSignIn.supportsAuthenticate()) {
        return (
          user: null,
          error: 'firebaseErrorOperationNotAllowed'.tr(),
        );
      }

      final user = await googleSignIn.authenticate();
      final googleAuth = user.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        log('Google sign in returned no ID token');
        return (
          user: null,
          error: 'firebaseErrorInvalidCredential'.tr(),
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);

      logSocialAuthentication(
        credential: userCredential,
        provider: AuthProvider.google,
      );

      await saveUserMetadata(
        user: userCredential.user,
        providerName: user.displayName,
      );

      return (
        user: userCredential.user,
        error: null,
      );
    } on GoogleSignInException catch (error) {
      final errorMessage = switch (error.code) {
        GoogleSignInExceptionCode.unknownError => 'firebaseGoogleErrorUnknown'.tr(),
        GoogleSignInExceptionCode.canceled => 'firebaseGoogleErrorCanceled'.tr(),
        GoogleSignInExceptionCode.interrupted => 'firebaseGoogleErrorInterrupted'.tr(),
        GoogleSignInExceptionCode.clientConfigurationError => 'firebaseGoogleErrorClientConfigurationError'.tr(),
        GoogleSignInExceptionCode.providerConfigurationError => 'firebaseGoogleErrorProviderConfigurationError'.tr(),
        GoogleSignInExceptionCode.uiUnavailable => 'firebaseGoogleErrorUIUnavailable'.tr(),
        GoogleSignInExceptionCode.userMismatch => 'firebaseGoogleErrorUserMismatch'.tr(),
      };

      if (error.code != GoogleSignInExceptionCode.canceled) {
        log(
          'Google sign in failed',
          error: error.code.name,
        );
      }
      return (
        user: null,
        error: errorMessage,
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      final errorMessage = switch (error.code) {
        'account-exists-with-different-credential' => 'firebaseErrorAccountExistsWithDifferentCredential'.tr(),
        'invalid-credential' => 'firebaseErrorInvalidCredential'.tr(),
        'user-disabled' => 'firebaseErrorUserDisabled'.tr(),
        'operation-not-allowed' => 'firebaseErrorOperationNotAllowed'.tr(),
        'too-many-requests' => 'firebaseErrorTooManyRequests'.tr(),
        _ => 'firebaseGoogleErrorLoginError'.tr(),
      };

      logFirebaseAuthFailure('Google sign in failed', error, stackTrace);
      return (user: null, error: errorMessage);
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Google sign in failed',
      );
      return (
        user: null,
        error: 'firebaseGoogleErrorLoginError'.tr(),
      );
    }
  }

  /// Signs user in with Apple and authenticates with [Firebase]
  Future<({User? user, String? error})> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null || credential.identityToken!.isEmpty) {
        log('Apple sign in returned no identity token');
        return (
          user: null,
          error: 'firebaseErrorInvalidCredential'.tr(),
        );
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await auth.signInWithCredential(oauthCredential);

      logSocialAuthentication(
        credential: userCredential,
        provider: AuthProvider.apple,
      );

      final appleName =
          [
                credential.givenName,
                credential.familyName,
              ]
              .whereType<String>()
              .map(
                (part) => part.trim(),
              )
              .where(
                (part) => part.isNotEmpty,
              )
              .join(' ');

      await saveUserMetadata(
        user: userCredential.user,
        providerName: appleName,
      );

      return (
        user: userCredential.user,
        error: null,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      final errorMessage = switch (error.code) {
        AuthorizationErrorCode.canceled => 'firebaseAppleErrorCanceled'.tr(),
        AuthorizationErrorCode.failed => 'firebaseAppleErrorFailed'.tr(),
        AuthorizationErrorCode.invalidResponse => 'firebaseAppleErrorInvalidResponse'.tr(),
        AuthorizationErrorCode.notHandled => 'firebaseAppleErrorNotHandled'.tr(),
        AuthorizationErrorCode.notInteractive => 'firebaseAppleErrorNotInteractive'.tr(),
        AuthorizationErrorCode.unknown => 'firebaseAppleErrorUnknown'.tr(),
        AuthorizationErrorCode.credentialExport => 'firebaseAppleErrorCredentialExport'.tr(),
        AuthorizationErrorCode.credentialImport => 'firebaseAppleErrorCredentialImport'.tr(),
        AuthorizationErrorCode.matchedExcludedCredential => 'firebaseAppleErrorMatchedExcludedCredential'.tr(),
      };

      if (error.code != AuthorizationErrorCode.canceled) {
        log(
          'Apple sign in failed',
          error: error.code.name,
        );
      }
      return (user: null, error: errorMessage);
    } on FirebaseAuthException catch (error, stackTrace) {
      final errorMessage = switch (error.code) {
        'account-exists-with-different-credential' => 'firebaseErrorAccountExistsWithDifferentCredential'.tr(),
        'invalid-credential' => 'firebaseErrorInvalidCredential'.tr(),
        'user-disabled' => 'firebaseErrorUserDisabled'.tr(),
        'operation-not-allowed' => 'firebaseErrorOperationNotAllowed'.tr(),
        'too-many-requests' => 'firebaseErrorTooManyRequests'.tr(),
        _ => 'firebaseAppleErrorLoginError'.tr(),
      };

      logFirebaseAuthFailure('Apple sign in failed', error, stackTrace);
      return (
        user: null,
        error: errorMessage,
      );
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Apple sign in failed',
      );
      return (
        user: null,
        error: 'firebaseAppleErrorLoginError'.tr(),
      );
    }
  }

  /// Signs user in anonymously with [Firebase]
  Future<({User? user, String? error})> signInAnonymously() async {
    try {
      final userCredential = await auth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        unawaited(
          analytics.logLogin(
            method: AuthProvider.anonymous.name,
          ),
        );
      }

      return (
        user: user,
        error: null,
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      final errorMessage = switch (error.code) {
        'operation-not-allowed' => 'firebaseErrorOperationNotAllowed'.tr(),
        'too-many-requests' => 'firebaseErrorTooManyRequests'.tr(),
        _ => 'firebaseAnonymousErrorLoginError'.tr(),
      };

      logFirebaseAuthFailure('Anonymous sign in failed', error, stackTrace);
      return (
        user: null,
        error: errorMessage,
      );
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Anonymous sign in failed',
      );
      return (
        user: null,
        error: 'firebaseAnonymousErrorLoginError'.tr(),
      );
    }
  }

  /// Registers a user with email and password in [Firebase]
  Future<({User? user, String? error})> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        log('Email registration returned no user');
        return (
          user: null,
          error: 'firebaseErrorUserNull'.tr(),
        );
      }

      unawaited(
        analytics.logSignUp(
          method: AuthProvider.email.name,
        ),
      );

      await saveUserMetadata(
        user: user,
        providerName: name,
      );

      return (
        user: user,
        error: null,
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      final errorMessage = switch (error.code) {
        'email-already-in-use' => 'firebaseErrorEmailAlreadyInUse'.tr(),
        'invalid-email' => 'firebaseErrorEmailInvalid'.tr(),
        'operation-not-allowed' => 'firebaseErrorOperationNotAllowed'.tr(),
        'weak-password' => 'firebaseErrorWeakPassword'.tr(),
        'too-many-requests' => 'firebaseErrorTooManyRequests'.tr(),
        _ => 'firebaseErrorRegisterError'.tr(),
      };

      logFirebaseAuthFailure('Email registration failed', error, stackTrace);
      return (
        user: null,
        error: errorMessage,
      );
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Email registration failed',
      );
      return (
        user: null,
        error: 'firebaseErrorRegisterError'.tr(),
      );
    }
  }

  /// Records either account creation or sign-in after successful social authentication
  void logSocialAuthentication({
    required UserCredential credential,
    required AuthProvider provider,
  }) {
    if (credential.user == null) {
      return;
    }

    unawaited(
      credential.additionalUserInfo?.isNewUser == true
          ? analytics.logSignUp(
              method: provider.name,
            )
          : analytics.logLogin(
              method: provider.name,
            ),
    );
  }

  /// Logs provider codes and keeps ordinary credential rejections in debug builds
  void logFirebaseAuthFailure(String message, FirebaseAuthException error, StackTrace stackTrace) {
    final code = error.code;
    reportFirebaseOperationFailure(
      error: error,
      stackTrace: stackTrace,
      reason: message,
    );
    final isCredentialRejection = switch (code) {
      'invalid-email' || 'user-not-found' || 'wrong-password' || 'invalid-credential' || 'email-already-in-use' || 'weak-password' => true,
      _ => false,
    };

    if (!isCredentialRejection || kDebugMode) {
      log(
        message,
        level: isCredentialRejection ? 500 : 900,
        error: code,
      );
    }
  }

  /// Saves available user metadata without replacing existing values
  Future<void> saveUserMetadata({
    required User? user,
    required String? providerName,
  }) async {
    if (user == null) {
      return;
    }

    final displayName = user.displayName?.trim();
    final fallbackName = providerName?.trim();
    final name = (displayName?.isNotEmpty ?? false)
        ? displayName
        : (fallbackName?.isNotEmpty ?? false)
        ? fallbackName
        : null;

    final document = firestore.collection('users').doc(user.uid);
    final registeredAt = user.metadata.creationTime ?? DateTime.now();

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final data = snapshot.data();
      final existingUserMetrics = data != null ? UserMetrics.fromMap(data) : null;
      final existingName = existingUserMetrics?.name?.trim();
      final hasExistingName = existingName != null && existingName.isNotEmpty;
      final hasExistingRegistrationDate = existingUserMetrics?.registeredAt != null;

      if (hasExistingName && hasExistingRegistrationDate) {
        return;
      }

      final userMetrics = UserMetrics(
        registeredAt: existingUserMetrics?.registeredAt ?? registeredAt,
        name: hasExistingName ? existingName : name,
      );

      transaction.set(
        document,
        userMetrics.toMap(
          includeMetrics: false,
        ),
        SetOptions(merge: true),
      );
    });
  }

  /// Deletes the current user's data and Firebase account
  /// Email users must provide [email] and [password] for reauthentication
  Future<bool> deleteUser({
    String? email,
    String? password,
  }) async {
    var stage = 'reauthenticate';
    unawaited(
      analytics.record(
        AnalyticsEvent.accountDeletionStarted,
      ),
    );

    try {
      final user = auth.currentUser;

      if (user == null) {
        unawaited(
          analytics.record(
            AnalyticsEvent.accountDeletionFailed,
          ),
        );
        return false;
      }

      final provider = authProvider;

      final reauthenticationResult = switch (provider) {
        AuthProvider.google => (
          success: await reauthenticateWithGoogle(user),
          appleAuthorizationCode: null,
        ),

        AuthProvider.apple => await reauthenticateWithApple(user),

        AuthProvider.email => (
          success: await reauthenticateWithEmail(
            user,
            email: email,
            password: password,
          ),
          appleAuthorizationCode: null,
        ),

        AuthProvider.anonymous => (
          success: true,
          appleAuthorizationCode: null,
        ),
        null => (
          success: false,
          appleAuthorizationCode: null,
        ),
      };

      if (!reauthenticationResult.success) {
        unawaited(
          analytics.record(
            AnalyticsEvent.accountDeletionFailed,
          ),
        );

        return false;
      }

      final appleAuthorizationCode = reauthenticationResult.appleAuthorizationCode;

      if (appleAuthorizationCode != null) {
        stage = 'revoke_apple_token';
        await auth.revokeTokenWithAuthorizationCode(
          appleAuthorizationCode,
        );
      }

      if (provider == AuthProvider.google) {
        stage = 'disconnect_google';
        await googleSignIn.disconnect();
      }

      stage = 'delete_account';
      await user.delete();
      unawaited(
        analytics.logDeleteAccount(),
      );

      return true;
    } catch (error, stackTrace) {
      reportFirebaseOperationFailure(
        error: error,
        stackTrace: stackTrace,
        reason: 'account_deletion_$stage',
      );
      unawaited(
        analytics.record(
          AnalyticsEvent.accountDeletionFailed,
        ),
      );

      log(
        'User deletion failed',
        error: error,
      );
      return false;
    }
  }

  /// Reauthenticates an email/password user
  Future<bool> reauthenticateWithEmail(
    User user, {
    required String? email,
    required String? password,
  }) async {
    if (email == null || password == null) {
      log(
        'Email reauthentication failed',
        error: 'Email and password are required',
      );
      return false;
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final userCredential = await user.reauthenticateWithCredential(credential);

    return userCredential.user != null;
  }

  /// Reauthenticates a Google user
  Future<bool> reauthenticateWithGoogle(User user) async {
    await googleSignIn.initialize();

    if (!googleSignIn.supportsAuthenticate()) {
      return false;
    }

    final googleUser = await googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      return false;
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await user.reauthenticateWithCredential(credential);

    return userCredential.user != null;
  }

  /// Reauthenticates an Apple user and returns Apple authorization code
  Future<ReauthenticationResult> reauthenticateWithApple(User user) async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final identityToken = appleCredential.identityToken;

    if (identityToken == null || identityToken.isEmpty) {
      return (
        success: false,
        appleAuthorizationCode: null,
      );
    }

    final credential = OAuthProvider('apple.com').credential(
      idToken: identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final userCredential = await user.reauthenticateWithCredential(credential);

    return (
      success: userCredential.user != null,
      appleAuthorizationCode: appleCredential.authorizationCode,
    );
  }

  ///
  /// USER METRICS
  ///

  /// Fetches `userMetrics` from the current user's document in [Firebase]
  Future<UserMetrics?> getUserMetrics() async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return null;
      }

      final snapshot = await firestore.collection('users').doc(user.uid).get();
      final data = snapshot.data();

      if (data == null) {
        return null;
      }

      return UserMetrics.fromMap(data);
    } catch (error) {
      log(
        'Getting user metrics failed',
        error: error,
      );
      return null;
    }
  }

  /// Listens for real-time changes to `userMetrics` in the current user's document in [Firebase]
  Stream<UserMetrics?> listenToUserMetrics() async* {
    final user = auth.currentUser;

    if (user == null) {
      yield null;
      return;
    }

    try {
      final document = firestore.collection('users').doc(user.uid);

      await for (final snapshot in document.snapshots()) {
        final data = snapshot.data();

        if (data == null) {
          yield null;
          continue;
        }

        yield UserMetrics.fromMap(data);
      }
    } catch (error) {
      log(
        'Listening to user metrics failed',
        error: error,
      );
      yield null;
    }
  }

  /// Writes `userMetrics` to the current user's document in [Firebase]
  Future<bool> writeUserMetrics({required UserMetrics newUserMetrics}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final document = firestore.collection('users').doc(user.uid);

      await document.set(
        newUserMetrics.toMap(),
        SetOptions(merge: true),
      );

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Writing user metrics failed',
      );
      return false;
    }
  }

  /// Updates only the `name` in the current user's document in [Firebase]
  Future<bool> updateUserName({required String newName}) async {
    final name = newName.trim();
    if (name.isEmpty) {
      return false;
    }

    try {
      final user = auth.currentUser;
      if (user == null) {
        return false;
      }

      final userMetrics = UserMetrics(
        name: name,
      );

      await firestore
          .collection('users')
          .doc(user.uid)
          .set(
            userMetrics.toMap(
              includeMetrics: false,
            ),
            SetOptions(merge: true),
          );

      return true;
    } catch (error) {
      log(
        'Updating user name failed',
        error: error,
      );
      return false;
    }
  }

  /// Updates `userMetrics` in the current user's document in [Firebase]
  Future<bool> updateUserMetrics({required UserMetrics newUserMetrics}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final document = firestore.collection('users').doc(user.uid);

      await document.set(
        newUserMetrics.toMap(),
        SetOptions(merge: true),
      );

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Updating user metrics failed',
      );
      return false;
    }
  }

  /// Deletes `userMetrics` from the current user's document in [Firebase]
  Future<bool> deleteUserMetrics({
    required bool onlyMetricsAndMacros,
    required bool onlyMacros,
  }) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final document = firestore.collection('users').doc(user.uid);

      if (onlyMacros) {
        await document.update({
          'dailyCalories': FieldValue.delete(),
          'dailyProtein': FieldValue.delete(),
          'dailyCarbs': FieldValue.delete(),
          'dailyFat': FieldValue.delete(),
        });
      } else if (onlyMetricsAndMacros) {
        await document.update({
          'age': FieldValue.delete(),
          'gender': FieldValue.delete(),
          'height': FieldValue.delete(),
          'weight': FieldValue.delete(),
          'dailyCalories': FieldValue.delete(),
          'dailyProtein': FieldValue.delete(),
          'dailyCarbs': FieldValue.delete(),
          'dailyFat': FieldValue.delete(),
        });
      } else {
        await document.delete();
      }

      return true;
    } catch (error) {
      log(
        'Deleting user metrics failed',
        error: error,
      );
      return false;
    }
  }

  ///
  /// MEALS
  ///

  /// Deletes unfinished manual meals without touching backend AI jobs
  Future<void> deleteAbandonedManualMeals() async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return;
      }

      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('meals')
          .where(
            'isLoading',
            isEqualTo: true,
          )
          .get(
            const GetOptions(
              source: Source.server,
            ),
          );
      final manualDocuments = snapshot.docs.where(
        (document) => document.data()['methodOfCreation'] == 'manual',
      );

      for (var offset = 0; offset < manualDocuments.length; offset += 300) {
        final batch = firestore.batch();

        for (final document in manualDocuments.skip(offset).take(300)) {
          batch.delete(document.reference);
        }

        await batch.commit();
      }
    } catch (error) {
      log(
        'Deleting abandoned manual meals failed',
        error: error,
      );
    }
  }

  /// Fetches `meals` from [Firebase]
  Future<List<Meal>?> getMeals({required String languageCode}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return null;
      }

      Query<Map<String, dynamic>> query = firestore.collection('users').doc(user.uid).collection('meals');

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (document) => parseMealDocument(
              document,
              languageCode: languageCode,
            ),
          )
          .whereType<Meal>()
          .toList();
    } catch (error) {
      log(
        'Getting meals failed',
        error: error,
      );
      return null;
    }
  }

  /// Listens for real-time changes to `meals` created on [date] in [Firebase]
  Stream<List<Meal>> listenToMeals({
    required DateTime date,
    required String languageCode,
  }) async* {
    final user = auth.currentUser;

    if (user == null) {
      throw StateError('User is not authenticated');
    }

    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfNextDay = DateTime(date.year, date.month, date.day + 1);

    Query<Map<String, dynamic>> query = firestore.collection('users').doc(user.uid).collection('meals');

    query = query
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(startOfNextDay),
        )
        .orderBy('createdAt', descending: true);

    await for (final snapshot in query.snapshots()) {
      yield snapshot.docs
          .map(
            (document) => parseMealDocument(
              document,
              languageCode: languageCode,
            ),
          )
          .whereType<Meal>()
          .toList();
    }
  }

  /// Adds a new `meal` into [Firebase]
  Future<bool> writeMeal({
    required Meal newMeal,
    bool preserveLocalizedData = false,
  }) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final collection = firestore.collection('users').doc(user.uid).collection('meals');

      final mealData = preserveLocalizedData && newMeal.localizedData != null ? newMeal.toLocalizedMap() : newMeal.toMap();

      await collection.doc(newMeal.id).set(mealData);

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Writing meal failed',
      );
      return false;
    }
  }

  /// Adds a loading meal before invoking backend AI generation
  Future<bool> writeAIMealRequest({
    required Meal newMeal,
    required String languageCode,
  }) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final document = firestore.collection('users').doc(user.uid).collection('meals').doc(newMeal.id);

      await document.set({
        ...newMeal.toMap(),
        'aiGenerationLanguage': languageCode,
        'aiGenerationRequestedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Writing AI meal request failed',
      );
      return false;
    }
  }

  /// Sends the meal to the callable and reads metrics from a successful response
  Future<({bool pending, MealSaveFailure? failure, AIMealGenerationMetrics? metrics})> generateAIMeal({
    required String mealId,
    required String languageCode,
    required File? imageFile,
  }) async {
    String? imageBase64;
    String? imageBlurHash;

    if (imageFile != null) {
      try {
        const maximumImageBytes = 5 * 1024 * 1024;
        final imageBytesFuture = imageFile.readAsBytes();
        final imageBlurHashFuture = generateMealImageBlurHash(imageFile);
        final imageBytes = await imageBytesFuture;

        imageBlurHash = await imageBlurHashFuture;

        if (imageBytes.isEmpty || imageBytes.length > maximumImageBytes) {
          log(
            'AI meal image rejected before calling Firebase',
            error: 'reason=${imageBytes.isEmpty ? 'empty_image' : 'image_too_large'}, bytes=${imageBytes.length}',
          );

          return (
            pending: false,
            failure: MealSaveFailure.imageUpload,
            metrics: null,
          );
        }

        imageBase64 = base64Encode(imageBytes);
      } catch (error) {
        log(
          'Preparing AI meal image failed',
          error: error.runtimeType,
        );

        return (
          pending: false,
          failure: MealSaveFailure.imageUpload,
          metrics: null,
        );
      }
    }

    try {
      final response = await functions.httpsCallable('generateAIMeal').call({
        'mealId': mealId,
        'languageCode': languageCode,
        'imageBase64': imageBase64,
        'imageContentType': imageFile == null ? null : 'image/webp',
        'imageBlurHash': imageBlurHash,
      });
      final data = response.data;

      if (data is! Map || data['success'] is! bool) {
        reportHandledError(
          error: const FormatException(),
          stackTrace: StackTrace.current,
          reason: 'invalid_ai_meal_response',
        );
      }

      if (data is Map && data['success'] == true) {
        final metrics = switch (data['metrics']) {
          {
            'attempt': final int attempt,
            'model': final String model,
            'durationMs': final int durationMs,
            'backendDurationMs': final int backendDurationMs,
            'foodCount': final int foodCount,
          } =>
            (
              attempt: attempt,
              model: model,
              durationMs: durationMs,
              backendDurationMs: backendDurationMs,
              foodCount: foodCount,
            ),
          _ => null,
        };

        return (
          pending: data['pending'] == true,
          failure: null,
          metrics: metrics,
        );
      }

      final reason = data is Map ? data['failureReason'] : null;
      final failure = switch (reason) {
        'image_upload' => MealSaveFailure.imageUpload,
        'persistence' => MealSaveFailure.persistence,
        'validation' => MealSaveFailure.validation,
        _ => MealSaveFailure.generation,
      };

      return (
        pending: false,
        failure: failure,
        metrics: null,
      );
    } on FirebaseFunctionsException catch (error, stackTrace) {
      if (error.code == 'resource-exhausted') {
        final quotaError = AIMealQuotaError.tryParse(error.details);

        if (quotaError != null) {
          throw quotaError;
        }
      }

      reportFirebaseOperationFailure(
        error: error,
        stackTrace: stackTrace,
        reason: 'generate_ai_meal',
      );
      log(
        'AI meal callable request failed',
        error: error.code,
      );

      return (
        pending: false,
        failure: MealSaveFailure.request,
        metrics: null,
      );
    } catch (error, stackTrace) {
      reportFirebaseOperationFailure(
        error: error,
        stackTrace: stackTrace,
        reason: 'generate_ai_meal',
      );
      log(
        'AI meal callable request failed',
        error: error.runtimeType,
      );

      return (
        pending: false,
        failure: MealSaveFailure.request,
        metrics: null,
      );
    }
  }

  /// Updates a `meal` in [Firebase]
  Future<bool> updateMeal({required Meal newMeal}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final collection = firestore.collection('users').doc(user.uid).collection('meals');

      await collection.doc(newMeal.id).set(newMeal.toLocalizedMap());

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Updating meal failed',
      );
      return false;
    }
  }

  /// Updates only a meal's shared creation date while preserving localized data
  Future<bool> updateMealDateTime({
    required String mealId,
    required DateTime createdAt,
  }) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final document = firestore.collection('users').doc(user.uid).collection('meals').doc(mealId);

      await document.update({
        'createdAt': Timestamp.fromDate(createdAt),
      });

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Updating meal date and time failed',
      );
      return false;
    }
  }

  /// Deletes a `meal` from [Firebase]
  Future<bool> deleteMeal({required Meal meal}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final collection = firestore.collection('users').doc(user.uid).collection('meals');

      await collection.doc(meal.id).delete();

      unawaited(
        analytics.record(
          AnalyticsEvent.mealDeleted,
        ),
      );

      if (meal.imageStoragePath != null) {
        return await deleteMealImageIfUnused(
          imageStoragePath: meal.imageStoragePath!,
        );
      }

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Deleting meal failed',
      );
      return false;
    }
  }

  ///
  /// MEAL IMAGE
  ///

  /// Deletes a stored image only when no saved meal references it
  Future<bool> deleteMealImageIfUnused({required String imageStoragePath}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      /// Check all `meals` before deleting image
      final mealsUsingImage = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('meals')
          .where(
            'imageStoragePath',
            isEqualTo: imageStoragePath,
          )
          .limit(1)
          .get(
            const GetOptions(
              source: Source.server,
            ),
          );

      if (mealsUsingImage.docs.isNotEmpty) {
        return true;
      }

      return await deleteMealImage(
        imageStoragePath: imageStoragePath,
      );
    } catch (error) {
      log(
        'Deleting unused meal image failed',
        error: error,
      );
      return false;
    }
  }

  /// Uploads a meal image and returns its `Storage` path with an optional `BlurHash`
  Future<MealImageUploadResult?> uploadMealImage({
    required File imageFile,
  }) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return null;
      }

      final imageId = const Uuid().v1();
      final ext = mealImageExtension(imageFile);
      final storagePath = 'users/${user.uid}/meal-images/$imageId.$ext';
      final imageReference = storage.ref(storagePath);
      final imageBlurHashFuture = generateMealImageBlurHash(imageFile);

      await imageReference.putFile(
        imageFile,
        SettableMetadata(
          contentType: mealImageContentType(ext),
          customMetadata: {
            'imageId': imageId,
            'userId': user.uid,
          },
        ),
      );

      return (
        imageStoragePath: storagePath,
        imageBlurHash: await imageBlurHashFuture,
      );
    } on FirebaseException catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Uploading meal image failed',
      );
      return null;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Uploading meal image failed',
      );
      return null;
    }
  }

  /// Deletes an uploaded meal image when it is no longer needed
  Future<bool> deleteMealImage({required String imageStoragePath}) async {
    try {
      await storage.ref(imageStoragePath).delete();

      await cache.removeMealImageDownloadUrl(
        imageStoragePath: imageStoragePath,
      );

      return true;
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        await cache.removeMealImageDownloadUrl(
          imageStoragePath: imageStoragePath,
        );

        return true;
      }

      log(
        'Deleting meal image failed',
        error: error,
      );
      return false;
    } catch (error) {
      log(
        'Deleting meal image failed',
        error: error,
      );
      return false;
    }
  }

  ///
  /// WEIGHT TRACKS
  ///

  /// Listens to the latest ordered page of `weightTracks` from [Firebase]
  Stream<List<WeightTrack>?> listenToLatestWeightTracks({
    required int pageSize,
  }) async* {
    try {
      final user = auth.currentUser;

      if (user == null) {
        yield null;
        return;
      }

      Query<Map<String, dynamic>> query = firestore.collection('users').doc(user.uid).collection('weightTracks');

      query = query.orderBy('dateTime', descending: true);
      query = query.orderBy(FieldPath.documentId, descending: true);

      await for (final snapshot in query.limit(pageSize).snapshots()) {
        yield snapshot.docs.map(parseWeightTrackDocument).whereType<WeightTrack>().toList();
      }
    } catch (error) {
      log(
        'Listening to latest weight tracks failed',
        error: error,
      );
      yield null;
    }
  }

  /// Fetches one ordered page of `weightTracks` from [Firebase]
  Future<({List<WeightTrack> weightTracks, WeightTrack? cursor, bool hasMore})?> getWeightTracksPage({
    required int pageSize,
    WeightTrack? startAfterWeightTrack,
  }) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return null;
      }

      Query<Map<String, dynamic>> query = firestore.collection('users').doc(user.uid).collection('weightTracks');

      query = query.orderBy('dateTime', descending: true);
      query = query.orderBy(FieldPath.documentId, descending: true);

      if (startAfterWeightTrack != null) {
        query = query.startAfter([
          Timestamp.fromDate(startAfterWeightTrack.dateTime),
          startAfterWeightTrack.id,
        ]);
      }

      final snapshot = await query.limit(pageSize).get();
      final weightTracks = snapshot.docs.map(parseWeightTrackDocument).whereType<WeightTrack>().toList();

      return (
        weightTracks: weightTracks,
        cursor: weightTracks.lastOrNull,
        hasMore: snapshot.docs.length == pageSize,
      );
    } catch (error) {
      log(
        'Getting weight tracks page failed',
        error: error,
      );
      return null;
    }
  }

  /// Adds a new `weightTrack` into [Firebase]
  Future<bool> writeWeightTrack({required WeightTrack newWeightTrack}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final collection = firestore.collection('users').doc(user.uid).collection('weightTracks');

      await collection.doc(newWeightTrack.id).set(newWeightTrack.toMap());

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Writing weight track failed',
      );
      return false;
    }
  }

  /// Updates a `weightTrack` in [Firebase]
  Future<bool> updateWeightTrack({required WeightTrack newWeightTrack}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final collection = firestore.collection('users').doc(user.uid).collection('weightTracks');

      await collection.doc(newWeightTrack.id).set(newWeightTrack.toMap());

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Updating weight track failed',
      );
      return false;
    }
  }

  /// Deletes a `weightTrack` from [Firebase]
  Future<bool> deleteWeightTrack({required WeightTrack weightTrack}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final collection = firestore.collection('users').doc(user.uid).collection('weightTracks');

      await collection.doc(weightTrack.id).delete();

      return true;
    } catch (error, stackTrace) {
      logAndReportFirebaseFailure(
        error: error,
        stackTrace: stackTrace,
        message: 'Deleting weight track failed',
      );
      return false;
    }
  }

  /// Logs an operation failure and reports it when it indicates an unexpected problem
  void logAndReportFirebaseFailure({
    required Object error,
    required StackTrace stackTrace,
    required String message,
  }) {
    log(
      message,
      error: error,
    );
    reportFirebaseOperationFailure(
      error: error,
      stackTrace: stackTrace,
      reason: message,
    );
  }

  /// Reports app errors and SDK codes that indicate a backend or configuration problem
  void reportFirebaseOperationFailure({
    required Object error,
    required StackTrace stackTrace,
    required String reason,
  }) {
    if (error is SocketException || error is TimeoutException) {
      return;
    }

    final code = error is FirebaseException ? error.code : null;
    const reportableCodes = {
      'data-loss',
      'failed-precondition',
      'internal',
      'internal-error',
      'operation-not-allowed',
      'permission-denied',
      'unauthorized',
    };

    if (code != null && !reportableCodes.contains(code)) {
      return;
    }

    reportHandledError(
      error: error,
      stackTrace: stackTrace,
      reason: reason,
      information: [if (code != null) 'firebase_code=$code'],
    );
  }
}
