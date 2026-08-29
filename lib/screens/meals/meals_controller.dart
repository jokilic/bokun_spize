import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../models/meal/meal.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../util/null_state.dart';
import '../../util/snackbars.dart';
import '../../util/typedefs.dart';
import '../../widgets/calendar_sheet.dart';
import '../add_meal/add_meal_screen.dart';

class MealsController extends ValueNotifier<({DateTime activeDate, List<Meal> meals, bool isLoading, String? error})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;
  final AIService ai;

  MealsController({
    required this.firebase,
    required this.ai,
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

  StreamSubscription<List<Meal>?>? mealsSubscription;

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

  /// Listens to meals from [date] and updates the loading and error state.
  void listenToMeals({required DateTime date}) {
    updateState(
      activeDate: date,
      meals: const [],
      isLoading: true,
      error: null,
    );

    unawaited(
      mealsSubscription?.cancel(),
    );

    mealsSubscription = firebase.listenToMeals(date: date).listen(
      (meals) {
        if (!DateUtils.isSameDay(value.activeDate, date)) {
          return;
        }

        updateState(
          meals: meals ?? const [],
          isLoading: false,
          error: meals == null ? 'Meals could not be loaded.' : null,
        );
      },
    );
  }

  /// Deletes [meal] from Firebase
  Future<void> deleteMeal({
    required Meal meal,
    required BuildContext context,
  }) async {
    final success = await firebase.deleteMeal(
      meal: meal,
    );

    /// Delete failed, show error snackbar
    if (!success) {
      showSnackbar(
        context,
        text: 'Delete failed',
        icon: PhosphorIconsBold.warningOctagon,
      );
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
      dateValue: value.activeDate,
      onDateChanged: updateDate,
      primaryColor: BokunSpizeColors.green,
    ),
  );

  /// Triggered when the user adds, edits, or copies a `meal`
  Future<void> onMealPressed(
    BuildContext context, {
    Meal? passedMeal,
    bool isCopyingMeal = false,
  }) async {
    /// Determine if user is editing existing `meal`
    final shouldEditExistingMeal = passedMeal != null && !isCopyingMeal;

    /// Generate `newMealId`
    final newMealId = const Uuid().v1();

    /// Show [AddMealScreen] for adding or editing `meal`
    final result = await showModalBottomSheet<MealSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BokunSpizeColors.grey,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(listTileRadius),
        ),
      ),
      builder: (context) => AddMealScreen(
        mealId: shouldEditExistingMeal ? passedMeal.id : newMealId,
        passedMeal: passedMeal,
        isCopyingMeal: isCopyingMeal,
      ),
    );

    /// User was editing existing `meal`
    if (shouldEditExistingMeal) {
      /// User deleted `meal`
      if (result?.deleteMeal ?? false) {
        await deleteMeal(
          meal: passedMeal,
          context: context,
        );
      }
      /// User changed `dateTime`
      else if (result?.dateTime != null && result?.dateTime != passedMeal.createdAt) {
        /// Update `dateTime` in [Firebase]
        await firebase.updateMeal(
          newMeal: passedMeal.copyWith(
            createdAt: result!.dateTime,
          ),
        );
      }

      return;
    }

    /// Check if `words` and `image` exists
    final hasWords = result?.words?.trim().isNotEmpty ?? false;
    final hasImage = result?.imageFile != null;
    final hasPersistedImage = isCopyingMeal && passedMeal?.imageStoragePath != null;

    /// Data missing, return
    if ((!hasWords && !hasImage && !hasPersistedImage) || result?.dateTime == null) {
      return;
    }

    /// Copy the meal while keeping its shared image reference
    if (isCopyingMeal && passedMeal != null) {
      await firebase.writeMeal(
        newMeal: passedMeal.copyWith(
          id: newMealId,
          createdAt: result!.dateTime,
          imageStoragePath: passedMeal.imageStoragePath,
        ),
      );
      return;
    }

    /// Trigger AI which generates a new `meal` and stores into [Firebase]
    await triggerAI(
      newMealId: newMealId,
      textPrompt: result?.words,
      imageFile: result?.imageFile,
      dateTime: result!.dateTime!,
    );
  }

  /// Creates a loading `meal`, processes it with AI, and persists the result in [Firebase]
  Future<void> triggerAI({
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

    /// Write `loadingMeal` to [Firebase]
    final loadingMealWritten = await firebase.writeMeal(
      newMeal: loadingMeal,
    );

    /// Return if `meal` isn't written to [Firebase]
    if (!loadingMealWritten) {
      return;
    }

    /// Trigger AI
    final result = await ai.triggerAI(
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
      return;
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
      await firebase.updateMeal(
        newMeal: meal,
      );
      return;
    }

    /// Some weird error happened, update `meal` with `error`
    await firebase.updateMeal(
      newMeal: loadingMeal.copyWith(
        errors: ['Obrok nije dekodiran'],
        imageStoragePath: result.imageStoragePath,
        isLoading: false,
      ),
    );
  }

  /// Parses the AI response into `meal` for [Firebase]
  Meal? parseAIResultToMeal({
    required String aiResult,
    required String id,
    required DateTime createdAt,
    required String? originalText,
    required String? imageStoragePath,
  }) {
    try {
      final decoded = jsonDecode(aiResult);

      if (decoded is Map<String, dynamic>) {
        return Meal.fromMap(
          decoded,
          id: id,
          createdAt: createdAt,
          originalText: originalText,
          imageStoragePath: imageStoragePath,
          isLoading: false,
          errors: null,
        );
      }

      return null;
    } catch (e) {
      return null;
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
