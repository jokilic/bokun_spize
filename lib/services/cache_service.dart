import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CacheService extends ValueNotifier<({Map<String, String> mealImageDownloadUrls, Map<String, Future<String>> mealImageDownloadUrlRequests})> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseStorage storage;

  CacheService({
    required this.storage,
  }) : super((
         mealImageDownloadUrls: {},
         mealImageDownloadUrlRequests: {},
       ));

  ///
  /// METHODS
  ///

  /// Returns a previously resolved image URL without starting a new request
  String? getCachedMealImageDownloadUrl({required String imageStoragePath}) => value.mealImageDownloadUrls[imageStoragePath];

  /// Returns the cached image URL or resolves it from [Firebase Storage]
  Future<String?> getMealImageDownloadUrl({required String imageStoragePath}) async {
    final cachedUrl = value.mealImageDownloadUrls[imageStoragePath];

    if (cachedUrl != null) {
      return cachedUrl;
    }

    Future<String>? request;

    try {
      request = value.mealImageDownloadUrlRequests[imageStoragePath];

      if (request == null) {
        request = storage.ref(imageStoragePath).getDownloadURL();

        updateState(
          mealImageDownloadUrlRequests: {
            ...value.mealImageDownloadUrlRequests,
            imageStoragePath: request,
          },
        );
      }

      final imageUrl = await request;

      updateState(
        mealImageDownloadUrls: {
          ...value.mealImageDownloadUrls,
          imageStoragePath: imageUrl,
        },
      );
      return imageUrl;
    } catch (error) {
      log(
        'Getting meal image download URL failed',
        error: error,
      );
      return null;
    } finally {
      if (identical(value.mealImageDownloadUrlRequests[imageStoragePath], request)) {
        final mealImageDownloadUrlRequests = Map<String, Future<String>>.from(
          value.mealImageDownloadUrlRequests,
        )..remove(imageStoragePath);

        updateState(
          mealImageDownloadUrlRequests: mealImageDownloadUrlRequests,
        );
      }
    }
  }

  /// Removes a meal image URL and any request associated with it from the cache.
  Future<void> removeMealImageDownloadUrl({required String imageStoragePath}) async {
    final request = value.mealImageDownloadUrlRequests[imageStoragePath];
    final mealImageDownloadUrls = Map<String, String>.from(value.mealImageDownloadUrls)..remove(imageStoragePath);

    updateState(
      mealImageDownloadUrls: mealImageDownloadUrls,
    );

    if (request != null) {
      try {
        await request;
      } catch (_) {
        /// The original request handles its own error; the cache still needs cleanup.
      }
    }

    final completedMealImageDownloadUrls = Map<String, String>.from(value.mealImageDownloadUrls)..remove(imageStoragePath);
    final mealImageDownloadUrlRequests = Map<String, Future<String>>.from(value.mealImageDownloadUrlRequests);

    if (identical(mealImageDownloadUrlRequests[imageStoragePath], request)) {
      await mealImageDownloadUrlRequests.remove(imageStoragePath);
    }

    updateState(
      mealImageDownloadUrls: completedMealImageDownloadUrls,
      mealImageDownloadUrlRequests: mealImageDownloadUrlRequests,
    );
  }

  /// Updates `state`.
  void updateState({
    Map<String, String>? mealImageDownloadUrls,
    Map<String, Future<String>>? mealImageDownloadUrlRequests,
  }) => value = (
    mealImageDownloadUrls: mealImageDownloadUrls ?? value.mealImageDownloadUrls,
    mealImageDownloadUrlRequests: mealImageDownloadUrlRequests ?? value.mealImageDownloadUrlRequests,
  );
}
