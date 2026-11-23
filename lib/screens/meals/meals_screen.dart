import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/durations.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/analytics_service.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import '../../theme/extensions.dart';
import '../../util/analytics.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import '../../widgets/navigation_bar_widget.dart';
import '../search/search_screen.dart';
import '../view_meal/view_meal_screen.dart';
import 'meals_controller.dart';
import 'widgets/meals_app_bar.dart';
import 'widgets/meals_empty.dart';
import 'widgets/meals_error.dart';
import 'widgets/meals_loading.dart';
import 'widgets/meals_success.dart';

class MealsScreen extends WatchingStatefulWidget {
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageCode = context.locale.languageCode;

    registerIfNotInitialized<MealsController>(
      () => MealsController(
        firebase: getIt.get<FirebaseService>(),
        analytics: getIt.get<AnalyticsService>(),
        storage: getIt.get<StorageService>(),
        languageCode: languageCode,
      ),
      afterRegister: (controller) => controller.init(),
    ).updateLanguageCode(languageCode);
  }

  @override
  void dispose() {
    // unRegisterIfNotDisposed<MealsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealsController = getIt.get<MealsController>();

    final state = watchIt<MealsController>().value;

    final requestedDate = state.requestedDate;
    final currentlyVisibleDate = state.currentlyVisibleDate ?? requestedDate;
    final error = state.error;
    final isLoading = state.isLoading && state.currentlyVisibleDate == null;
    final meals = state.meals;

    /// Localized `date` values
    final shortDayString = getDateString(
      date: currentlyVisibleDate,
      dateFormat: 'dd MMM',
      languageCode: context.locale.languageCode,
      includeYearIfNotCurrentYear: true,
    );

    final fullDayString = getDateString(
      date: currentlyVisibleDate,
      dateFormat: 'EEEE, dd MMM',
      languageCode: context.locale.languageCode,
      includeYearIfNotCurrentYear: true,
    );

    /// Listens to any changes in `userMetrics` from [Firebase]
    final userMetrics = watchStream<FirebaseService, UserMetrics?>(
      (firebaseService) => firebaseService.listenToUserMetrics(),
    ).data;

    /// Calculates total values for `List<Meals>`
    final currentCalories = meals.fold<double>(
      0,
      (total, meal) => total + (meal.nutrition?.calories ?? 0),
    );
    final currentProtein = meals.fold<double>(
      0,
      (total, meal) => total + (meal.nutrition?.protein ?? 0),
    );
    final currentCarbs = meals.fold<double>(
      0,
      (total, meal) => total + (meal.nutrition?.carbs ?? 0),
    );
    final currentFat = meals.fold<double>(
      0,
      (total, meal) => total + (meal.nutrition?.fat ?? 0),
    );

    return ColoredBox(
      color: context.colors.scaffoldBackground,
      child: Scaffold(
        bottomNavigationBar: NavigationBarWidget(),
        floatingActionButton: isLoading
            ? null
            : error != null
            ? SizedBox(
                height: 68,
                width: 68,
                child: FloatingActionButton(
                  heroTag: const ValueKey('meals-retry-fab'),
                  elevation: 0,
                  backgroundColor: context.colors.protein,
                  foregroundColor: context.colors.listTileBackground,
                  splashColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  shape: const CircleBorder(),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    mealsController.retryMeals();
                  },
                  child: PhosphorIcon(
                    PhosphorIconsBold.arrowClockwise,
                    color: context.colors.buttonText,
                    size: 32,
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ///
                  /// ADD MANUAL MEAL
                  ///
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      heroTag: const ValueKey('meals-add-meal-fab'),
                      elevation: 0,
                      backgroundColor: context.colors.protein,
                      foregroundColor: context.colors.listTileBackground,
                      splashColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      shape: const CircleBorder(),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        mealsController.onAddManualMealPressed(
                          context,
                          passedMeal: null,
                          isCopyingMeal: false,
                        );
                      },
                      child: PhosphorIcon(
                        PhosphorIconsBold.pencilSimple,
                        color: context.colors.buttonText,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ///
                  /// ADD AI MEAL
                  ///
                  SizedBox(
                    height: 68,
                    width: 68,
                    child: FloatingActionButton(
                      heroTag: const ValueKey('meals-add-meal-fab'),
                      elevation: 0,
                      backgroundColor: context.colors.protein,
                      foregroundColor: context.colors.listTileBackground,
                      splashColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      shape: const CircleBorder(),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        mealsController.onAddAIMealPressed(
                          context,
                          languageCode: context.locale.languageCode,
                        );
                      },
                      child: PhosphorIcon(
                        PhosphorIconsBold.sparkle,
                        color: context.colors.buttonText,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
        body: Animate(
          effects: const [
            FadeEffect(
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOut,
            ),
            MoveEffect(
              begin: Offset(0, 18),
              end: Offset.zero,
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOutCubic,
            ),
            ScaleEffect(
              begin: Offset(0.985, 0.985),
              end: Offset(1, 1),
              alignment: Alignment.topCenter,
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOutCubic,
            ),
          ],
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              slivers: [
                ///
                /// APP BAR
                ///
                MealsAppBar(
                  isLoading: isLoading,
                  onPressedPreviousDay: () {
                    HapticFeedback.lightImpact();
                    mealsController.updateDate(
                      DateUtils.addDaysToDate(
                        requestedDate,
                        -1,
                      ),
                    );
                  },
                  onPressedDay: () {
                    HapticFeedback.lightImpact();
                    mealsController.updateDateViaPicker(context);
                  },
                  onPressedNextDay: () {
                    HapticFeedback.lightImpact();
                    mealsController.updateDate(
                      DateUtils.addDaysToDate(
                        requestedDate,
                        1,
                      ),
                    );
                  },
                  onSearchPressed: () {
                    unawaited(
                      mealsController.analytics.record(
                        AnalyticsEvent.mealSearchOpened,
                      ),
                    );

                    HapticFeedback.lightImpact();
                    showBlurredModalBottomSheet(
                      context: context,
                      builder: (sheetContext) => SearchScreen(
                        languageCode: context.locale.languageCode,
                        onMealPressed: ({required meal, required onDeleted}) {
                          unawaited(
                            mealsController.analytics.record(
                              AnalyticsEvent.mealSearchResultOpened,
                            ),
                          );

                          unawaited(
                            mealsController.analytics.record(
                              AnalyticsEvent.mealDetailsOpened,
                              parameters: {
                                'source': 'search',
                              },
                            ),
                          );

                          HapticFeedback.lightImpact();
                          showBlurredModalBottomSheet(
                            context: context,
                            builder: (viewMealContext) => ViewMealScreen(
                              passedMeal: meal,
                              onDeletePressed: () async {
                                unawaited(
                                  HapticFeedback.lightImpact(),
                                );

                                final success = await mealsController.deleteMeal(
                                  meal: meal,
                                  context: context,
                                );

                                if (success) {
                                  onDeleted();
                                }
                              },
                              onEditPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(sheetContext).pop();
                                mealsController.onAddManualMealPressed(
                                  context,
                                  passedMeal: meal,
                                  isCopyingMeal: false,
                                );
                              },
                              onCopyPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(sheetContext).pop();
                                mealsController.onAddManualMealPressed(
                                  context,
                                  passedMeal: meal,
                                  isCopyingMeal: true,
                                );
                              },
                            ),
                          );
                        },
                        onDeletePressed: (meal) {
                          HapticFeedback.lightImpact();
                          return mealsController.deleteMeal(
                            meal: meal,
                            context: context,
                          );
                        },
                        onEditPressed: (meal) {
                          HapticFeedback.lightImpact();
                          mealsController.onAddManualMealPressed(
                            context,
                            passedMeal: meal,
                            isCopyingMeal: false,
                          );
                        },
                        onCopyPressed: (meal) {
                          HapticFeedback.lightImpact();
                          mealsController.onAddManualMealPressed(
                            context,
                            passedMeal: meal,
                            isCopyingMeal: true,
                          );
                        },
                      ),
                    );
                  },
                  shortDayString: shortDayString,
                  fullDayString: fullDayString,
                  currentCalories: currentCalories,
                  currentProtein: currentProtein,
                  currentCarbs: currentCarbs,
                  currentFat: currentFat,
                  dailyCalories: userMetrics?.dailyCalories,
                  dailyProtein: userMetrics?.dailyProtein,
                  dailyCarbs: userMetrics?.dailyCarbs,
                  dailyFat: userMetrics?.dailyFat,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 8),
                ),

                ///
                /// SUCCESS
                ///
                if (meals.isNotEmpty)
                  MealsSuccess(
                    meals: meals,
                    onPressed: (meal) {
                      unawaited(
                        mealsController.analytics.record(
                          AnalyticsEvent.mealDetailsOpened,
                          parameters: {
                            'source': 'history',
                          },
                        ),
                      );

                      HapticFeedback.lightImpact();
                      showBlurredModalBottomSheet(
                        context: context,
                        builder: (context) => ViewMealScreen(
                          passedMeal: meal,
                          onDeletePressed: () {
                            HapticFeedback.lightImpact();
                            mealsController.deleteMeal(
                              meal: meal,
                              context: context,
                            );
                          },
                          onEditPressed: () {
                            HapticFeedback.lightImpact();
                            mealsController.onAddManualMealPressed(
                              context,
                              passedMeal: meal,
                              isCopyingMeal: false,
                            );
                          },
                          onCopyPressed: () {
                            HapticFeedback.lightImpact();
                            mealsController.onAddManualMealPressed(
                              context,
                              passedMeal: meal,
                              isCopyingMeal: true,
                            );
                          },
                        ),
                      );
                    },
                    onDeletePressed: (meal) {
                      HapticFeedback.lightImpact();
                      mealsController.deleteMeal(
                        meal: meal,
                        context: context,
                      );
                    },
                    onEditPressed: (meal) {
                      HapticFeedback.lightImpact();
                      mealsController.onAddManualMealPressed(
                        context,
                        passedMeal: meal,
                        isCopyingMeal: false,
                      );
                    },
                    onCopyPressed: (meal) {
                      HapticFeedback.lightImpact();
                      mealsController.onAddManualMealPressed(
                        context,
                        passedMeal: meal,
                        isCopyingMeal: true,
                      );
                    },
                  ),

                ///
                /// EMPTY
                ///
                if (!isLoading && meals.isEmpty && error == null) MealsEmpty(),

                ///
                /// LOADING
                ///
                if (isLoading) MealsLoading(),

                ///
                /// ERROR
                ///
                if (!isLoading && error != null)
                  MealsError(
                    error: error,
                  ),

                ///
                /// BOTTOM SPACING
                ///
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: getBottomSpacing(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
