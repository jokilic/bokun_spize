import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/meal.dart';
import '../../services/speech_to_text_service.dart';
import '../../util/null_state.dart';

class MealController
    extends ValueNotifier<({bool wordsValid, String? speechToTextWords, bool dateEditMode, bool timeEditMode, DateTime transactionDate, DateTime transactionTime, bool expanded})>
    implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final SpeechToTextService speechToText;
  final Meal? passedMeal;

  MealController({
    required this.speechToText,
    required this.passedMeal,
  }) : super(
         (
           wordsValid: false,
           speechToTextWords: null,
           dateEditMode: false,
           timeEditMode: false,
           transactionDate: DateTime.now(),
           transactionTime: DateTime.now(),
           expanded: false,
         ),
       );

  ///
  /// VARIABLES
  ///

  late final textEditingController = TextEditingController();

  ///
  /// INIT
  ///

  void init() {
    final now = DateTime.now();

    /// Update `state` with proper values
    updateState(
      wordsValid: passedMeal?.originalText.isNotEmpty ?? false,
      transactionDate: passedMeal?.createdAt ?? now,
      transactionTime: passedMeal?.createdAt ?? now,
    );

    /// Update [TextEditingController] text
    textEditingController.text = passedMeal?.originalText ?? '';

    /// Add validation listener to [TextEditingController]
    textEditingController.addListener(validateTextField);
  }

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    /// Stop listener & update `state`
    if (speechToText.value.isListening) {
      await speechToText.stopListening();
    }

    speechToText.updateState(
      isListening: false,
    );

    /// Dispose [TextEditingController]
    textEditingController
      ..removeListener(validateTextField)
      ..dispose();
  }

  ///
  /// METHODS
  ///

  /// Triggered on every [TextField] change
  /// Updates `Add` button state
  void validateTextField() {
    /// Parse values
    final words = textEditingController.text.trim();

    /// Validate values
    updateState(
      wordsValid: words.isNotEmpty,
    );
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

  /// Updates `state`
  void updateState({
    bool? wordsValid,
    Object? speechToTextWords = nullStateNoChange,
    bool? dateEditMode,
    bool? timeEditMode,
    DateTime? transactionDate,
    DateTime? transactionTime,
    bool? expanded,
  }) => value = (
    wordsValid: wordsValid ?? value.wordsValid,
    speechToTextWords: identical(speechToTextWords, nullStateNoChange) ? value.speechToTextWords : speechToTextWords as String?,
    dateEditMode: dateEditMode ?? value.dateEditMode,
    timeEditMode: timeEditMode ?? value.timeEditMode,
    transactionDate: transactionDate ?? value.transactionDate,
    transactionTime: transactionTime ?? value.transactionTime,
    expanded: expanded ?? value.expanded,
  );
}
