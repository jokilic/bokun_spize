import 'dart:convert';
import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../models/meal/meal.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';

class HomeController extends ValueNotifier<DateTime> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;
  final AIService ai;

  HomeController({
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

  /// Opens the calendar and updates the selected date when confirmed
  Future<void> updateDateViaPicker(BuildContext context) async => showCalendarDatePicker2Dialog(
    context: context,
    value: [value],
    onValueChanged: (newValue) {
      final chosenDate = newValue.firstOrNull;

      if (chosenDate != null && !DateUtils.isSameDay(value, chosenDate)) {
        value = chosenDate;
        Navigator.of(context).pop();
      }
    },
    config: CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.single,
      weekdayLabelTextStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: BokunSpizeColors.neutralDark,
      ),
      controlsTextStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: BokunSpizeColors.neutralDark,
      ),
      dayTextStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: BokunSpizeColors.neutralDark,
      ),
      todayTextStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: BokunSpizeColors.neutralDark,
      ),
      selectedDayTextStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: BokunSpizeColors.neutralLight,
      ),
      selectedMonthTextStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: BokunSpizeColors.neutralLight,
      ),
      selectedYearTextStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: BokunSpizeColors.neutralLight,
      ),
      selectedDayHighlightColor: BokunSpizeColors.primary,
      daySplashColor: BokunSpizeColors.secondary,
      dayBuilder: ({required date, textStyle, decoration, isSelected, isDisabled, isToday}) {
        var currentDecoration = decoration;

        if ((isToday ?? false) && !(isSelected ?? false)) {
          currentDecoration = BoxDecoration(
            border: Border.all(
              color: BokunSpizeColors.neutralDark,
              width: 1.5,
            ),
            shape: BoxShape.circle,
          );
        }

        return Container(
          alignment: Alignment.center,
          decoration: currentDecoration,
          child: Text(
            DateFormat.d().format(date),
            style: textStyle,
          ),
        );
      },
      firstDayOfWeek: DateTime.monday,
      useAbbrLabelForMonthModePicker: true,
      cancelButton: const Text(
        'CANCEL',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: BokunSpizeColors.neutralDark,
        ),
      ),
      okButton: const Text(
        'GO',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: BokunSpizeColors.neutralDark,
        ),
      ),
      lastMonthIcon: const Icon(
        Icons.chevron_left_rounded,
        size: 20,
        color: BokunSpizeColors.neutralDark,
      ),
      nextMonthIcon: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: BokunSpizeColors.neutralDark,
      ),
    ),
    borderRadius: BorderRadius.circular(8),
    dialogBackgroundColor: BokunSpizeColors.neutralLight,
    dialogSize: const Size(325, 410),
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
    // final result = await showCupertinoSheet<MealSheetResult>(
    //   context: context,
    //   scrollableBuilder: (context, scrollController) => const Scaffold(),
    // );

    final result = (
      dateTime: DateTime.now(),
      deleteMeal: false,
      imageFile: null,
      words: 'piletina i mlinci',
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

    final hasWords = result?.words?.trim().isNotEmpty ?? false;
    final hasImage = result?.imageFile != null;

    if ((!hasWords && !hasImage) || result?.dateTime == null) {
      return;
    }

    /// A copied [Firebase] document cannot share its image path with the source,
    /// because deleting either meal would also delete the shared [Storage] file
    // TODO: Explain this and handle properly
    if (isCopyingMeal && passedMeal != null) {
      final copiedMeal = Meal(
        id: const Uuid().v1(),
        name: passedMeal.name,
        emoji: passedMeal.emoji,
        color: passedMeal.color,
        createdAt: result!.dateTime!,
        nutrition: passedMeal.nutrition,
        foods: passedMeal.foods,
        originalText: passedMeal.originalText,
        isLoading: passedMeal.isLoading,
        errors: passedMeal.errors,
      );

      await firebase.writeMeal(
        newMeal: copiedMeal,
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

    /// Generate `originalText`
    final originalText = trimmedPrompt?.isNotEmpty ?? false ? trimmedPrompt : null;

    /// Create `loadingMeal` with loading state
    final loadingMeal = Meal(
      id: const Uuid().v1(),
      createdAt: dateTime,
      originalText: originalText,
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
      textPrompt: originalText,
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
      originalText: originalText,
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
