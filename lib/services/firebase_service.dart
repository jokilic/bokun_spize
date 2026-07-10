import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthProvider {
  google,
  apple,
  anonymous,
}

class FirebaseService {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  FirebaseService({
    required this.auth,
    required this.firestore,
    required this.googleSignIn,
  });

  ///
  /// GETTERS
  ///

  String? get userEmail => auth.currentUser?.email;

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

    return AuthProvider.anonymous;
  }

  ///
  /// METHODS
  ///

  /// Logs user out of [Firebase]
  void logOut() => auth.signOut();

  /// Logs user into [Firebase]
  Future<({User? user, String? error})> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return (user: user.user, error: null);
    } on FirebaseAuthException catch (e) {
      final error = switch (e.code) {
        'invalid-email' => 'errorEmailInvalid',
        'user-disabled' => 'errorAccountDisabled',
        'user-not-found' => 'errorUserNotFound',
        'wrong-password' => 'errorPasswordWrong',
        'invalid-credential' => 'errorInvalidCredential',
        'too-many-requests' => 'errorTooManyRequests',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        _ => e.code,
      };

      log(error);
      return (user: null, error: error);
    } catch (e) {
      final error = 'Login error $e';
      log(error);
      return (user: null, error: error);
    }
  }

  /// Signs user in with Google and authenticates with [Firebase]
  Future<({User? user, String? error})> signInWithGoogle() async {
    try {
      await googleSignIn.initialize();

      if (!googleSignIn.supportsAuthenticate()) {
        return (user: null, error: 'errorOperationNotAllowed');
      }

      final user = await googleSignIn.authenticate();
      final googleAuth = user.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        return (user: null, error: 'errorInvalidCredential');
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);

      return (user: userCredential.user, error: null);
    } on GoogleSignInException catch (e) {
      final error = switch (e.code) {
        GoogleSignInExceptionCode.unknownError => 'errorUnknown',
        GoogleSignInExceptionCode.canceled => 'errorGoogleCanceled',
        GoogleSignInExceptionCode.interrupted => 'errorGoogleInterrupted',
        GoogleSignInExceptionCode.clientConfigurationError => 'errorGoogleClientConfigurationError',
        GoogleSignInExceptionCode.providerConfigurationError => 'errorGoogleProviderConfigurationError',
        GoogleSignInExceptionCode.uiUnavailable => 'errorGoogleUIUnavailable',
        GoogleSignInExceptionCode.userMismatch => 'errorGoogleUserMismatch',
      };

      log('GoogleSignInException ${e.code}: ${e.description}');
      return (user: null, error: error);
    } on FirebaseAuthException catch (e) {
      final error = switch (e.code) {
        'account-exists-with-different-credential' => 'errorInvalidCredential',
        'invalid-credential' => 'errorInvalidCredential',
        'user-disabled' => 'errorAccountDisabled',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        'too-many-requests' => 'errorTooManyRequests',
        _ => e.code,
      };

      log(error);
      return (user: null, error: error);
    } catch (e) {
      final error = 'Google sign-in error $e';
      log(error);
      return (user: null, error: error);
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
        return (user: null, error: 'errorInvalidCredential');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await auth.signInWithCredential(oauthCredential);

      return (user: userCredential.user, error: null);
    } on SignInWithAppleAuthorizationException catch (e) {
      final error = switch (e.code) {
        AuthorizationErrorCode.canceled => 'errorAppleCanceled',
        AuthorizationErrorCode.failed => 'errorAppleFailed',
        AuthorizationErrorCode.invalidResponse => 'errorAppleInvalidResponse',
        AuthorizationErrorCode.notHandled => 'errorAppleNotHandled',
        AuthorizationErrorCode.notInteractive => 'errorAppleNotInteractive',
        AuthorizationErrorCode.unknown => 'errorUnknown',
        AuthorizationErrorCode.credentialExport => 'errorAppleCredentialExport',
        AuthorizationErrorCode.credentialImport => 'errorAppleCredentialImport',
        AuthorizationErrorCode.matchedExcludedCredential => 'errorAppleMatchedExcludedCredential',
      };

      log('AppleSignInException ${e.code}: ${e.message}');
      return (user: null, error: error);
    } on FirebaseAuthException catch (e) {
      final error = switch (e.code) {
        'account-exists-with-different-credential' => 'errorInvalidCredential',
        'invalid-credential' => 'errorInvalidCredential',
        'user-disabled' => 'errorAccountDisabled',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        'too-many-requests' => 'errorTooManyRequests',
        _ => e.code,
      };

      log(error);
      return (user: null, error: error);
    } catch (e) {
      final error = 'Apple sign-in error $e';
      log(error);
      return (user: null, error: error);
    }
  }

  /// Signs user in anonymously with [Firebase]
  Future<({User? user, String? error})> signInAnonymously() async {
    try {
      final userCredential = await auth.signInAnonymously();

      return (user: userCredential.user, error: null);
    } on FirebaseAuthException catch (e) {
      final error = switch (e.code) {
        'operation-not-allowed' => 'errorOperationNotAllowed',
        'too-many-requests' => 'errorTooManyRequests',
        _ => e.code,
      };

      log(error);
      return (user: null, error: error);
    } catch (e) {
      final error = 'Anonymous sign-in error $e';
      log(error);
      return (user: null, error: error);
    }
  }
}
