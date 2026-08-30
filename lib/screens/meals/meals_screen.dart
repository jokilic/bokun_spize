import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../widgets/navigation_bar_widget.dart';
import 'meals_controller.dart';
import 'widgets/meals_app_bar.dart';
import 'widgets/meals_list_tile.dart';

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

    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(),
      floatingActionButton: Column(
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
              heroTag: const ValueKey('meals-fab'),
              elevation: 0,
              backgroundColor: BokunSpizeColors.green,
              foregroundColor: BokunSpizeColors.white,
              splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              shape: const CircleBorder(),
              onPressed: () {
                HapticFeedback.lightImpact();
                mealsController.onMealPressed(context);
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
            /// MEALS
            ///
            if (meals.isNotEmpty)
              SliverList.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];

                  return MealsListTile(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: Open [MealScreen]
                    },
                    onDeletePressed: () {
                      HapticFeedback.lightImpact();
                      mealsController.deleteMeal(
                        meal: meal,
                        context: context,
                      );
                    },
                    onCopyPressed: () {
                      HapticFeedback.lightImpact();
                      mealsController.onMealPressed(
                        context,
                        passedMeal: meal,
                        isCopyingMeal: true,
                      );
                    },
                    meal: meal,
                  );
                },
              ),

            ///
            /// NO MEALS
            ///
            if (!isLoading && meals.isEmpty && error == null)
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: marginHorizontal,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      PhosphorIcon(
                        PhosphorIconsBold.bowlFood,
                        color: BokunSpizeColors.green,
                        size: 96,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Meal journal',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'No logs at this time',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            ///
            /// LOADING
            ///
            if (isLoading)
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: marginHorizontal,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      PhosphorIcon(
                        PhosphorIconsBold.bowlFood,
                        color: BokunSpizeColors.green,
                        size: 96,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Meal journal',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            ///
            /// ERROR
            ///
            if (error != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: marginHorizontal,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const PhosphorIcon(
                        PhosphorIconsBold.warningOctagon,
                        color: BokunSpizeColors.green,
                        size: 96,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        error,
                        style: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
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
    );
  }
}
