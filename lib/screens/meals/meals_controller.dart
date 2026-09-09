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

  /// Deletes `meal` from [Firebase]
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
      ),
    );

    /// Sheet was dismissed, do nothing
    if (result == null) {
      return;
    }

    /// Create and save the AI meal
    final success = await createAIMeal(
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

  /// Save a `loading meal` in [Firebase], then replaces it with the `AI outcome`
  Future<bool> createAIMeal({
    required AIMealResult result,
    required String newMealId,
  }) async {
    /// Trigger validation and return if fail
    if (!isValidAIMealResult(result)) {
      return false;
    }

    /// Create `loading meal`
    final loadingMeal = Meal(
      id: newMealId,
      createdAt: result.dateTime!,
      originalText: result.words?.trim(),
      isLoading: true,
    );

    try {
      /// Write `loading meal` to [Firebase]
      final loadingMealWritten = await firebase.writeMeal(
        newMeal: loadingMeal,
      );

      if (!loadingMealWritten) {
        return false;
      }

      /// Show the date where the newly saved `meal` belongs
      updateDate(
        loadingMeal.createdAt,
      );

      /// Trigger AI logic
      final outcome = await processAIMeal(
        loadingMeal: loadingMeal,
        imageFile: result.imageFile,
      );

      /// Update `meal` in [Firebase] with new values
      final mealUpdated = await firebase.updateMeal(
        newMeal: outcome.meal,
      );

      return mealUpdated && outcome.success;
    } catch (error) {
      log(
        'Adding AI meal failed',
        error: error,
      );
      return false;
    }
  }

  /// Runs AI alongside image uploading and returns a finished `meal` containing parsed data or errors
  Future<({Meal meal, bool success})> processAIMeal({
    required Meal loadingMeal,
    required File? imageFile,
  }) async {
    /// Start both operations and wait for them to finish before processing their results
    final results = await Future.wait(
      [
        /// AI logic
        aiProvider().triggerAI(
          textPrompt: loadingMeal.originalText,
          imageFile: imageFile,
        ),

        /// Image uploading logic
        if (imageFile != null)
          firebase.uploadMealImage(
            imageFile: imageFile,
          )
        else
          Future<String?>.value(),
      ],
    );

    final result = results.first! as ({String? aiResult, List<String>? errors});
    final imageStoragePath = results.last as String?;

    final aiResult = result.aiResult;

    /// Parse result to proper [Meal] instance
    final meal = aiResult == null
        ? null
        : parseAIResultToMeal(
            aiResult: aiResult,
            id: loadingMeal.id,
            createdAt: loadingMeal.createdAt,
            originalText: loadingMeal.originalText,
            imageStoragePath: imageStoragePath,
          );

    /// Keep errors while allowing fallback AI model to recover
    final errors = [
      if (aiResult == null) ...?result.errors,
      if (aiResult != null && meal == null) 'Meal failed decoding',
      if (imageFile != null && imageStoragePath == null) 'Image failed to save',
    ];

    return (
      meal: (meal ?? loadingMeal).copyWith(
        errors: errors.isEmpty ? null : errors,
        imageStoragePath: imageStoragePath,
        isLoading: false,
      ),
      success: meal != null && errors.isEmpty,
    );
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
      try {
        if (isCopyingMeal && passedMeal != null) {
          /// Copy the meal while keeping its shared image reference
          success = await firebase.writeMeal(
            newMeal: passedMeal.copyWith(
              id: newMealId,
              createdAt: dateTime,
              imageStoragePath: passedMeal.imageStoragePath,
            ),
          );

          if (success) {
            updateDate(dateTime);
          }
        } else {
          /// Save a loading meal so it appears while the image uploads
          final loadingMeal = Meal(
            id: newMealId,
            createdAt: dateTime,
            isLoading: true,
          );

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
