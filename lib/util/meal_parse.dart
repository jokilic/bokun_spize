import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

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

/// Localizes one compact AI food while keeping all shared fields unchanged
Map<String, dynamic> getLocalizedFoodData(
  Map<String, dynamic> food, {
  required String languageCode,
}) => {
  ...food,
  'name': getLocalizedString(
    food['name'],
    languageCode: languageCode,
  ),
  'unit': getLocalizedString(
    food['unit'],
    languageCode: languageCode,
  ),
};

/// Returns compact AI fields so copies and date-only edits preserve both languages
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

/// Converts compact bilingual AI fields into the active app language
Map<String, dynamic> getLocalizedMealData(
  Map<String, dynamic> data, {
  required String languageCode,
}) {
  final localizedName = getLocalizedString(
    data['name'],
    languageCode: languageCode,
  );

  if (localizedName == null || data['name'] is String) {
    return data;
  }

  final foods = data['foods'];

  return {
    ...data,
    'name': localizedName,
    'foods': foods is List
        ? foods
              .whereType<Map>()
              .map(
                (food) => getLocalizedFoodData(
                  Map<String, dynamic>.from(food),
                  languageCode: languageCode,
                ),
              )
              .toList()
        : foods,
  };
}

/// Parses one Firestore meal document into the active app language
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
      localizedData: getCompactLocalizedMealData(data),
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
