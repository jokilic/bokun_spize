import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/durations.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/extensions.dart';
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
  void initState() {
    super.initState();

    registerIfNotInitialized<MealsController>(
      () => MealsController(
        firebase: getIt.get<FirebaseService>(),
        aiProvider: () => getIt.get<AIService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    // unRegisterIfNotDisposed<MealsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final mealsController = getIt.get<MealsController>();

    /// Reference to `state`
    final state = watchIt<MealsController>().value;

    final activeDate = state.activeDate;
    final error = state.error;
    final isLoading = state.isLoading;
    final meals = state.meals;

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
            : SizedBox(
                height: 68,
                width: 68,
                child: GestureDetector(
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                    mealsController.onAddManualMealPressed(
                      context,
                      passedMeal: null,
                      isCopyingMeal: false,
                    );
                  },
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
                        languageCode: 'hr',
                      );
                    },
                    child: PhosphorIcon(
                      PhosphorIconsBold.plus,
                      color: context.colors.buttonText,
                      size: 32,
                    ),
                  ),
                ),
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
                      DateUtils.addDaysToDate(activeDate, -1),
                    );
                  },
                  onPressedDay: () {
                    HapticFeedback.lightImpact();
                    mealsController.updateDateViaPicker(context);
                  },
                  onPressedNextDay: () {
                    HapticFeedback.lightImpact();
                    mealsController.updateDate(
                      DateUtils.addDaysToDate(activeDate, 1),
                    );
                  },
                  onSearchPressed: () {
                    HapticFeedback.lightImpact();
                    showBlurredModalBottomSheet(
                      context: context,
                      builder: (context) => SearchScreen(),
                    );
                  },
                  shortDayString: getDateString(
                    date: activeDate,
                    dateFormat: 'dd MMM',
                  ),
                  fullDayString: getDateString(
                    date: activeDate,
                    dateFormat: 'EEEE, dd.MM.yyyy.',
                  ),
                  currentCalories: currentCalories,
                  currentProtein: currentProtein,
                  currentCarbs: currentCarbs,
                  currentFat: currentFat,
                  dailyCalories: userMetrics?.dailyCalories,
                  dailyProtein: userMetrics?.dailyProtein,
                  dailyCarbs: userMetrics?.dailyCarbs,
                  dailyFat: userMetrics?.dailyFat,
                ),

                ///
                /// SUCCESS
                ///
                if (meals.isNotEmpty)
                  MealsSuccess(
                    meals: meals,
                    onPressed: (meal) {
                      HapticFeedback.lightImpact();
                      showBlurredModalBottomSheet(
                        context: context,
                        builder: (context) => ViewMealScreen(
                          passedMeal: meal,
                          onCopyPressed: () {
                            HapticFeedback.lightImpact();
                            mealsController.onAddManualMealPressed(
                              context,
                              passedMeal: meal,
                              isCopyingMeal: true,
                            );
                          },
                          onEditPressed: () {
                            // TODO This should open another blurred modal bottom sheet, like when we long-press `MealsListTile`
                          },
                        ),
                      );
                    },
                    onLongPressed: (meal) {
                      HapticFeedback.lightImpact();
                      mealsController.onAddManualMealPressed(
                        context,
                        passedMeal: meal,
                        isCopyingMeal: false,
                      );
                    },
                    onDeletePressed: (meal) {
                      HapticFeedback.lightImpact();
                      mealsController.deleteMeal(
                        meal: meal,
                        context: context,
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
