import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../models/meal.dart';
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
  /// DISPOSE
  ///

  @override
  void onDispose() {
    speechToText.updateState(
      isListening: false,
    );
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
      builder: (context) => BokunSpizeMealSheet(),
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

          /// Update [TextEditingController] with `words`
          // TODO
        },
        locale: locale,
      );
    }
    /// [SpeechToText] was enabled, stop listening
    else {
      await speechToText.stopListening();
    }
  }

  /// Triggers AI with `prompt`
  Future<void> triggerAI({required String prompt}) async {
    if (prompt.isEmpty) {
      return;
    }

    /// Create `loadingMeal` with loading state
    final loadingMeal = Meal(
      id: const Uuid().v1(),
      createdAt: DateTime.now(),
      originalText: prompt,
      isLoading: true,
    );

    /// Add `loadingMeal` to [Hive]
    await hive.writeMeal(
      newMeal: loadingMeal,
    );

    /// Trigger `AI`
    final result = await ai.triggerAI(
      prompt: prompt,
    );

    logger.d('AI Result -> $result');

    /// AI generated result, parse it to `Meal`
    if (result?.isNotEmpty ?? false) {
      final meal = parseAIResultToMeal(
        aiResult: result!,
        id: loadingMeal.id,
        createdAt: loadingMeal.createdAt,
        originalText: prompt,
      );

      /// Result is successfully parsed
      if (meal != null) {
        /// Create `finalMeal` with `meal` data
        final finalMeal = loadingMeal.copyWith(
          name: meal.name,
          nutrition: meal.nutrition,
          foods: meal.foods,
          isLoading: false,
        );

        /// Update `loadingMeal` with `finalMeal`
        await hive.updateMeal(
          newMeal: finalMeal,
        );

        logger.w('New meal -> $finalMeal');
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
