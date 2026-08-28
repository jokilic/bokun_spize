import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../models/meal/meal.dart';
import '../../services/speech_to_text_service.dart';
import '../../util/null_state.dart';
import '../../util/path.dart';
import '../../widgets/calendar_sheet.dart';
import '../../widgets/time_sheet.dart';

class AddMealController extends ValueNotifier<({bool textImageValid, String? speechToTextWords, DateTime mealDate, DateTime mealTime, File? imageFile})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final SpeechToTextService speechToText;
  final Meal? passedMeal;
  final bool isCopyingMeal;

  AddMealController({
    required this.speechToText,
    required this.passedMeal,
    required this.isCopyingMeal,
  }) : super(
         (
           textImageValid: false,
           speechToTextWords: null,
           mealDate: DateTime.now(),
           mealTime: DateTime.now(),
           imageFile: null,
         ),
       );

  ///
  /// INIT
  ///

  void init() {
    final now = DateTime.now();

    /// Update `state` with proper values
    updateState(
      textImageValid: (passedMeal?.originalText?.isNotEmpty ?? false) || passedMeal?.imageStoragePath != null,
      mealDate: isCopyingMeal ? now : passedMeal?.createdAt ?? now,
      mealTime: isCopyingMeal ? now : passedMeal?.createdAt ?? now,
    );

    /// Update [TextEditingController] text
    textEditingController.text = passedMeal?.originalText ?? '';

    /// Add validation listener to [TextEditingController]
    textEditingController.addListener(triggerValidation);
    textFocusNode.addListener(stopSpeechToTextIfTextFieldFocused);

    /// Trigger validation
    triggerValidation();
  }

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    /// Stop listener & update `state`
    if (speechToText.value.isListening) {
      speechToText.stopListening();
    }

    speechToText.updateState(
      isListening: false,
    );

    /// Dispose [TextEditingController]
    textEditingController
      ..removeListener(triggerValidation)
      ..dispose();

    /// Dispose [FocusNode]
    textFocusNode
      ..removeListener(stopSpeechToTextIfTextFieldFocused)
      ..dispose();
  }

  ///
  /// VARIABLES
  ///

  late final textEditingController = TextEditingController();
  late final textFocusNode = FocusNode();
  late final imagePicker = ImagePicker();

  ///
  /// METHODS
  ///

  /// Checks if validation passed
  void triggerValidation() {
    final isTextValidated = textEditingController.text.trim().isNotEmpty;
    final isImageValidated = value.imageFile != null || passedMeal?.imageStoragePath != null;

    updateState(
      textImageValid: isTextValidated || isImageValidated,
    );
  }

  /// Stop speech recognition if [TextField] becomes active
  Future<void> stopSpeechToTextIfTextFieldFocused() async {
    if (!textFocusNode.hasFocus) {
      return;
    }

    await stopSpeechToTextIfListening();
  }

  /// Stop speech recognition when the user starts editing text manually
  Future<void> stopSpeechToTextIfListening() async {
    if (!speechToText.value.isListening) {
      return;
    }

    await speechToText.stopListening();
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
      /// Copy image into app storage
      final imageFile = await persistImage(
        imagePath: image.path,
      );

      /// Update `state` with new image
      updateState(
        imageFile: imageFile,
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
      /// Copy image into app storage
      final imageFile = await persistImage(
        imagePath: image.path,
      );

      /// Update `state` with new image
      updateState(
        imageFile: imageFile,
      );

      /// Trigger validation
      triggerValidation();
    }
  }

  /// Opens [CalendarSheet] and updates the selected `date`
  Future<void> updateDateViaPicker(BuildContext context) async => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: BokunSpizeColors.white,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(listTileRadius),
      ),
    ),
    builder: (context) => CalendarSheet(
      dateValue: value.mealDate,
      onDateChanged: (newDate) => updateState(
        mealDate: newDate,
      ),
      primaryColor: BokunSpizeColors.green,
    ),
  );

  /// Opens [TimeSheet] and updates the selected `date`
  Future<void> updateTimeViaPicker(BuildContext context) async => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: BokunSpizeColors.white,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(listTileRadius),
      ),
    ),
    builder: (context) => TimeSheet(
      dateValue: value.mealTime,
      onDateChanged: (newDate) => updateState(
        mealTime: newDate,
      ),
      primaryColor: BokunSpizeColors.green,
    ),
  );

  /// Updates `state`
  void updateState({
    bool? textImageValid,
    Object? speechToTextWords = nullStateNoChange,
    bool? dateEditMode,
    bool? timeEditMode,
    DateTime? mealDate,
    DateTime? mealTime,
    Object? imageFile = nullStateNoChange,
  }) => value = (
    textImageValid: textImageValid ?? value.textImageValid,
    speechToTextWords: identical(speechToTextWords, nullStateNoChange) ? value.speechToTextWords : speechToTextWords as String?,
    mealDate: mealDate ?? value.mealDate,
    mealTime: mealTime ?? value.mealTime,
    imageFile: identical(imageFile, nullStateNoChange) ? value.imageFile : imageFile as File?,
  );
}
