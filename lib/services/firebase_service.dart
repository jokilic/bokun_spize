import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

import '../models/meal/meal.dart';
import '../models/user_metrics/user_metrics.dart';
import '../models/weight_track/weight_track.dart';
import '../util/meal_image.dart';
import '../util/meal_parse.dart';
import '../util/typedefs.dart';
import '../util/weight_track_parse.dart';
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
  final FirebaseStorage storage;
  final GoogleSignIn googleSignIn;
  final CacheService cache;

  FirebaseService({
    required this.auth,
    required this.firestore,
    required this.storage,
    required this.googleSignIn,
    required this.cache,
  });

  ///
  /// GETTERS
  ///

  String? get userEmail => auth.currentUser?.email;
  String? get userName => auth.currentUser?.displayName;
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

  /// Logs user out of [Firebase]
  Future<void> logOut() async => auth.signOut();

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
    } on FirebaseAuthException catch (error) {
      final errorMessage = switch (error.code) {
        'invalid-email' => 'errorEmailInvalid',
        'user-disabled' => 'errorAccountDisabled',
        'user-not-found' => 'errorUserNotFound',
        'wrong-password' => 'errorPasswordWrong',
        'invalid-credential' => 'errorInvalidCredential',
        'too-many-requests' => 'errorTooManyRequests',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        _ => error.code,
      };

      log(
        'Email sign in failed',
        error: error,
      );
      return (user: null, error: errorMessage);
    } catch (error) {
      log(
        'Email sign in failed',
        error: error,
      );
      return (user: null, error: 'Login error $error');
    }
  }

  /// Sends a password reset email through [Firebase]
  Future<({bool success, String? error})> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await auth.sendPasswordResetEmail(email: email);

      return (success: true, error: null);
    } on FirebaseAuthException catch (error) {
      final errorMessage = switch (error.code) {
        'invalid-email' => 'errorEmailInvalid',
        'user-disabled' => 'errorAccountDisabled',
        'user-not-found' => 'errorUserNotFound',
        'too-many-requests' => 'errorTooManyRequests',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        _ => error.code,
      };

      log(
        'Password reset email failed',
        error: error,
      );
      return (success: false, error: errorMessage);
    } catch (error) {
      log(
        'Password reset email failed',
        error: error,
      );
      return (success: false, error: 'Password reset error $error');
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
    } on GoogleSignInException catch (error) {
      final errorMessage = switch (error.code) {
        GoogleSignInExceptionCode.unknownError => 'errorUnknown',
        GoogleSignInExceptionCode.canceled => 'errorGoogleCanceled',
        GoogleSignInExceptionCode.interrupted => 'errorGoogleInterrupted',
        GoogleSignInExceptionCode.clientConfigurationError => 'errorGoogleClientConfigurationError',
        GoogleSignInExceptionCode.providerConfigurationError => 'errorGoogleProviderConfigurationError',
        GoogleSignInExceptionCode.uiUnavailable => 'errorGoogleUIUnavailable',
        GoogleSignInExceptionCode.userMismatch => 'errorGoogleUserMismatch',
      };

      log(
        'Google sign in failed',
        error: error,
      );
      return (user: null, error: errorMessage);
    } on FirebaseAuthException catch (error) {
      final errorMessage = switch (error.code) {
        'account-exists-with-different-credential' => 'errorInvalidCredential',
        'invalid-credential' => 'errorInvalidCredential',
        'user-disabled' => 'errorAccountDisabled',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        'too-many-requests' => 'errorTooManyRequests',
        _ => error.code,
      };

      log(
        'Google sign in failed',
        error: error,
      );
      return (user: null, error: errorMessage);
    } catch (error) {
      log(
        'Google sign in failed',
        error: error,
      );
      return (user: null, error: 'Google sign-in error $error');
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
    } on SignInWithAppleAuthorizationException catch (error) {
      final errorMessage = switch (error.code) {
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

      log(
        'Apple sign in failed',
        error: error,
      );
      return (user: null, error: errorMessage);
    } on FirebaseAuthException catch (error) {
      final errorMessage = switch (error.code) {
        'account-exists-with-different-credential' => 'errorInvalidCredential',
        'invalid-credential' => 'errorInvalidCredential',
        'user-disabled' => 'errorAccountDisabled',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        'too-many-requests' => 'errorTooManyRequests',
        _ => error.code,
      };

      log(
        'Apple sign in failed',
        error: error,
      );
      return (user: null, error: errorMessage);
    } catch (error) {
      log(
        'Apple sign in failed',
        error: error,
      );
      return (user: null, error: 'Apple sign-in error $error');
    }
  }

  /// Signs user in anonymously with [Firebase]
  Future<({User? user, String? error})> signInAnonymously() async {
    try {
      final userCredential = await auth.signInAnonymously();

      return (user: userCredential.user, error: null);
    } on FirebaseAuthException catch (error) {
      final errorMessage = switch (error.code) {
        'operation-not-allowed' => 'errorOperationNotAllowed',
        'too-many-requests' => 'errorTooManyRequests',
        _ => error.code,
      };

      log(
        'Anonymous sign in failed',
        error: error,
      );
      return (user: null, error: errorMessage);
    } catch (error) {
      log(
        'Anonymous sign in failed',
        error: error,
      );
      return (user: null, error: 'Anonymous sign-in error $error');
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
        return (user: null, error: 'errorUnknown');
      }

      await firestore.collection('users').doc(user.uid).set({
        'name': name,
      });

      return (user: user, error: null);
    } on FirebaseAuthException catch (error) {
      final errorMessage = switch (error.code) {
        'email-already-in-use' => 'errorEmailInUse',
        'invalid-email' => 'errorEmailInvalid',
        'operation-not-allowed' => 'errorOperationNotAllowed',
        'weak-password' => 'errorWeakPassword',
        'too-many-requests' => 'errorTooManyRequests',
        _ => error.code,
      };

      log(
        'Email registration failed',
        error: error,
      );
      return (user: null, error: errorMessage);
    } catch (error) {
      log(
        'Email registration failed',
        error: error,
      );
      return (user: null, error: 'Register error $error');
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
        return false;
      }

      final userDocument = firestore.collection('users').doc(user.uid);

      /// Deletes images
      await deleteStorageFolderPaged(
        storage.ref('users/${user.uid}/meal-images'),
      );

      /// Deletes folders
      await deleteCollectionPaged(
        userDocument.collection('meals'),
      );
      await deleteCollectionPaged(
        userDocument.collection('weightTracks'),
      );

      /// Deletes user document
      await userDocument.delete();

      final appleAuthorizationCode = reauthenticationResult.appleAuthorizationCode;

      if (appleAuthorizationCode != null) {
        await auth.revokeTokenWithAuthorizationCode(
          appleAuthorizationCode,
        );
      }

      if (provider == AuthProvider.google) {
        await googleSignIn.disconnect();
      }

      await user.delete();

      return true;
    } catch (error) {
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

  /// Deletes a [Firestore] collection in batches
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

  /// Deletes all files and nested folders below a [Firebase Storage] reference
  Future<void> deleteStorageFolderPaged(
    Reference folder, {
    int pageSize = 1000,
  }) async {
    while (true) {
      final result = await folder.list(
        ListOptions(maxResults: pageSize),
      );

      if (result.items.isEmpty && result.prefixes.isEmpty) {
        return;
      }

      for (final item in result.items) {
        await item.delete();
      }

      for (final prefix in result.prefixes) {
        await deleteStorageFolderPaged(
          prefix,
          pageSize: pageSize,
        );
      }
    }
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

      if (data == null || !data.containsKey('age')) {
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

        if (data == null || !data.containsKey('age')) {
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

      await document.set(newUserMetrics.toMap());

      return true;
    } catch (error) {
      log(
        'Writing user metrics failed',
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

      await document.set(newUserMetrics.toMap());

      return true;
    } catch (error) {
      log(
        'Updating user metrics failed',
        error: error,
      );
      return false;
    }
  }

  /// Deletes `userMetrics` from the current user's document in [Firebase]
  Future<bool> deleteUserMetrics() async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      final document = firestore.collection('users').doc(user.uid);

      await document.delete();

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

      return snapshot.docs.map(parseMealDocument).whereType<Meal>().toList();
    } catch (error) {
      log(
        'Getting meals failed',
        error: error,
      );
      return null;
    }
  }

  /// Listens for real-time changes to `meals` created on [date] in [Firebase]
  Stream<List<Meal>> listenToMeals({required DateTime date}) async* {
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
          isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
        )
        .where(
          'createdAt',
          isLessThan: startOfNextDay.toIso8601String(),
        )
        .orderBy('createdAt', descending: true);

    await for (final snapshot in query.snapshots()) {
      yield snapshot.docs.map(parseMealDocument).whereType<Meal>().toList();
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
    } catch (error) {
      log(
        'Writing meal failed',
        error: error,
      );
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
    } catch (error) {
      log(
        'Updating meal failed',
        error: error,
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

      if (meal.imageStoragePath != null) {
        /// Keep shared images while another meal still references them
        final mealsUsingImage = await collection
            .where(
              'imageStoragePath',
              isEqualTo: meal.imageStoragePath,
            )
            .limit(1)
            .get();

        if (mealsUsingImage.docs.isEmpty) {
          return await deleteMealImage(
            imageStoragePath: meal.imageStoragePath!,
          );
        }
      }

      return true;
    } catch (error) {
      log(
        'Deleting meal failed',
        error: error,
      );
      return false;
    }
  }

  ///
  /// MEAL IMAGE
  ///

  /// Uploads the image used to create a meal and returns its `Storage` path
  Future<String?> uploadMealImage({
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

      return storagePath;
    } on FirebaseException catch (error) {
      log(
        'Uploading meal image failed',
        error: error,
      );
      return null;
    } catch (error) {
      log(
        'Uploading meal image failed',
        error: error,
      );
      return null;
    }
  }

  /// Deletes an uploaded meal image when it is no longer needed
  Future<bool> deleteMealImage({required String imageStoragePath}) async {
    try {
      await storage.ref(imageStoragePath).delete();

      cache.mealImageDownloadUrls.remove(imageStoragePath);
      await cache.mealImageDownloadUrlRequests.remove(imageStoragePath);

      return true;
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        cache.mealImageDownloadUrls.remove(imageStoragePath);
        await cache.mealImageDownloadUrlRequests.remove(imageStoragePath);

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

      return snapshot.docs.map(parseWeightTrackDocument).whereType<WeightTrack>().toList();
    } catch (error) {
      log(
        'Getting weight tracks failed',
        error: error,
      );
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
        yield snapshot.docs.map(parseWeightTrackDocument).whereType<WeightTrack>().toList();
      }
    } catch (error) {
      log(
        'Listening to weight tracks failed',
        error: error,
      );
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
    } catch (error) {
      log(
        'Writing weight track failed',
        error: error,
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
    } catch (error) {
      log(
        'Updating weight track failed',
        error: error,
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
    } catch (error) {
      log(
        'Deleting weight track failed',
        error: error,
      );
      return false;
    }
  }
}
