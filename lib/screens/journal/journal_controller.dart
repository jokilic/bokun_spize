import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../main.dart';
import '../../models/meal/meal.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../util/typedefs.dart';
import 'widgets/journal_calendar_sheet.dart';

class JournalController extends ValueNotifier<DateTime> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;
  final AIService ai;

  JournalController({
    required this.firebase,
    required this.ai,
  }) : super(
         DateUtils.dateOnly(
           DateTime.now(),
         ),
       );

  ///
  /// INIT
  ///

  void init() => mealsStream = firebase.listenToMeals(date: value);

  ///
  /// VARIABLES
  ///

  late Stream<List<Meal>?> mealsStream;

  ///
  /// METHODS
  ///

  /// Updates the active `date` and switches the meal listener to that day
  @override
  set value(DateTime newValue) {
    final selectedDate = DateUtils.dateOnly(newValue);

    if (DateUtils.isSameDay(super.value, selectedDate)) {
      return;
    }

    mealsStream = firebase.listenToMeals(date: selectedDate);
    super.value = selectedDate;
  }

  /// Deletes [meal] from Firebase
  Future<void> deleteMeal({required Meal meal}) async {
    final success = await firebase.deleteMeal(meal: meal);
    // TODO: Show snackbar if it fails
  }

  /// Opens [JournalCalendarSheet] and updates the selected `date`
  Future<void> updateDateViaPicker(BuildContext context) async => showModalBottomSheet(
    context: context,
    backgroundColor: BokunSpizeColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(listTileRadius),
    ),
    builder: (context) => JournalCalendarSheet(
      dateValue: value,
      onDateChanged: (newDate) => value = newDate,
    ),
  );

  /// Triggered when the user adds, edits, or copies a meal
  Future<void> onMealPressed(
    BuildContext context, {
    Meal? passedMeal,
    bool isCopyingMeal = false,
  }) async {
    /// Determine if user is editing existing `meal`
    final shouldEditExistingMeal = passedMeal != null && !isCopyingMeal;

    /// Show [MealScreen] for adding or editing `meal`
    final result = await showCupertinoSheet<MealSheetResult>(
      context: context,
      scrollableBuilder: (context, scrollController) => const Scaffold(),
    );

    /// User was editing existing `meal`
    if (shouldEditExistingMeal) {
      /// User deleted `meal`
      if (result?.deleteMeal ?? false) {
        await deleteMeal(meal: passedMeal);
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

    /// Data missing, return
    if ((!hasWords && !hasImage) || result?.dateTime == null) {
      return;
    }

    /// Meal is being copied
    /// Deleting either `meal` will remove the shared `image`
    if (isCopyingMeal && passedMeal != null) {
      await firebase.writeMeal(
        newMeal: passedMeal.copyWith(
          id: const Uuid().v1(),
          createdAt: result!.dateTime,
        ),
      );
      return;
    }

    /// Trigger AI which generates a new `meal` and stores into [Firebase]
    await triggerAI(
      textPrompt: result?.words,
      imageFile: result?.imageFile,
      dateTime: result!.dateTime!,
    );
  }

  /// Creates a loading `meal`, processes it with AI, and persists the result in [Firebase]
  Future<void> triggerAI({
    required String? textPrompt,
    required File? imageFile,
    required DateTime dateTime,
  }) async {
    /// Get `trimmedPrompt`
    final trimmedPrompt = textPrompt?.trim();

    /// Create `loadingMeal` with loading state
    final loadingMeal = Meal(
      id: const Uuid().v1(),
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
      mealId: loadingMeal.id,
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
}
