import 'dart:convert';

import '../models/meal/meal.dart';
import 'typedefs.dart';

double parseNumberForFood(String passedValue) {
  final value = double.tryParse(passedValue);
  return value != null && value.isFinite ? value : 0;
}

/// Requires a date and either nonblank text or an image
bool isValidAIMealResult(AIMealResult result) {
  final hasWords = result.words?.trim().isNotEmpty ?? false;
  final hasImage = result.imageFile != null;

  return result.dateTime != null && (hasWords || hasImage);
}

/// Parses the AI response into `meal` for [Firebase]
Meal? parseAIResultToMeal({
  required String aiResult,
  required String id,
  required DateTime createdAt,
  required String? originalText,
  required String? imageStoragePath,
}) {
  try {
    final decoded = jsonDecode(aiResult);

    if (decoded is Map<String, dynamic>) {
      return Meal.fromMap(
        decoded,
        id: id,
        createdAt: createdAt,
        originalText: originalText,
        imageStoragePath: imageStoragePath,
        isLoading: false,
        errors: null,
      );
    }

    return null;
  } catch (e) {
    return null;
  }
}
