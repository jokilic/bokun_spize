import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../models/food.dart';
import '../../models/meal.dart';
import '../../models/nutrition.dart';
import '../../services/ai_service.dart';
import '../../services/hive_service.dart';
import '../../services/logger_service.dart';
import '../../services/speech_to_text_service.dart';
import '../../theme/extensions.dart';
import '../../widgets/bokun_spize_meal_sheet.dart';

/// Class to distinguish `no argument passed` from `explicitly passed null`
class HomeStateNoChange {
  const HomeStateNoChange();
}

const homeStateNoChange = HomeStateNoChange();

class HomeController extends ValueNotifier<({String? speechToTextWords})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final LoggerService logger;
  final HiveService hive;
  final SpeechToTextService speechToText;
  final AIService ai;

  HomeController({
    required this.logger,
    required this.hive,
    required this.speechToText,
    required this.ai,
  }) : super((speechToTextWords: null));

  ///
  /// VARIABLES
  ///

  late final textEditingController = TextEditingController();

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    speechToText.updateState(
      isListening: false,
    );

    textEditingController.dispose();
  }

  ///
  /// METHODS
  ///

  /// Triggered when the user presses the 'Add' button
  Future<void> onAddPressed(BuildContext context) async {
    /// Reset `state`
    updateState(
      speechToTextWords: null,
    );

    /// Show [BokunSpizeMealSheet] for adding meal
    final userWords = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: context.colors.scaffoldBackground,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      builder: (context) => BokunSpizeMealSheet(
        textEditingController: textEditingController,
      ),
    );

    /// User entered words
    if (userWords?.isNotEmpty ?? false) {
      /// Trigger AI
      await triggerAI(
        prompt: userWords!,
      );
    }
  }

  /// Triggered when the user presses [SpeechToText] button
  Future<void> onSpeechToTextPressed({
    required String locale,
  }) async {
    /// Save current [TextEditingController] text
    final currentText = textEditingController.text;

    /// [SpeechToText] was disabled, start listening
    if (!speechToText.value.isListening) {
      /// Reset `state`
      updateState(
        speechToTextWords: null,
      );

      await speechToText.startListening(
        onResult: (words) {
          /// Update `state`
          updateState(
            speechToTextWords: words,
          );

          /// Add new `words` to [TextEditingController]
          if (currentText.isNotEmpty) {
            textEditingController.text = '$currentText $words';
          } else {
            textEditingController.text = words;
          }
        },
        locale: locale,
      );
    }
    /// [SpeechToText] was enabled, stop listening
    else {
      await speechToText.stopListening();
    }
  }

  /// Triggered when dismissing [BokunSpizeMealSheet]
  Future<void> onDismissSheet() async {
    /// Stop listener
    if (speechToText.value.isListening) {
      await speechToText.stopListening();
    }

    /// Clear [TextEditingController]
    textEditingController.clear();
  }

  /// Triggers AI with `prompt`
  Future<void> triggerAI({required String prompt}) async {
    final trimmedPrompt = prompt.trim();

    if (trimmedPrompt.isEmpty) {
      return;
    }

    /// Create `loadingMeal` with loading state
    final loadingMeal = Meal(
      id: const Uuid().v1(),
      createdAt: DateTime.now(),
      originalText: trimmedPrompt.trim(),
      isLoading: true,
    );

    /// Add `loadingMeal` to [Hive]
    await hive.writeMeal(
      newMeal: loadingMeal,
    );

    /// Trigger `AI`
    // final result = await ai.triggerAI(
    //   prompt: trimmedPrompt,
    // );

    final result = Meal(
      id: const Uuid().v1(),
      name: 'Some food',
      emoji: '🍔',
      nutrition: Nutrition(
        calories: 15,
        protein: 9,
        carbs: 2,
        fat: 4,
      ),
      foods: [
        Food(
          name: 'banana',
          quantity: 2,
          unit: 'piece',
        ),
      ],
      createdAt: DateTime.now(),
      originalText: 'This is my original text',
      isLoading: false,
    ).toJson();

    logger.f('Result: $result');

    /// AI did not generate result
    if (result == null) {
      /// Create `errorMeal` with `error` data
      final errorMeal = loadingMeal.copyWith(
        error: 'Obrok nije generiran',
        isLoading: false,
      );

      /// Update `loadingMeal` with `errorMeal`
      await hive.updateMeal(
        newMeal: errorMeal,
      );
    }

    /// AI generated result
    if (result?.isNotEmpty ?? false) {
      /// Parse to `Meal`
      final meal = parseAIResultToMeal(
        aiResult: result!,
        id: loadingMeal.id,
        createdAt: loadingMeal.createdAt,
        originalText: trimmedPrompt,
      );

      /// Result is successfully parsed
      if (meal != null) {
        /// Create `successMeal` with `meal` data
        final successMeal = loadingMeal.copyWith(
          name: meal.name,
          emoji: meal.emoji,
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
          error: 'Obrok nije dekodiran',
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
  }) {
    try {
      final decoded = jsonDecode(aiResult);

      if (decoded is Map<String, dynamic>) {
        return Meal.fromMap(
          decoded,
          id: id,
          createdAt: createdAt,
          originalText: originalText,
          isLoading: false,
          error: null,
        );
      }

      return null;
    } catch (e) {
      logger.e('HomeController -> parseAIResultToMeal() -> $e');
      return null;
    }
  }

  /// Updates `state`
  void updateState({
    Object? speechToTextWords = homeStateNoChange,
  }) => value = (
    speechToTextWords: identical(speechToTextWords, homeStateNoChange) ? value.speechToTextWords : speechToTextWords as String?,
  );
}
