import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal/meal.dart';

/// Returns localized AI meal fields merged with shared document metadata
Map<String, dynamic> getLocalizedMealData(
  Map<String, dynamic> data, {
  required String languageCode,
}) {
  final localizedData = data[languageCode];
  final fallbackData = data[languageCode == 'en' ? 'hr' : 'en'];
  final selectedData = localizedData is Map
      ? localizedData
      : fallbackData is Map
      ? fallbackData
      : null;

  if (selectedData == null) {
    return data;
  }

  return {
    ...data,
    ...Map<String, dynamic>.from(selectedData),
  };
}

/// Parses single `meal` document
Meal? parseMealDocument(
  QueryDocumentSnapshot<Map<String, dynamic>> document, {
  required String languageCode,
}) {
  try {
    final data = document.data();
    final localizedData = getLocalizedMealData(
      data,
      languageCode: languageCode,
    );
    final createdAt = data['createdAt'];

    return Meal.fromMap(
      localizedData,
      id: document.id,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.parse(createdAt as String),
      originalText: data['originalText'] as String?,
      isLoading: data['isLoading'] as bool? ?? false,
      errors: (data['errors'] as List?)?.whereType<String>().toList(),
      imageStoragePath: data['imageStoragePath'] as String?,
      imageBlurHash: data['imageBlurHash'] as String?,
    );
  } catch (error, stackTrace) {
    log(
      'Parsing meal ${document.id} failed',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}
