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
import '../../widgets/add_meal_modal.dart';

/// Class to distinguish `no argument passed` from `explicitly passed null`
class HomeStateNoChange {
  const HomeStateNoChange();
}

const homeStateNoChange = HomeStateNoChange();

class HomeController extends ValueNotifier<({String? userWords, Meal? aiResult, String? aiError})> implements Disposable {
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
  }) : super((userWords: null, aiResult: null, aiError: null));

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
  Future<bool> onAddPressed(BuildContext context) async {
    /// Reset `state`
    updateState(
      userWords: null,
      aiResult: null,
      aiError: null,
    );

    /// Show [SettingsDeleteAccountModal] for email users
    final value = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: context.colors.scaffoldBackground,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      builder: (context) => AddMealModal(),
    );

    /// User entered words
    if (value?.isNotEmpty ?? false) {
      /// Update `state` with new `words`
      updateState(
        userWords: value,
      );

      /// Trigger AI
      await triggerAI();
    }

    return false;
  }

  /// Triggered when the user presses [SpeechToText] button
  Future<void> onSpeechToTextPressed({
    required String locale,
  }) async {
    /// [SpeechToText] was disabled, start listening
    if (!speechToText.value.isListening) {
      updateState(
        userWords: null,
        aiResult: null,
        aiError: null,
      );

      await speechToText.startListening(
        onResult: (words) => updateState(
          userWords: words,
        ),
        locale: locale,
      );
    }
    /// [SpeechToText] was enabled, stop listening & trigger `AI`
    else {
      await speechToText.stopListening();
      await triggerAI();
    }
  }

  /// Triggers AI with `prompt` used from `state`
  Future<void> triggerAI() async {
    if (value.userWords?.isNotEmpty ?? false) {
      final result = await ai.triggerAI(
        prompt: value.userWords!,
      );

      /// Update `state` with potential `error`
      updateState(
        aiError: result.error,
      );

      /// AI generated result, parse it to `Meal`
      if (result.aiResult?.isNotEmpty ?? false) {
        final aiMeal = parseAIResultToMeal(
          aiResult: result.aiResult!,
        );

        /// Result is successfully parsed, add meal to `state`
        if (aiMeal != null) {
          /// Update `state` with parsed `meal`
          updateState(
            aiResult: aiMeal,
          );

          /// Add new `meal` to [Hive]
          await hive.writeMeal(
            newMeal: aiMeal,
          );
        }
      }
    }
  }

  /// Parses AI result to `Meal`
  Meal? parseAIResultToMeal({
    required String aiResult,
  }) {
    try {
      final decoded = jsonDecode(aiResult);

      if (decoded is Map<String, dynamic>) {
        return Meal.fromMap(
          decoded,
          id: const Uuid().v1(),
          postedAt: DateTime.now(),
          originalText: value.userWords!,
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
    Object? userWords = homeStateNoChange,
    Object? aiResult = homeStateNoChange,
    Object? aiError = homeStateNoChange,
  }) => value = (
    userWords: identical(userWords, homeStateNoChange) ? value.userWords : userWords as String?,
    aiResult: identical(aiResult, homeStateNoChange) ? value.aiResult : aiResult as Meal?,
    aiError: identical(aiError, homeStateNoChange) ? value.aiError : aiError as String?,
  );
}
