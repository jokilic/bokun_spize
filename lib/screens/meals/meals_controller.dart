import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:uuid/uuid.dart';

import '../../models/meal/ai_meal_quota_error.dart';
import '../../models/meal/meal.dart';
import '../../services/analytics_service.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import '../../theme/extensions.dart';
import '../../util/analytics.dart';
import '../../util/crashlytics.dart';
import '../../util/date_time.dart';
import '../../util/null_state.dart';
import '../../util/parse.dart';
import '../../util/snackbars.dart';
import '../../util/typedefs.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import '../../widgets/calendar_sheet.dart';
import '../ai_add_meal/ai_add_meal_screen.dart';
import '../manual_add_meal/manual_add_meal_screen.dart';

class MealsController extends ValueNotifier<({DateTime requestedDate, DateTime? currentlyVisibleDate, List<Meal> meals, bool isLoading, String? error})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;
  final AnalyticsService analytics;
  final StorageService storage;
  String languageCode;

  MealsController({
    required this.firebase,
    required this.analytics,
    required this.storage,
    required this.languageCode,
  }) : super((
         requestedDate: DateUtils.dateOnly(
           DateTime.now(),
         ),
         currentlyVisibleDate: null,
         meals: const [],
         isLoading: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  void init() => listenToMeals(
    date: value.requestedDate,
  );

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    mealsListenerVersion++;
    await mealsSubscription?.cancel();
    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  var mealsListenerVersion = 0;

  StreamSubscription<List<Meal>>? mealsSubscription;

  ///
  /// METHODS
  ///

  /// Updates the active `date` and switches the meal listener to that day
  void updateDate(DateTime newValue) {
    final selectedDate = DateUtils.dateOnly(newValue);

    if (DateUtils.isSameDay(value.requestedDate, selectedDate)) {
      return;
    }

    listenToMeals(
      date: selectedDate,
    );
  }

  /// Keeps the displayed day visible until meals from [date] arrive
  void listenToMeals({required DateTime date}) {
    final listenerVersion = ++mealsListenerVersion;

    updateState(
      requestedDate: date,
      isLoading: true,
      error: null,
    );

    mealsSubscription?.cancel();

    mealsSubscription = firebase
        .listenToMeals(
          date: date,
          languageCode: languageCode,
        )
        .listen(
          (meals) {
            if (listenerVersion != mealsListenerVersion) {
              return;
            }

            updateState(
              currentlyVisibleDate: date,
              meals: meals,
              isLoading: false,
              error: null,
            );
          },
          onError: (error) {
            if (listenerVersion != mealsListenerVersion) {
              return;
            }

            log(
              'Listening to meals failed',
              error: error,
            );

            updateState(
              currentlyVisibleDate: null,
              meals: const [],
              isLoading: false,
              error: 'mealsCouldNotBeLoaded'.tr(),
            );
          },
        );
  }

  /// Restarts the listener after an error
  void retryMeals() => listenToMeals(
    date: value.requestedDate,
  );

  /// Restarts meal parsing when the active app language changes
  void updateLanguageCode(String newLanguageCode) {
    if (languageCode == newLanguageCode) {
      return;
    }

    languageCode = newLanguageCode;
    listenToMeals(
      date: value.requestedDate,
    );
  }

  /// Deletes `meal` from [Firebase]
  Future<bool> deleteMeal({
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
        text: 'mealDeleteFailure'.tr(),
        icon: PhosphorIconsBold.warningOctagon,
      );
    }

    return success;
  }

  /// Opens [CalendarSheet] and updates the selected `date`
  Future<void> updateDateViaPicker(BuildContext context) async {
    unawaited(
      analytics.record(
        AnalyticsEvent.mealCalendarUsed,
      ),
    );

    return showBlurredModalBottomSheet(
      context: context,
      builder: (context) => CalendarSheet(
        showConfirmButton: false,
        subtitle: 'mealsCalendarSubtitle'.tr(),
        primaryColor: context.colors.protein,
        dateValue: value.requestedDate,
        onDateChanged: (newDate) {
          HapticFeedback.lightImpact();
          updateDate(newDate);
        },
      ),
    );
  }

  /// Triggered when the user presses `FAB` to add `AI meal`
  Future<void> onAddAIMealPressed(
    BuildContext context, {
    required String languageCode,
  }) async {
    /// Generate `newMealId`
    final newMealId = const Uuid().v1();
    final aiAddMealOpenedNumber = storage.incrementAIAddMealOpenedNumber();

    unawaited(
      analytics.logAddMealOpened(
        MealAnalyticsMethod.ai,
      ),
    );

    /// Show [AIAddMealScreen] for adding `AI meal`
    final result = await showBlurredModalBottomSheet<AIMealResult>(
      context: context,
      builder: (context) => AIAddMealScreen(
        mealId: newMealId,
        shouldShowExplanation: aiAddMealOpenedNumber <= 5,
      ),
    );

    /// Sheet was dismissed, do nothing
    if (result == null) {
      return;
    }

    unawaited(
      analytics.record(
        AnalyticsEvent.mealSubmitted,
        parameters: {
          'method': MealAnalyticsMethod.ai.name,
        },
      ),
    );

    try {
      final success = await createAIMeal(
        result: result,
        newMealId: newMealId,
        languageCode: languageCode,
      );

      if (!success && context.mounted) {
        showSnackbar(
          context,
          text: 'mealAddFailure'.tr(),
          icon: PhosphorIconsBold.warningOctagon,
        );
      }
    } on AIMealQuotaError catch (error) {
      unawaited(
        analytics.logMealSaveFailed(
          MealAnalyticsMethod.ai,
          MealSaveFailure.quota,
        ),
      );

      if (!context.mounted) {
        return;
      }

      final retryAt = getDateString(
        date: error.retryAt.toLocal(),
        dateFormat: 'dd MMM, HH:mm',
        languageCode: context.locale.languageCode,
        useTodayYesterdayTomorrow: false,
      );

      showSnackbar(
        context,
        text: 'aiMealLimitReached'.tr(
          args: [retryAt],
        ),
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Saves a loading meal and submits its inputs for backend AI generation
  Future<bool> createAIMeal({
    required AIMealResult result,
    required String newMealId,
    required String languageCode,
  }) async {
    final saveTimer = Stopwatch()..start();

    /// Trigger validation and return if fail
    if (!isValidAIMealResult(result)) {
      unawaited(
        analytics.logMealSaveFailed(
          MealAnalyticsMethod.ai,
          MealSaveFailure.validation,
        ),
      );

      return false;
    }

    final words = result.words?.trim();

    /// Create `loading meal`
    final loadingMeal = Meal(
      id: newMealId,
      createdAt: result.dateTime!,
      originalText: words == null || words.isEmpty ? null : words,
      methodOfCreation: 'ai',
      isLoading: true,
    );

    try {
      /// Show the selected date before the latency-compensated Firestore write
      updateDate(
        loadingMeal.createdAt,
      );

      /// Create the list item before invoking backend generation
      final loadingMealWritten = await firebase.writeAIMealRequest(
        newMeal: loadingMeal,
        languageCode: languageCode,
      );

      if (!loadingMealWritten) {
        unawaited(
          analytics.logMealSaveFailed(
            MealAnalyticsMethod.ai,
            MealSaveFailure.persistence,
          ),
        );

        return false;
      }
    } catch (error, stackTrace) {
      reportHandledError(
        error: error,
        stackTrace: stackTrace,
        reason: 'prepare_ai_meal_save',
      );
      log(
        'Adding AI meal failed',
        error: error,
      );
      unawaited(
        analytics.logMealSaveFailed(
          MealAnalyticsMethod.ai,
          MealSaveFailure.persistence,
        ),
      );

      return false;
    }

    /// The callable uploads the image and generates the meal concurrently
    final outcome = await firebase.generateAIMeal(
      mealId: loadingMeal.id,
      languageCode: languageCode,
      imageFile: result.imageFile,
    );
    saveTimer.stop();

    if (outcome.failure case final failure?) {
      unawaited(
        analytics.logMealSaveFailed(
          MealAnalyticsMethod.ai,
          failure,
        ),
      );
      return false;
    }

    if (!outcome.pending) {
      unawaited(
        analytics.logMealSaved(
          MealAnalyticsMethod.ai,
          duration: saveTimer.elapsed,
          hasPhoto: result.imageFile != null,
          generation: outcome.metrics,
        ),
      );
    }

    return true;
  }

  /// Opens [ManualAddMealScreen] to add, copy, or edit a meal
  Future<void> onAddManualMealPressed(
    BuildContext context, {
    required Meal? passedMeal,
    required bool isCopyingMeal,
  }) async {
    final isEditingMeal = passedMeal != null && !isCopyingMeal;
    final isAddingMeal = passedMeal == null && !isCopyingMeal;
    final shouldShowExplanation = isAddingMeal && storage.incrementManualAddMealOpenedNumber() <= 5;

    /// Keep the existing `mealId` when editing
    final mealId = isEditingMeal ? passedMeal.id : const Uuid().v1();

    if (isAddingMeal) {
      unawaited(analytics.logAddMealOpened(MealAnalyticsMethod.manual));
    }

    /// Show [ManualAddMealScreen]
    final result = await showBlurredModalBottomSheet<ManualMealResult>(
      context: context,
      builder: (sheetContext) => ManualAddMealScreen(
        mealId: mealId,
        passedMeal: passedMeal,
        isCopyingMeal: isCopyingMeal,
        onDeletePressed: isEditingMeal
            ? () => deleteMeal(
                meal: passedMeal,
                context: context,
              )
            : null,
        shouldShowExplanation: shouldShowExplanation,
      ),
    );

    /// Sheet was dismissed, do nothing
    if (result == null) {
      return;
    }

    if (isAddingMeal) {
      unawaited(
        analytics.record(
          AnalyticsEvent.mealSubmitted,
          parameters: {
            'method': MealAnalyticsMethod.manual.name,
          },
        ),
      );
    }

    final saveTimer = Stopwatch()..start();

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
    saveTimer.stop();

    if (success && isAddingMeal) {
      unawaited(
        analytics.logMealSaved(
          MealAnalyticsMethod.manual,
          duration: saveTimer.elapsed,
          hasPhoto: result.imageFile != null || result.imageStoragePath != null,
        ),
      );
    } else if (success && isCopyingMeal) {
      unawaited(
        analytics.record(
          AnalyticsEvent.mealCopied,
        ),
      );
    }

    /// Saving failed, show error snackbar
    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: isEditingMeal ? 'mealUpdateFailure'.tr() : 'mealAddFailure'.tr(),
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

    /// Tracks failures in the manual creation funnel
    void recordFailure(MealSaveFailure failure) {
      if (!isCopyingMeal) {
        unawaited(
          analytics.logMealSaveFailed(
            MealAnalyticsMethod.manual,
            failure,
          ),
        );
      }
    }

    /// Return if the meal date is missing
    if (dateTime == null) {
      recordFailure(
        MealSaveFailure.validation,
      );
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
          preserveLocalizedData: true,
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
        methodOfCreation: 'manual',
        isLoading: true,
      );

      /// Write `loading meal` to [Firebase]
      final loadingMealWritten = await firebase.writeMeal(
        newMeal: loadingMeal,
      );

      if (!loadingMealWritten) {
        recordFailure(
          MealSaveFailure.persistence,
        );
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

      if (!mealUpdated) {
        recordFailure(
          MealSaveFailure.persistence,
        );
      } else if (!outcome.success) {
        recordFailure(
          MealSaveFailure.imageUpload,
        );
      }
      return mealUpdated && outcome.success;
    } catch (error, stackTrace) {
      reportHandledError(
        error: error,
        stackTrace: stackTrace,
        reason: 'save_manual_meal',
      );
      recordFailure(
        MealSaveFailure.persistence,
      );
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
    final dateTime = result.dateTime;

    if (dateTime == null) {
      return false;
    }

    try {
      final hasOnlyDateTimeChanges =
          passedMeal.localizedData != null &&
          result.name == passedMeal.name &&
          result.nutrition == passedMeal.nutrition &&
          listEquals(
            result.foods ?? const [],
            passedMeal.foods ?? const [],
          ) &&
          result.imageFile == null &&
          result.imageStoragePath == passedMeal.imageStoragePath;

      /// Update only the shared timestamp so localized `en` and `hr` data remains intact
      if (hasOnlyDateTimeChanges) {
        final mealUpdated = await firebase.updateMealDateTime(
          mealId: passedMeal.id,
          createdAt: dateTime,
        );

        if (mealUpdated) {
          unawaited(
            analytics.record(
              AnalyticsEvent.mealEdited,
            ),
          );
          updateDate(dateTime);
        }

        return mealUpdated;
      }

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
        unawaited(
          analytics.record(
            AnalyticsEvent.mealEdited,
          ),
        );
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
    } catch (error, stackTrace) {
      reportHandledError(
        error: error,
        stackTrace: stackTrace,
        reason: 'save_manual_meal_edit',
      );
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
    final imageUploadResult = imageFile != null
        ? await firebase.uploadMealImage(
            imageFile: imageFile,
          )
        : null;
    final imageStoragePath = imageFile != null ? imageUploadResult?.imageStoragePath : result.imageStoragePath;
    final imageBlurHash = imageFile != null
        ? imageUploadResult?.imageBlurHash
        : imageStoragePath == loadingMeal.imageStoragePath
        ? loadingMeal.imageBlurHash
        : null;
    final imageUploadFailed = imageFile != null && imageUploadResult == null;

    /// Finish loading and preserve the meal data even if the image upload fails
    return (
      meal: Meal(
        id: loadingMeal.id,
        createdAt: result.dateTime ?? loadingMeal.createdAt,
        emoji: loadingMeal.emoji,
        color: loadingMeal.color,
        originalText: loadingMeal.originalText,
        methodOfCreation: loadingMeal.methodOfCreation,
        name: result.name,
        nutrition: result.nutrition,
        foods: result.foods,
        localizedData: loadingMeal.getEditedLocalizedData(
          editedName: result.name,
          editedNutrition: result.nutrition,
          editedFoods: result.foods,
        ),
        imageStoragePath: imageStoragePath,
        imageBlurHash: imageBlurHash,
        isLoading: false,
        errors: imageUploadFailed ? ['mealsErrorImageUploadFailed'.tr()] : null,
      ),
      success: !imageUploadFailed,
    );
  }

  /// Updates `state`
  void updateState({
    DateTime? requestedDate,
    Object? currentlyVisibleDate = nullStateNoChange,
    List<Meal>? meals,
    bool? isLoading,
    Object? error = nullStateNoChange,
  }) => value = (
    requestedDate: requestedDate ?? value.requestedDate,
    currentlyVisibleDate: identical(currentlyVisibleDate, nullStateNoChange) ? value.currentlyVisibleDate : currentlyVisibleDate as DateTime?,
    meals: meals ?? value.meals,
    isLoading: isLoading ?? value.isLoading,
    error: identical(error, nullStateNoChange) ? value.error : error as String?,
  );
}
