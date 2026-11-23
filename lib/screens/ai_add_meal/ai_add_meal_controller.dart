import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/analytics_service.dart';
import '../../services/speech_to_text_service.dart';
import '../../theme/extensions.dart';
import '../../util/analytics.dart';
import '../../util/date_time.dart';
import '../../util/null_state.dart';
import '../../util/path.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import '../../widgets/calendar_sheet.dart';
import '../../widgets/time_sheet.dart';

class AIAddMealController extends ValueNotifier<({bool validation, String? speechToTextWords, DateTime mealDate, DateTime mealTime, File? imageFile})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final SpeechToTextService speechToText;
  final AnalyticsService analytics;

  AIAddMealController({
    required this.speechToText,
    required this.analytics,
  }) : super(
         (
           validation: false,
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
    final newMealTime = roundUpToFiveMinuteInterval(
      DateTime.now(),
    );

    /// Update `state` with proper values
    updateState(
      validation: false,
      mealDate: newMealTime,
      mealTime: newMealTime,
    );

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

    super.dispose();
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

  /// Requires a photo or nonblank description
  void triggerValidation() {
    final hasDescription = textEditingController.text.trim().isNotEmpty;

    updateState(
      validation: hasDescription || value.imageFile != null,
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
        surface: VoiceInputSurface.aiMeal,
      );
    }
    /// [SpeechToText] was enabled, stop listening
    else {
      await speechToText.stopListening();
    }
  }

  /// Selects a meal image using the camera
  Future<void> onCameraPressed() => selectMealImage(ImageSource.camera);

  /// Selects a meal image from the gallery
  Future<void> onGalleryPressed() => selectMealImage(ImageSource.gallery);

  /// Updates the form once a meal image is ready
  Future<void> selectMealImage(ImageSource source) async {
    final imageFile = await pickMealImage(
      imagePicker: imagePicker,
      source: source,
    );
    if (imageFile == null) {
      return;
    }

    updateState(
      imageFile: imageFile,
    );

    triggerValidation();

    unawaited(
      analytics.record(
        AnalyticsEvent.mealPhotoAdded,
        parameters: {
          'source': source.name,
          'surface': VoiceInputSurface.aiMeal.eventValue,
        },
      ),
    );
  }

  /// Opens [CalendarSheet] and updates the selected `date`
  Future<void> updateDateViaPicker(BuildContext context) async => showBlurredModalBottomSheet(
    context: context,
    builder: (context) => CalendarSheet(
      showConfirmButton: true,
      subtitle: 'dayOfNewMeal'.tr(),
      primaryColor: context.colors.protein,
      dateValue: value.mealDate,
      onDateChanged: (newDate) {
        HapticFeedback.lightImpact();
        updateState(
          mealDate: newDate,
        );
      },
    ),
  );

  /// Opens [TimeSheet] and updates the selected `date`
  Future<void> updateTimeViaPicker(BuildContext context) async => showBlurredModalBottomSheet(
    context: context,
    builder: (context) => TimeSheet(
      subtitle: 'timeOfNewMeal'.tr(),
      primaryColor: context.colors.protein,
      dateValue: value.mealTime,
      onTimeChanged: (newTime) {
        HapticFeedback.lightImpact();
        updateState(
          mealTime: newTime,
        );
      },
    ),
  );

  /// Updates `state`
  void updateState({
    bool? validation,
    Object? speechToTextWords = nullStateNoChange,
    bool? dateEditMode,
    bool? timeEditMode,
    DateTime? mealDate,
    DateTime? mealTime,
    Object? imageFile = nullStateNoChange,
  }) => value = (
    validation: validation ?? value.validation,
    speechToTextWords: identical(speechToTextWords, nullStateNoChange) ? value.speechToTextWords : speechToTextWords as String?,
    mealDate: mealDate ?? value.mealDate,
    mealTime: mealTime ?? value.mealTime,
    imageFile: identical(imageFile, nullStateNoChange) ? value.imageFile : imageFile as File?,
  );
}
