import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../models/meal/food.dart';
import '../../models/meal/meal.dart';
import '../../services/speech_to_text_service.dart';
import '../../theme/extensions.dart';
import '../../util/date_time.dart';
import '../../util/format.dart';
import '../../util/null_state.dart';
import '../../util/path.dart';
import '../../widgets/add_food_sheet.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import '../../widgets/calendar_sheet.dart';
import '../../widgets/time_sheet.dart';

class ManualAddMealController
    extends ValueNotifier<({bool validation, String? speechToTextWords, List<Food>? foods, DateTime mealDate, DateTime mealTime, File? imageFile, String? imageStoragePath})>
    implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final SpeechToTextService speechToText;
  final Meal? passedMeal;
  final bool isCopyingMeal;

  ManualAddMealController({
    required this.speechToText,
    required this.passedMeal,
    required this.isCopyingMeal,
  }) : super(
         (
           validation: false,
           speechToTextWords: null,
           foods: null,
           mealDate: DateTime.now(),
           mealTime: DateTime.now(),
           imageFile: null,
           imageStoragePath: null,
         ),
       );

  ///
  /// INIT
  ///

  /// Initializes the form with the passed meal and registers validation listeners
  void init() {
    final meal = passedMeal;
    final mealTime = meal != null && !isCopyingMeal
        ? meal.createdAt
        : roundUpToFiveMinuteInterval(
            DateTime.now(),
          );

    /// Preserve the original date and time when editing an existing meal
    updateState(
      foods: meal?.foods,
      imageStoragePath: meal?.imageStoragePath,
      mealDate: mealTime,
      mealTime: mealTime,
    );

    /// Update [TextEditingController] text
    nameTextEditingController.text = meal?.name ?? '';
    caloriesTextEditingController.text =
        formatNutritionValue(
          meal?.nutrition?.calories,
        ) ??
        '';
    proteinTextEditingController.text =
        formatNutritionValue(
          meal?.nutrition?.protein,
        ) ??
        '';
    carbsTextEditingController.text =
        formatNutritionValue(
          meal?.nutrition?.carbs,
        ) ??
        '';
    fatsTextEditingController.text =
        formatNutritionValue(
          meal?.nutrition?.fat,
        ) ??
        '';

    /// Add validation listener to [TextEditingController]
    nameTextEditingController.addListener(triggerValidation);
    nameFocusNode.addListener(stopSpeechToTextIfTextFieldFocused);

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
    nameTextEditingController
      ..removeListener(triggerValidation)
      ..dispose();

    /// Dispose [FocusNode]
    nameFocusNode
      ..removeListener(stopSpeechToTextIfTextFieldFocused)
      ..dispose();

    /// Dispose other [TextEditingControllers]
    caloriesTextEditingController.dispose();
    proteinTextEditingController.dispose();
    carbsTextEditingController.dispose();
    fatsTextEditingController.dispose();

    /// Dispose other [FocusNodes]
    caloriesFocusNode.dispose();
    proteinFocusNode.dispose();
    carbsFocusNode.dispose();
    fatsFocusNode.dispose();
  }

  ///
  /// VARIABLES
  ///

  late final nameTextEditingController = TextEditingController();
  late final nameFocusNode = FocusNode();

  late final caloriesTextEditingController = TextEditingController();
  late final caloriesFocusNode = FocusNode();

  late final proteinTextEditingController = TextEditingController();
  late final proteinFocusNode = FocusNode();
  late final carbsTextEditingController = TextEditingController();
  late final carbsFocusNode = FocusNode();
  late final fatsTextEditingController = TextEditingController();
  late final fatsFocusNode = FocusNode();

  late final imagePicker = ImagePicker();

  ///
  /// METHODS
  ///

  /// Checks if validation passed
  void triggerValidation() {
    final isTextValidated = nameTextEditingController.text.trim().isNotEmpty;
    final isImageValidated = value.imageFile != null || value.imageStoragePath != null;

    updateState(
      validation: isTextValidated || isImageValidated,
    );
  }

  /// Removes the current image from the form before saving or choosing a replacement
  void removeImage() {
    updateState(
      imageFile: null,
      imageStoragePath: null,
    );

    triggerValidation();
  }

  /// Adds a food item without changing the existing list
  void addFood({required Food food}) => updateState(
    foods: [
      ...?value.foods,
      food,
    ],
  );

  /// Replaces a food item at the selected `index`
  void updateFood({
    required int index,
    required Food food,
  }) {
    final foods = [
      ...?value.foods,
    ];
    foods[index] = food;

    updateState(
      foods: foods,
    );
  }

  /// Deletes the `food` item at the selected `index`
  void deleteFood({required int index}) {
    final foods = [
      ...?value.foods,
    ]..removeAt(index);

    updateState(
      foods: foods,
    );
  }

  /// Stop speech recognition if [TextField] becomes active
  Future<void> stopSpeechToTextIfTextFieldFocused() async {
    if (!nameFocusNode.hasFocus) {
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
    final currentText = nameTextEditingController.text;

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
            nameTextEditingController.text = '$currentText $words';
          } else {
            nameTextEditingController.text = words;
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
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    /// Image is taken, update `state`
    if (image != null) {
      /// Center the camera image to a `1:1 aspect ratio`
      final imageBytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        return;
      }

      final orientedImage = img.bakeOrientation(decodedImage);
      final squareSize = min(
        orientedImage.width,
        orientedImage.height,
      );

      final squareImage = img.copyCrop(
        orientedImage,
        x: (orientedImage.width - squareSize) ~/ 2,
        y: (orientedImage.height - squareSize) ~/ 2,
        width: squareSize,
        height: squareSize,
      );

      await File(image.path).writeAsBytes(
        img.encodeJpg(
          squareImage,
          quality: 50,
        ),
      );

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

  /// Triggered when the user presses `Add food` button
  Future<void> onAddFoodPressed(
    BuildContext context, {
    required Food? passedFood,
  }) async {
    /// Show [AddFoodSheet] for adding `food`
    final result = await showBlurredModalBottomSheet<Food>(
      context: context,
      builder: (context) => AddFoodSheet(
        passedFood: passedFood,
      ),
    );

    if (result == null) {
      return;
    }

    /// `passedFood` exists, update it
    if (passedFood != null) {
      /// Find proper `index`
      final index =
          value.foods?.indexWhere(
            (food) => identical(food, passedFood),
          ) ??
          -1;

      /// Update proper `food`
      if (index != -1) {
        updateFood(
          index: index,
          food: result,
        );
      }

      return;
    }

    /// Add `food` to `state`
    addFood(
      food: result,
    );
  }

  /// Opens [CalendarSheet] and updates the selected `date`
  Future<void> updateDateViaPicker(BuildContext context) async => showBlurredModalBottomSheet(
    context: context,
    builder: (context) => CalendarSheet(
      subtitle: passedMeal != null && !isCopyingMeal ? 'Day of meal' : 'Day of new meal',
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
      subtitle: passedMeal != null && !isCopyingMeal ? 'Time of meal' : 'Time of new meal',
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
    Object? foods = nullStateNoChange,
    DateTime? mealDate,
    DateTime? mealTime,
    Object? imageFile = nullStateNoChange,
    Object? imageStoragePath = nullStateNoChange,
  }) => value = (
    validation: validation ?? value.validation,
    speechToTextWords: identical(speechToTextWords, nullStateNoChange) ? value.speechToTextWords : speechToTextWords as String?,
    foods: identical(foods, nullStateNoChange)
        ? value.foods
        : foods == null
        ? null
        : List<Food>.unmodifiable(foods as List<Food>),
    mealDate: mealDate ?? value.mealDate,
    mealTime: mealTime ?? value.mealTime,
    imageFile: identical(imageFile, nullStateNoChange) ? value.imageFile : imageFile as File?,
    imageStoragePath: identical(imageStoragePath, nullStateNoChange) ? value.imageStoragePath : imageStoragePath as String?,
  );
}
