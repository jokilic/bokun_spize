import 'dart:developer';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CacheService extends ValueNotifier<({Map<String, String> mealImageDownloadUrls, Map<String, Future<String>> mealImageDownloadUrlRequests})> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseStorage storage;
  final BaseCacheManager imageCacheManager;

  CacheService({
    required this.storage,
    required this.imageCacheManager,
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
    /// Get cached URL
    final cachedUrl = getCachedMealImageDownloadUrl(
      imageStoragePath: imageStoragePath,
    );

    /// Cached URL exists, return it
    if (cachedUrl != null) {
      return cachedUrl;
    }

    try {
      /// Try to get file from `cache`
      final cachedImage = await imageCacheManager.getFileFromCache(imageStoragePath);

      /// Cached URL exists, update `state` and return it
      if (cachedImage != null) {
        updateState(
          mealImageDownloadUrls: {
            ...value.mealImageDownloadUrls,
            imageStoragePath: cachedImage.originalUrl,
          },
        );

        return cachedImage.originalUrl;
      }
    } catch (error) {
      log(
        'Getting meal image from the disk cache failed',
        error: error,
      );
    }

    Future<String>? request;

    /// Cached URL or file don't exist, trigger a request from [Firebase Storage]
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
      /// This avoids accidentally deleting a newer request that might have started for the same path
      if (identical(value.mealImageDownloadUrlRequests[imageStoragePath], request)) {
        await value.mealImageDownloadUrlRequests.remove(imageStoragePath);

        final mealImageDownloadUrlRequests = Map<String, Future<String>>.from(
          value.mealImageDownloadUrlRequests,
        );

        updateState(
          mealImageDownloadUrlRequests: mealImageDownloadUrlRequests,
        );
      }
    }
  }

  /// Remove meal image URL and any request from cache
  Future<void> removeMealImageDownloadUrl({required String imageStoragePath}) async {
    final request = value.mealImageDownloadUrlRequests[imageStoragePath];
    final mealImageDownloadUrls = Map<String, String>.from(value.mealImageDownloadUrls)..remove(imageStoragePath);

    updateState(
      mealImageDownloadUrls: mealImageDownloadUrls,
    );

    if (request != null) {
      try {
        await request;
      } catch (_) {}
    }

    final imageUrl = value.mealImageDownloadUrls[imageStoragePath];

    /// Remove the image bytes cached on disk
    try {
      await imageCacheManager.removeFile(imageStoragePath);
    } catch (error) {
      log(
        'Removing meal image from the disk cache failed',
        error: error,
      );
    }

    /// Remove the decoded image
    try {
      await CachedNetworkImageProvider(
        imageUrl ?? imageStoragePath,
        cacheKey: imageStoragePath,
        cacheManager: imageCacheManager,
      ).evict();
    } catch (error) {
      log(
        'Removing meal image from the memory cache failed',
        error: error,
      );
    }

    final completedMealImageDownloadUrls = Map<String, String>.from(value.mealImageDownloadUrls)..remove(imageStoragePath);
    final mealImageDownloadUrlRequests = Map<String, Future<String>>.from(value.mealImageDownloadUrlRequests);

    /// This avoids accidentally deleting a newer request that might have started for the same path
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
