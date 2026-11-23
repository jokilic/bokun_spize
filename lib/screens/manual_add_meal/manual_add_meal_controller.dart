import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

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

class ManualAddMealController extends ValueNotifier<({bool validation, List<Food>? foods, DateTime mealDate, DateTime mealTime, File? imageFile, String? imageStoragePath})>
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

    super.dispose();
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
    required String languageCode,
    required bool speechToTextAvailable,
  }) async {
    if (!speechToTextAvailable) {
      await speechToText.loadSpeechToText();
    }

    /// Save current [TextEditingController] text
    final currentText = nameTextEditingController.text;

    /// [SpeechToText] was disabled, start listening
    if (!speechToText.value.isListening) {
      await speechToText.startListening(
        onResult: (words) {
          /// Add new `words` to [TextEditingController]
          if (currentText.isNotEmpty) {
            nameTextEditingController.text = '$currentText $words';
          } else {
            nameTextEditingController.text = words;
          }
        },
        locale: languageCode,
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
      showConfirmButton: true,
      subtitle: passedMeal != null && !isCopyingMeal ? 'manualAddMealCalendarSheetEditSubtitle'.tr() : 'dayOfNewMeal'.tr(),
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
      subtitle: passedMeal != null && !isCopyingMeal ? 'manualAddMealTimeSheetEditSubtitle'.tr() : 'timeOfNewMeal'.tr(),
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
    Object? foods = nullStateNoChange,
    DateTime? mealDate,
    DateTime? mealTime,
    Object? imageFile = nullStateNoChange,
    Object? imageStoragePath = nullStateNoChange,
  }) => value = (
    validation: validation ?? value.validation,
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
