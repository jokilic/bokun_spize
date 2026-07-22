import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/meal/meal.dart';
import '../models/weight_track/weight_track.dart';

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

    if (user.providerData.any((provider) => provider.providerId == 'password')) {
      return AuthProvider.email;
    }

    return null;
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

  /// Registers a user with email and password in [Firebase]
  Future<({User? user, String? error})> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return (user: userCredential.user, error: null);
    } on FirebaseAuthException catch (e) {
      final error = switch (e.code) {
        'email-already-in-use' => 'errorEmailInUse',
        'invalid-email' => 'errorEmailInvalid',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        'weak-password' => 'errorWeakPassword',
        'too-many-requests' => 'errorTooManyRequests',
        _ => e.code,
      };

      log(error);
      return (user: null, error: error);
    } catch (e) {
      final error = 'Register error $e';
      log(error);
      return (user: null, error: error);
    }
  }

  /// Deletes the current user's data and Firebase account
  /// Email users must provide [email] and [password] for reauthentication
  Future<bool> deleteUser({
    String? email,
    String? password,
  }) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final isReauthenticated = switch (authProvider) {
        AuthProvider.google => await reauthenticateWithGoogle(user),
        AuthProvider.apple => await reauthenticateWithApple(user),
        AuthProvider.email => await reauthenticateWithEmail(
          user,
          email: email,
          password: password,
        ),
        // Anonymous users have no external credentials to reauthenticate with.
        AuthProvider.anonymous => true,
        null => false,
      };

      if (!isReauthenticated) {
        return false;
      }

      // TODO: Check if there are other documents to delete
      final userDocument = firestore.collection('users').doc(user.uid);

      // TODO: Check if there are other collections to delete
      await deleteCollectionPaged(
        userDocument.collection('meals'),
      );
      await deleteCollectionPaged(
        userDocument.collection('weightTracks'),
      );
      await userDocument.delete();

      await user.delete();

      return true;
    } catch (e) {
      log('FirebaseService -> deleteUser() -> $e');
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
      log('Email and password are required for email/password users');
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

  /// Reauthenticates an Apple user
  Future<bool> reauthenticateWithApple(User user) async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final identityToken = appleCredential.identityToken;

    if (identityToken == null || identityToken.isEmpty) {
      return false;
    }

    final credential = OAuthProvider('apple.com').credential(
      idToken: identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final userCredential = await user.reauthenticateWithCredential(credential);

    return userCredential.user != null;
  }

  /// Deletes a Firestore collection in batches
  Future<void> deleteCollectionPaged(
    CollectionReference<Map<String, dynamic>> collection, {
    int batchSize = 300,
  }) async {
    while (true) {
      final snapshot = await collection.limit(batchSize).get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = firestore.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
    }
  }

  ///
  /// MEALS
  ///

  /// Fetches `meals` from [Firebase]
  Future<List<Meal>?> getMeals() async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return null;
      }

      Query<Map<String, dynamic>> query = firestore.collection('users').doc(user.uid).collection('meals');

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs.map((document) {
        final data = document.data();
        final createdAt = data['createdAt'];

        return Meal.fromMap(
          data,
          id: document.id,
          createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.parse(createdAt as String),
          originalText: data['originalText'] as String?,
          isLoading: data['isLoading'] as bool? ?? false,
          errors: (data['errors'] as List?)?.cast<String>(),
          imageFilePath: data['imageFilePath'] as String?,
        );
      }).toList();
    } catch (e) {
      log('FirebaseService -> getMeals() -> $e');
      return null;
    }
  }

  /// Listens for real-time changes to `meals` in [Firebase]
  Stream<List<Meal>?> listenToMeals() async* {
    try {
      final user = auth.currentUser;

      if (user == null) {
        yield null;
        return;
      }

      Query<Map<String, dynamic>> query = firestore.collection('users').doc(user.uid).collection('meals');

      query = query.orderBy('createdAt', descending: true);

      await for (final snapshot in query.snapshots()) {
        yield snapshot.docs.map((document) {
          final data = document.data();
          final createdAt = data['createdAt'];

          return Meal.fromMap(
            data,
            id: document.id,
            createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.parse(createdAt as String),
            originalText: data['originalText'] as String?,
            isLoading: data['isLoading'] as bool? ?? false,
            errors: (data['errors'] as List?)?.cast<String>(),
            imageFilePath: data['imageFilePath'] as String?,
          );
        }).toList();
      }
    } catch (e) {
      log('FirebaseService -> listenToMeals() -> $e');
      yield null;
    }
  }

  /// Adds a new `meal` into [Firebase]
  Future<bool> writeMeal({required Meal newMeal}) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final collection = firestore.collection('users').doc(user.uid).collection('meals');

      await collection.doc(newMeal.id).set(newMeal.toMap());

      return true;
    } catch (e) {
      log('FirebaseService -> writeMeal() -> $e');
      return false;
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

      await collection.doc(newMeal.id).set(newMeal.toMap());

      return true;
    } catch (e) {
      log('FirebaseService -> updateMeal() -> $e');
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

      return true;
    } catch (e) {
      log('FirebaseService -> deleteMeal() -> $e');
      return false;
    }
  }

  ///
  /// WEIGHT TRACKS
  ///

  /// Fetches `weightTracks` from [Firebase]
  Future<List<WeightTrack>?> getWeightTracks() async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return null;
      }

      Query<Map<String, dynamic>> query = firestore.collection('users').doc(user.uid).collection('weightTracks');

      query = query.orderBy('dateTime', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (document) => WeightTrack.fromMap(
              document.data(),
              id: document.id,
            ),
          )
          .toList();
    } catch (e) {
      log('FirebaseService -> getWeightTracks() -> $e');
      return null;
    }
  }

  /// Listens for real-time changes to `weightTracks` in [Firebase]
  Stream<List<WeightTrack>?> listenToWeightTracks() async* {
    try {
      final user = auth.currentUser;

      if (user == null) {
        yield null;
        return;
      }

      Query<Map<String, dynamic>> query = firestore.collection('users').doc(user.uid).collection('weightTracks');

      query = query.orderBy('dateTime', descending: true);

      await for (final snapshot in query.snapshots()) {
        yield snapshot.docs
            .map(
              (document) => WeightTrack.fromMap(
                document.data(),
                id: document.id,
              ),
            )
            .toList();
      }
    } catch (e) {
      log('FirebaseService -> listenToWeightTracks() -> $e');
      yield null;
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
    } catch (e) {
      log('FirebaseService -> writeWeightTrack() -> $e');
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
    } catch (e) {
      log('FirebaseService -> updateWeightTrack() -> $e');
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
    } catch (e) {
      log('FirebaseService -> deleteWeightTrack() -> $e');
      return false;
    }
  }
}
