import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../constants/durations.dart';
import '../../models/food.dart';
import '../../models/meal.dart';
import '../../models/nutrition.dart';
import '../../services/ai_service.dart';
import '../../services/hive_service.dart';
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

  final HiveService hive;
  final SpeechToTextService speechToText;
  final AIService ai;

  HomeController({
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

  /// Triggered when the user presses the 'Add' button or edits existing meal
  Future<void> onMealPressed(
    BuildContext context, {
    Meal? passedMeal,
  }) async {
    /// Reset `state`
    updateState(
      speechToTextWords: null,
    );

    /// Update TextEditingController] with proper text
    textEditingController.text = passedMeal?.originalText ?? '';

    /// Show [BokunSpizeMealSheet] for adding meal
    final result = await showModalBottomSheet<({String? words, DateTime? dateTime, bool deleteMeal})>(
      context: context,
      backgroundColor: context.colors.scaffoldBackground,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      sheetAnimationStyle: const AnimationStyle(
        duration: BokunSpizeDurations.animation,
        reverseDuration: BokunSpizeDurations.animation,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn,
      ),
      builder: (context) => BokunSpizeMealSheet(
        textEditingController: textEditingController,
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
      else if (result?.dateTime != passedMeal.createdAt) {
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
      /// User entered `words` and `dateTime`
      if ((result?.words?.isNotEmpty ?? false) && result?.dateTime != null) {
        /// Trigger AI which generates a new `meal` and stores into [Hive]
        await triggerAI(
          prompt: result!.words!,
          dateTime: result.dateTime!,
        );
      }
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
  Future<void> triggerAI({
    required String prompt,
    required DateTime dateTime,
  }) async {
    final trimmedPrompt = prompt.trim();

    if (trimmedPrompt.isEmpty) {
      return;
    }

    /// Create `loadingMeal` with loading state
    final loadingMeal = Meal(
      id: const Uuid().v1(),
      createdAt: dateTime,
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

    final result = (
      aiResult: Meal(
        id: const Uuid().v1(),
        createdAt: dateTime,
        originalText: trimmedPrompt,
        isLoading: false,
        name: 'Piletina',
        emoji: '🐔',
        color: Colors.deepPurple,
        nutrition: Nutrition(
          calories: 100,
          protein: 10,
          carbs: 10,
          fat: 10,
        ),
        foods: [
          Food(
            name: 'Piletina',
            quantity: 12,
            unit: 'komads',
            calories: 300,
          ),
        ],
      ).toJson(),
      errors: null,
    );

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
          errors: null,
        );
      }

      return null;
    } catch (e) {
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
