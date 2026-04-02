import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/meal.dart';
import '../../services/speech_to_text_service.dart';
import '../../util/null_state.dart';

class MealController
    extends
        ValueNotifier<
          ({bool validationPassed, String? speechToTextWords, bool dateEditMode, bool timeEditMode, DateTime transactionDate, DateTime transactionTime, File? imageFile})
        >
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
           validationPassed: false,
           speechToTextWords: null,
           dateEditMode: false,
           timeEditMode: false,
           transactionDate: DateTime.now(),
           transactionTime: DateTime.now(),
           imageFile: null,
         ),
       );

  ///
  /// VARIABLES
  ///

  late final textEditingController = TextEditingController();
  late final imagePicker = ImagePicker();

  ///
  /// INIT
  ///

  void init() {
    final now = DateTime.now();

    /// Get `imageFile` if `passedMeal` is not `null`
    final imageFile = passedMeal?.imageFilePath != null ? File(passedMeal!.imageFilePath!) : null;

    /// Update `state` with proper values
    updateState(
      validationPassed: (passedMeal?.originalText.isNotEmpty ?? false) || imageFile != null,
      transactionDate: passedMeal?.createdAt ?? now,
      transactionTime: passedMeal?.createdAt ?? now,
      imageFile: imageFile,
    );

    /// Update [TextEditingController] text
    textEditingController.text = passedMeal?.originalText ?? '';

    /// Add validation listener to [TextEditingController]
    textEditingController.addListener(triggerValidation);
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
      ..removeListener(triggerValidation)
      ..dispose();
  }

  ///
  /// METHODS
  ///

  /// Checks if validation passed
  void triggerValidation() {
    final isTextValidated = textEditingController.text.trim().isNotEmpty;
    final isImageValidated = value.imageFile != null;

    updateState(
      validationPassed: isTextValidated || isImageValidated,
    );
  }

  /// Triggered when the user presses [SpeechToText] button
  Future<void> onSpeechToTextPressed({
    required String locale,
    required bool speechToTextAvailable,
  }) async {
    if (!speechToTextAvailable) {
      await speechToText.loadSpeechToText();
    }

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

  /// Triggered when the user presses [Camera] button
  Future<void> onCameraPressed() async {
    /// Trigger `imagePicker`
    final image = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    /// Image is taken, update `state`
    if (image != null) {
      updateState(
        imageFile: File(image.path),
      );

      /// Trigger validation
      triggerValidation();
    }
  }

  /// Triggered when the user presses [Gallery] button
  Future<void> onGalleryPressed() async {
    /// Trigger `imagePicker`
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    /// Image is picked, update `state`
    if (image != null) {
      updateState(
        imageFile: File(image.path),
      );

      /// Trigger validation
      triggerValidation();
    }
  }

  /// Updates `state`
  void updateState({
    bool? validationPassed,
    Object? speechToTextWords = nullStateNoChange,
    bool? dateEditMode,
    bool? timeEditMode,
    DateTime? transactionDate,
    DateTime? transactionTime,
    Object? imageFile = nullStateNoChange,
  }) => value = (
    validationPassed: validationPassed ?? value.validationPassed,
    speechToTextWords: identical(speechToTextWords, nullStateNoChange) ? value.speechToTextWords : speechToTextWords as String?,
    dateEditMode: dateEditMode ?? value.dateEditMode,
    timeEditMode: timeEditMode ?? value.timeEditMode,
    transactionDate: transactionDate ?? value.transactionDate,
    transactionTime: transactionTime ?? value.transactionTime,
    imageFile: identical(imageFile, nullStateNoChange) ? value.imageFile : imageFile as File?,
  );
}
