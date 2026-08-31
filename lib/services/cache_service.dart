import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';

class CacheService {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseStorage storage;

  CacheService({
    required this.storage,
  });

  ///
  /// VARIABLES
  ///

  /// Keeps meal image URLs available while the app is running
  final Map<String, String> mealImageDownloadUrls = {};

  /// Prevents duplicate requests for the same image
  final Map<String, Future<String>> mealImageDownloadUrlRequests = {};

  ///
  /// METHODS
  ///

  /// Returns a previously resolved image URL without starting a new request
  String? getCachedMealImageDownloadUrl({required String imageStoragePath}) => mealImageDownloadUrls[imageStoragePath];

  /// Returns the cached image URL or resolves it from [Firebase Storage]
  Future<String?> getMealImageDownloadUrl({required String imageStoragePath}) async {
    final cachedUrl = mealImageDownloadUrls[imageStoragePath];

    if (cachedUrl != null) {
      return cachedUrl;
    }

    try {
      final request = mealImageDownloadUrlRequests.putIfAbsent(
        imageStoragePath,
        () => storage.ref(imageStoragePath).getDownloadURL(),
      );
      final imageUrl = await request;

      mealImageDownloadUrls[imageStoragePath] = imageUrl;
      return imageUrl;
    } catch (error) {
      log(
        'Getting meal image download URL failed',
        error: error,
      );
      return null;
    } finally {
      await mealImageDownloadUrlRequests.remove(imageStoragePath);
    }
  }
}
