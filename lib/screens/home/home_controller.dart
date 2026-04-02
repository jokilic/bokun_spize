import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/food.dart';
import '../../models/meal.dart';
import '../../models/nutrition.dart';
import '../../services/ai_service.dart';
import '../../services/hive_service.dart';
import '../../services/speech_to_text_service.dart';
import '../meal/meal_screen.dart';

class HomeController {
  ///
  /// CONSTRUCTOR
  ///

  final HiveService hive;
  final SpeechToTextService speechToText;
  final AIService ai;

  HomeController({
    required this.hive,
    required this.speechToText,
    required this.ai,
  });

  ///
  /// VARIABLES
  ///

  final placeholderMeal = Meal(
    id: const Uuid().v1(),
    name: 'Some name',
    emoji: '🥗',
    color: Colors.blue,
    createdAt: DateTime.now(),
    nutrition: Nutrition(
      calories: 125,
      protein: 40,
      carbs: 25,
      fat: 10,
    ),
    foods: [
      Food(
        name: 'Some food',
        quantity: 100,
        unit: 'g',
        nutrition: Nutrition(
          calories: 40,
          protein: 15,
          carbs: 35,
          fat: 5,
        ),
      ),
    ],
    originalText: 'Some original text',
    isLoading: false,
  );

  ///
  /// METHODS
  ///

  /// Triggered when the user presses the 'Add' button or edits existing meal
  Future<void> onMealPressed(
    BuildContext context, {
    Meal? passedMeal,
  }) async {
    /// Show [MealScreen] for adding meal
    final result = await showCupertinoSheet<({String? words, DateTime? dateTime, File? imageFile, bool deleteMeal})>(
      context: context,
      builder: (context) => MealScreen(
        passedMeal: passedMeal,
      ),
    );

    /// User was editing existing `meal`
    if (passedMeal != null) {
      /// User deleted `meal`
      if (result?.deleteMeal ?? false) {
        await hive.deleteMeal(
          meal: passedMeal,
        );
      }
      /// User changed `dateTime`
      else if (result?.dateTime != null && result?.dateTime != passedMeal.createdAt) {
        /// Update `dateTime` in [Hive]
        await hive.updateMeal(
          newMeal: passedMeal.copyWith(
            createdAt: result!.dateTime,
          ),
        );
      }
    }
    /// User added a new `meal`
    else {
      /// User entered `words` or `imageFile` + `dateTime` exists
      if (((result?.words?.isNotEmpty ?? false) || result?.imageFile != null) && result?.dateTime != null) {
        /// Trigger AI which generates a new `meal` and stores into [Hive]
        await triggerAI(
          textPrompt: result?.words,
          imageFile: result?.imageFile,
          dateTime: result!.dateTime!,
        );
      }
    }
  }

  /// Triggers AI with `prompt`
  Future<void> triggerAI({
    required String? textPrompt,
    required File? imageFile,
    required DateTime dateTime,
  }) async {
    /// Get `trimmedPrompt` or photo emoji if `textPrompt` is null
    final trimmedPrompt = textPrompt?.trim() ?? '📷';

    /// Create `loadingMeal` with loading state
    final loadingMeal = Meal(
      id: const Uuid().v1(),
      createdAt: dateTime,
      originalText: trimmedPrompt,
      isLoading: true,
    );

    /// Add `loadingMeal` to [Hive]
    await hive.writeMeal(
      newMeal: loadingMeal,
    );

    /// Trigger `AI`
    final result = await ai.triggerAI(
      textPrompt: trimmedPrompt,
      imageFile: imageFile,
    );

    // final result = (
    //   aiResult: placeholderMeal.toJson(),
    //   errors: null,
    // );

    /// AI did not generate result
    if (result.aiResult == null) {
      /// Create `errorMeal` with `errors` data
      final errorMeal = loadingMeal.copyWith(
        errors: result.errors,
        isLoading: false,
      );

      /// Update `loadingMeal` with `errorMeal`
      await hive.updateMeal(
        newMeal: errorMeal,
      );
    }

    /// AI generated result
    if (result.aiResult?.isNotEmpty ?? false) {
      /// Parse to `Meal`
      final meal = parseAIResultToMeal(
        aiResult: result.aiResult!,
        id: loadingMeal.id,
        createdAt: loadingMeal.createdAt,
        originalText: trimmedPrompt,
        imageFile: imageFile,
      );

      /// Result is successfully parsed
      if (meal != null) {
        /// Create `successMeal` with `meal` data
        final successMeal = loadingMeal.copyWith(
          name: meal.name,
          emoji: meal.emoji,
          color: meal.color,
          nutrition: meal.nutrition,
          foods: meal.foods,
          isLoading: false,
        );

        /// Update `loadingMeal` with `successMeal`
        await hive.updateMeal(
          newMeal: successMeal,
        );
      }
      /// Result is not successfully parsed
      else {
        /// Create `errorMeal` with `error` data
        final errorMeal = loadingMeal.copyWith(
          errors: ['Obrok nije dekodiran'],
          isLoading: false,
        );

        /// Update `loadingMeal` with `errorMeal`
        await hive.updateMeal(
          newMeal: errorMeal,
        );
      }
    }
  }

  /// Parses AI result to `Meal`
  Meal? parseAIResultToMeal({
    required String aiResult,
    required String id,
    required DateTime createdAt,
    required String originalText,
    required File? imageFile,
  }) {
    try {
      final decoded = jsonDecode(aiResult);

      if (decoded is Map<String, dynamic>) {
        return Meal.fromMap(
          decoded,
          id: id,
          createdAt: createdAt,
          originalText: originalText,
          imageFilePath: imageFile?.path,
          isLoading: false,
          errors: null,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
