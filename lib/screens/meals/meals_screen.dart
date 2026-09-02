import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/durations.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../widgets/navigation_bar_widget.dart';
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
    final firebaseService = getIt.get<FirebaseService>();
    final mealsController = getIt.get<MealsController>();

    /// User data from `Firebase`
    final userName = firebaseService.userName;

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

    return Animate(
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
                  backgroundColor: BokunSpizeColors.green,
                  foregroundColor: BokunSpizeColors.white,
                  splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  shape: const CircleBorder(),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    mealsController.retryMeals();
                  },
                  child: const PhosphorIcon(
                    PhosphorIconsBold.arrowClockwise,
                    color: BokunSpizeColors.white,
                    size: 32,
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: FloatingActionButton(
                      heroTag: const ValueKey('meals-calendar-fab'),
                      elevation: 0,
                      backgroundColor: BokunSpizeColors.green,
                      foregroundColor: BokunSpizeColors.white,
                      splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      shape: const CircleBorder(),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        mealsController.updateDateViaPicker(context);
                      },
                      child: const PhosphorIcon(
                        PhosphorIconsBold.calendarDot,
                        color: BokunSpizeColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 68,
                    width: 68,
                    child: FloatingActionButton(
                      heroTag: const ValueKey('meals-add-manual-meal-fab'),
                      elevation: 0,
                      backgroundColor: BokunSpizeColors.green,
                      foregroundColor: BokunSpizeColors.white,
                      splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      shape: const CircleBorder(),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // TODO: Manual meal here
                        mealsController.onAddAIMealPressed(context);
                      },
                      child: const PhosphorIcon(
                        PhosphorIconsBold.plus,
                        color: BokunSpizeColors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
        body: SafeArea(
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
                title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
                dayString: getDateString(
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
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // TODO: Open [MealScreen]
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
                    mealsController.onCopyMealPressed(
                      context,
                      passedMeal: meal,
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
    );
  }
}
