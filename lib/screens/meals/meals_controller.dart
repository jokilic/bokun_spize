import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../models/meal/meal.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../util/null_state.dart';
import '../../util/parse.dart';
import '../../util/snackbars.dart';
import '../../util/typedefs.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import '../../widgets/calendar_sheet.dart';
import '../ai_add_meal/ai_add_meal_screen.dart';
import '../manual_add_meal/manual_add_meal_screen.dart';

class MealsController extends ValueNotifier<({DateTime activeDate, List<Meal> meals, bool isLoading, String? error})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;
  final AIService Function() aiProvider;

  MealsController({
    required this.firebase,
    required this.aiProvider,
  }) : super((
         activeDate: DateUtils.dateOnly(
           DateTime.now(),
         ),
         meals: const [],
         isLoading: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  void init() => listenToMeals(
    date: value.activeDate,
  );

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    mealsSubscription?.cancel();
    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  StreamSubscription<List<Meal>>? mealsSubscription;

  ///
  /// METHODS
  ///

  /// Updates the active `date` and switches the meal listener to that day
  void updateDate(DateTime newValue) {
    final selectedDate = DateUtils.dateOnly(newValue);

    if (DateUtils.isSameDay(value.activeDate, selectedDate)) {
      return;
    }

    listenToMeals(
      date: selectedDate,
    );
  }

  /// Listens to meals from [date] and updates the loading and error state
  void listenToMeals({required DateTime date}) {
    updateState(
      activeDate: date,
      meals: const [],
      isLoading: true,
      error: null,
    );

    mealsSubscription?.cancel();

    mealsSubscription = firebase
        .listenToMeals(date: date)
        .listen(
          (meals) {
            if (!DateUtils.isSameDay(value.activeDate, date)) {
              return;
            }

            updateState(
              meals: meals,
              isLoading: false,
              error: null,
            );
          },
          onError: (error) {
            if (!DateUtils.isSameDay(value.activeDate, date)) {
              return;
            }

            log(
              'Listening to meals failed',
              error: error,
            );

            updateState(
              meals: const [],
              isLoading: false,
              error: 'Meals could not be loaded.',
            );
          },
        );
  }

  /// Restarts the listener after an error
  void retryMeals() => listenToMeals(
    date: value.activeDate,
  );

  /// Deletes [meal] from Firebase
  Future<void> deleteMeal({
    required Meal meal,
    required BuildContext context,
  }) async {
    final success = await firebase.deleteMeal(
      meal: meal,
    );

    /// Delete failed, show error snackbar
    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: 'Delete failed',
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Opens [CalendarSheet] and updates the selected `date`
  Future<void> updateDateViaPicker(BuildContext context) async => showBlurredModalBottomSheet(
    context: context,
    builder: (context) => CalendarSheet(
      primaryColor: BokunSpizeColors.green,
      dateValue: value.activeDate,
      onDateChanged: (newDate) {
        HapticFeedback.lightImpact();
        updateDate(newDate);
      },
      showConfirmButton: false,
    ),
  );

  /// Triggered when the user presses `FAB` to add `AI meal`
  Future<void> onAddAIMealPressed(BuildContext context) async {
    /// Generate `newMealId`
    final newMealId = const Uuid().v1();

    /// Show [AIAddMealScreen] for adding `AI meal`
    final result = await showBlurredModalBottomSheet<AIMealResult>(
      context: context,
      backgroundColor: BokunSpizeColors.grey,
      builder: (context) => AIAddMealScreen(
        mealId: newMealId,
        passedMeal: null,
        isCopyingMeal: false,
      ),
    );

    if (result == null) {
      return;
    }

    /// Run `AI` logic
    final success = await validateAndRunAILogic(
      result: result,
      newMealId: newMealId,
    );

    /// Add failed, show error snackbar
    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: 'Add failed',
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Triggered when the user presses `FAB` to add `manual meal`
  Future<void> onAddManualMealPressed(
    BuildContext context, {
    required Meal? passedMeal,
    required bool isCopyingMeal,
  }) async {
    /// Generate `newMealId`
    final newMealId = const Uuid().v1();

    /// Show [ManualAddMealScreen] for adding `manual meal`
    final result = await showBlurredModalBottomSheet<ManualMealResult>(
      context: context,
      backgroundColor: BokunSpizeColors.grey,
      builder: (context) => ManualAddMealScreen(
        mealId: newMealId,
        passedMeal: passedMeal,
        isCopyingMeal: isCopyingMeal,
      ),
    );

    if (result == null) {
      return;
    }

    var success = false;
    final dateTime = result.dateTime;
    final imageFile = result.imageFile;

    if (dateTime != null) {
      /// Save a loading meal so it appears while the image uploads
      final loadingMeal = Meal(
        id: newMealId,
        createdAt: dateTime,
        isLoading: true,
      );

      try {
        final loadingMealWritten = await firebase.writeMeal(
          newMeal: loadingMeal,
        );

        if (loadingMealWritten) {
          updateDate(dateTime);

          final imageStoragePath = imageFile != null
              ? await firebase.uploadMealImage(
                  imageFile: imageFile,
                )
              : null;
          final imageUploadFailed = imageFile != null && imageStoragePath == null;

          /// Finish loading and preserve the meal data even if the image upload fails
          final meal = loadingMeal.copyWith(
            name: result.name,
            nutrition: result.nutrition,
            foods: result.foods,
            imageStoragePath: imageStoragePath,
            isLoading: false,
            errors: imageUploadFailed ? ['Image upload failed'] : null,
          );

          final mealUpdated = await firebase.updateMeal(
            newMeal: meal,
          );

          success = mealUpdated && !imageUploadFailed;
        }
      } catch (error) {
        log(
          'Adding manual meal failed',
          error: error,
        );
        success = false;
      }
    }

    /// Add failed, show error snackbar
    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: 'Add failed',
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  Future<bool> validateAndRunAILogic({
    required AIMealResult result,
    required String newMealId,
  }) async {
    /// Check if `words` and `image` exists
    final hasWords = result.words?.trim().isNotEmpty ?? false;
    final hasImage = result.imageFile != null;

    /// Data missing, return
    if ((!hasWords && !hasImage) || result.dateTime == null) {
      return false;
    }

    /// Trigger AI which generates a new `meal` and stores into [Firebase]
    return triggerAIAndFinishCreatingMeal(
      newMealId: newMealId,
      textPrompt: result.words,
      imageFile: result.imageFile,
      dateTime: result.dateTime!,
    );
  }

  /// Creates a loading `meal`, processes it with AI, and persists the result in [Firebase]
  Future<bool> triggerAIAndFinishCreatingMeal({
    required String newMealId,
    required String? textPrompt,
    required File? imageFile,
    required DateTime dateTime,
  }) async {
    /// Get `trimmedPrompt`
    final trimmedPrompt = textPrompt?.trim();

    /// Create `loadingMeal` with loading state
    final loadingMeal = Meal(
      id: newMealId,
      createdAt: dateTime,
      originalText: trimmedPrompt,
      isLoading: true,
    );

    try {
      /// Write `loadingMeal` to [Firebase]
      final loadingMealWritten = await firebase.writeMeal(
        newMeal: loadingMeal,
      );

      /// Return if `meal` isn't written to [Firebase]
      if (!loadingMealWritten) {
        return false;
      }

      /// Show the date where the newly saved meal belongs
      updateDate(dateTime);

      /// Trigger AI
      final result = await aiProvider().triggerAI(
        textPrompt: trimmedPrompt,
        imageFile: imageFile,
      );

      /// There is no proper result, update `meal` with `errors` in [Firebase]
      if (result.aiResult == null) {
        await firebase.updateMeal(
          newMeal: loadingMeal.copyWith(
            errors: result.errors,
            imageStoragePath: result.imageStoragePath,
            isLoading: false,
          ),
        );
        return false;
      }

      /// Parse AI response into [Meal] model
      final meal = parseAIResultToMeal(
        aiResult: result.aiResult!,
        id: loadingMeal.id,
        createdAt: loadingMeal.createdAt,
        originalText: trimmedPrompt,
        imageStoragePath: result.imageStoragePath,
      );

      /// Result exists, update `meal` with newly parsed values in [Firebase]
      if (meal != null) {
        return await firebase.updateMeal(
          newMeal: meal,
        );
      }

      /// Some weird error happened, update `meal` with `error`
      await firebase.updateMeal(
        newMeal: loadingMeal.copyWith(
          errors: ['Obrok nije dekodiran'],
          imageStoragePath: result.imageStoragePath,
          isLoading: false,
        ),
      );
      return false;
    } catch (error) {
      log(
        'Adding AI meal failed',
        error: error,
      );
      return false;
    }
  }

  /// Updates `state`.
  void updateState({
    DateTime? activeDate,
    List<Meal>? meals,
    bool? isLoading,
    Object? error = nullStateNoChange,
  }) => value = (
    activeDate: activeDate ?? value.activeDate,
    meals: meals ?? value.meals,
    isLoading: isLoading ?? value.isLoading,
    error: identical(error, nullStateNoChange) ? value.error : error as String?,
  );
}
