import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:uuid/uuid.dart';

import '../../models/meal/meal.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/extensions.dart';
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
    isDisposed = true;
    mealsSubscription?.cancel();
    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  StreamSubscription<List<Meal>>? mealsSubscription;

  final pendingAIMeals = <String, Meal>{};
  final submittingAIMeals = <String>{};
  final cancelledAIMeals = <String>{};
  List<Meal> streamedMeals = [];

  var isDisposed = false;

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
    streamedMeals = [];
    updateState(
      activeDate: date,
      meals: getVisibleMeals(
        date: date,
      ),
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

            streamedMeals = meals;
            for (final meal in meals) {
              pendingAIMeals.remove(meal.id);
            }

            updateState(
              meals: getVisibleMeals(date: value.activeDate),
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
    if (pendingAIMeals.containsKey(meal.id) && submittingAIMeals.contains(meal.id)) {
      cancelledAIMeals.add(meal.id);
      pendingAIMeals.remove(meal.id);
      updateState(meals: getVisibleMeals(date: value.activeDate));
      return;
    }

    final success = await firebase.deleteMeal(
      meal: meal,
    );

    if (success) {
      pendingAIMeals.remove(meal.id);
      updateState(
        meals: getVisibleMeals(
          date: value.activeDate,
        ),
      );
    }

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
      subtitle: 'View your activity and progress',
      primaryColor: context.colors.protein,
      dateValue: value.activeDate,
      onDateChanged: (newDate) {
        HapticFeedback.lightImpact();
        updateDate(newDate);
      },
      showConfirmButton: false,
    ),
  );

  /// Triggered when the user presses `FAB` to add `AI meal`
  Future<void> onAddAIMealPressed(
    BuildContext context, {
    required String languageCode,
  }) async {
    /// Generate `newMealId`
    final newMealId = const Uuid().v1();

    /// Show [AIAddMealScreen] for adding `AI meal`
    final result = await showBlurredModalBottomSheet<AIMealResult>(
      context: context,
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
      languageCode: languageCode,
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

  /// Combines temporary photo uploads with the meal documents received from `Firebase`
  List<Meal> getVisibleMeals({required DateTime date}) {
    final mealsById = {
      ...pendingAIMeals,
      for (final meal in streamedMeals) meal.id: meal,
    };
    return mealsById.values
        .where(
          (meal) => DateUtils.isSameDay(
            meal.createdAt,
            date,
          ),
        )
        .toList()
      ..sort(
        (first, second) => second.createdAt.compareTo(
          first.createdAt,
        ),
      );
  }

  /// Uploads the photo and submits a durable job whose outcome arrives through the meal listener
  Future<bool> createAIMeal({
    required AIMealResult result,
    required String newMealId,
    required String languageCode,
  }) async {
    final userId = firebase.auth.currentUser?.uid;
    if (!isValidAIMealResult(result) || userId == null) {
      return false;
    }

    final text = result.words?.trim();
    final loadingMeal = Meal(
      id: newMealId,
      createdAt: result.dateTime!,
      originalText: text == null || text.isEmpty ? null : text,
      isLoading: true,
    );

    /// Show upload progress before Firebase has received the meal request
    pendingAIMeals[newMealId] = loadingMeal;
    submittingAIMeals.add(newMealId);
    updateDate(
      loadingMeal.createdAt,
    );
    updateState(
      meals: getVisibleMeals(
        date: value.activeDate,
      ),
    );

    var submitted = false;
    try {
      final imageFile = result.imageFile;
      final imageStoragePath = imageFile == null ? null : await firebase.uploadMealImage(imageFile: imageFile);
      if (imageFile != null && imageStoragePath == null) {
        return false;
      }

      /// Cancelling during upload prevents the AI request from being submitted
      if (cancelledAIMeals.contains(newMealId)) {
        return imageStoragePath == null ||
            await firebase.deleteMealImageIfUnused(
              imageStoragePath: imageStoragePath,
            );
      }

      pendingAIMeals[newMealId] = loadingMeal.copyWith(
        imageStoragePath: imageStoragePath,
      );

      await aiProvider().createMeal(
        userId: userId,
        mealId: newMealId,
        text: loadingMeal.originalText,
        imageStoragePath: imageStoragePath,
        createdAt: loadingMeal.createdAt,
        languageCode: languageCode,
      );
      if (cancelledAIMeals.contains(newMealId)) {
        return await firebase.deleteMeal(
          meal: loadingMeal.copyWith(
            imageStoragePath: imageStoragePath,
          ),
        );
      }
      submitted = true;
      return true;
    } catch (error) {
      log('Submitting AI meal failed', error: error);
      return false;
    } finally {
      /// A server meal may already be visible even if the callable response was lost
      if (!submitted) {
        pendingAIMeals.remove(newMealId);
      }
      cancelledAIMeals.remove(newMealId);
      submittingAIMeals.remove(newMealId);
      updateState(
        meals: getVisibleMeals(
          date: value.activeDate,
        ),
      );
    }
  }

  /// Opens [ManualAddMealScreen] to add, copy, or edit a meal
  Future<void> onAddManualMealPressed(
    BuildContext context, {
    required Meal? passedMeal,
    required bool isCopyingMeal,
  }) async {
    final isEditingMeal = passedMeal != null && !isCopyingMeal;

    /// Keep the existing `mealId` when editing
    final mealId = isEditingMeal ? passedMeal.id : const Uuid().v1();

    /// Show [ManualAddMealScreen]
    final result = await showBlurredModalBottomSheet<ManualMealResult>(
      context: context,
      builder: (context) => ManualAddMealScreen(
        mealId: mealId,
        passedMeal: passedMeal,
        isCopyingMeal: isCopyingMeal,
      ),
    );

    /// Sheet was dismissed, do nothing
    if (result == null) {
      return;
    }

    /// Save edits to the original `meal` or create a new entry
    final success = isEditingMeal
        ? await updateManualMeal(
            result: result,
            passedMeal: passedMeal,
          )
        : await createManualMeal(
            result: result,
            newMealId: mealId,
            passedMeal: passedMeal,
            isCopyingMeal: isCopyingMeal,
          );

    /// Saving failed, show error snackbar
    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: isEditingMeal ? 'Update failed' : 'Add failed',
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Saves a copied meal or a loading manual meal followed by its completed data
  Future<bool> createManualMeal({
    required ManualMealResult result,
    required String newMealId,
    required Meal? passedMeal,
    required bool isCopyingMeal,
  }) async {
    final dateTime = result.dateTime;

    /// Return if the meal date is missing
    if (dateTime == null) {
      return false;
    }

    try {
      /// Meal is being copied
      if (isCopyingMeal && passedMeal != null) {
        /// Upload copied meal to [Firebase]
        final mealWritten = await firebase.writeMeal(
          newMeal: passedMeal.copyWith(
            id: newMealId,
            createdAt: dateTime,
          ),
        );

        if (mealWritten) {
          /// Show the date where the newly saved meal belongs
          updateDate(dateTime);
        }

        return mealWritten;
      }

      /// Save `loading meal` so it appears while the image uploads
      final loadingMeal = Meal(
        id: newMealId,
        createdAt: dateTime,
        isLoading: true,
      );

      /// Write `loading meal` to [Firebase]
      final loadingMealWritten = await firebase.writeMeal(
        newMeal: loadingMeal,
      );

      if (!loadingMealWritten) {
        return false;
      }

      /// Show the date where the new `meal` belongs
      updateDate(
        loadingMeal.createdAt,
      );

      /// Upload the image and prepare the completed manual `meal`
      final outcome = await processManualMeal(
        loadingMeal: loadingMeal,
        result: result,
      );

      /// Update completed `meal` to [Firebase]
      final mealUpdated = await firebase.updateMeal(
        newMeal: outcome.meal,
      );

      return mealUpdated && outcome.success;
    } catch (error) {
      log(
        'Adding manual meal failed',
        error: error,
      );
      return false;
    }
  }

  /// Saves edits to the existing `meal` and shows its selected date
  Future<bool> updateManualMeal({
    required ManualMealResult result,
    required Meal passedMeal,
  }) async {
    if (result.dateTime == null) {
      return false;
    }

    try {
      final outcome = await processManualMeal(
        loadingMeal: passedMeal,
        result: result,
      );

      /// Keep the original `meal` intact if the replacement image fails to upload
      if (!outcome.success) {
        return false;
      }

      final mealUpdated = await firebase.updateMeal(
        newMeal: outcome.meal,
      );

      if (mealUpdated) {
        updateDate(
          outcome.meal.createdAt,
        );

        /// Clean up removed or replaced images only after the edited meal is saved
        final previousImageStoragePath = passedMeal.imageStoragePath;

        if (previousImageStoragePath != null && previousImageStoragePath != outcome.meal.imageStoragePath) {
          return await firebase.deleteMealImageIfUnused(
            imageStoragePath: previousImageStoragePath,
          );
        }
      }

      return mealUpdated;
    } catch (error) {
      log(
        'Updating manual meal failed',
        error: error,
      );
      return false;
    }
  }

  /// Upload image and return finished manual `meal` containing its data or errors
  Future<({Meal meal, bool success})> processManualMeal({
    required Meal loadingMeal,
    required ManualMealResult result,
  }) async {
    final imageFile = result.imageFile;
    final imageStoragePath = imageFile != null
        ? await firebase.uploadMealImage(
            imageFile: imageFile,
          )
        : result.imageStoragePath;
    final imageUploadFailed = imageFile != null && imageStoragePath == null;

    /// Finish loading and preserve the meal data even if the image upload fails
    return (
      meal: Meal(
        id: loadingMeal.id,
        createdAt: result.dateTime ?? loadingMeal.createdAt,
        emoji: loadingMeal.emoji,
        color: loadingMeal.color,
        originalText: loadingMeal.originalText,
        name: result.name,
        nutrition: result.nutrition,
        foods: result.foods,
        imageStoragePath: imageStoragePath,
        isLoading: false,
        errors: imageUploadFailed ? ['Image upload failed'] : null,
      ),
      success: !imageUploadFailed,
    );
  }

  /// Updates `state`
  void updateState({
    DateTime? activeDate,
    List<Meal>? meals,
    bool? isLoading,
    Object? error = nullStateNoChange,
  }) {
    if (isDisposed) {
      return;
    }

    value = (
      activeDate: activeDate ?? value.activeDate,
      meals: meals ?? value.meals,
      isLoading: isLoading ?? value.isLoading,
      error: identical(error, nullStateNoChange) ? value.error : error as String?,
    );
  }
}
