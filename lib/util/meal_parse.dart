import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal/food.dart';
import '../models/meal/meal.dart';

/// Returns the requested localized string with the other supported language as fallback
String? getLocalizedString(
  Object? value, {
  required String languageCode,
}) {
  if (value is! Map) {
    return value is String ? value : null;
  }

  final localizedValue = value[languageCode];
  final fallbackValue = value[languageCode == 'en' ? 'hr' : 'en'];

  return localizedValue is String
      ? localizedValue
      : fallbackValue is String
      ? fallbackValue
      : null;
}

/// Parses a food in the active language and keeps its original fields for editing
Food? parseLocalizedFood(
  Object? value, {
  required String languageCode,
}) {
  if (value is! Map) {
    return null;
  }

  final food = Map<String, dynamic>.from(value);
  return Food.tryFromMap(
    {
      ...food,
      'name': getLocalizedString(food['name'], languageCode: languageCode),
      'unit': getLocalizedString(food['unit'], languageCode: languageCode),
    },
    localizedData: food,
  );
}

/// Returns the original compact AI fields for copies and edits
Map<String, dynamic>? getCompactLocalizedMealData(Map<String, dynamic> data) {
  final name = data['name'];

  if (name is! Map || name['en'] is! String || name['hr'] is! String) {
    return null;
  }

  return {
    'name': Map<String, dynamic>.from(name),
    'emoji': data['emoji'],
    'color': data['color'],
    'nutrition': data['nutrition'],
    'foods': data['foods'],
  };
}

/// Parses one Firestore meal document into the active app language
Meal? parseMealDocument(
  QueryDocumentSnapshot<Map<String, dynamic>> document, {
  required String languageCode,
}) {
  try {
    final data = document.data();
    final localizedName = getLocalizedString(
      data['name'],
      languageCode: languageCode,
    );
    final createdAt = data['createdAt'];
    final hasLocalizedName = data['name'] is Map && localizedName != null;

    return Meal.fromMap(
      hasLocalizedName ? {...data, 'name': localizedName} : data,
      id: document.id,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.parse(createdAt as String),
      originalText: data['originalText'] as String?,
      isLoading: data['isLoading'] as bool? ?? false,
      errors: (data['errors'] as List?)?.whereType<String>().toList(),
      imageStoragePath: data['imageStoragePath'] as String?,
      imageBlurHash: data['imageBlurHash'] as String?,
      localizedData: getCompactLocalizedMealData(data),
      parseFood: hasLocalizedName ? (food) => parseLocalizedFood(food, languageCode: languageCode) : Food.tryFromMap,
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
