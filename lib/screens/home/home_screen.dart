import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import '../../models/meal/meal.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../util/day.dart';
import '../../util/dependencies.dart';
import 'home_controller.dart';
import 'widgets/home_add_meal.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_meal_list_tile/home_meal_list_tile.dart';

class HomeScreen extends WatchingStatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<HomeController>(
      () => HomeController(
        firebase: getIt.get<FirebaseService>(),
        ai: getIt.get<AIService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<HomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final homeController = getIt.get<HomeController>();

    /// User name
    final userName = firebaseService.userName;

    /// Currently selected day
    final activeDate = watchIt<HomeController>().value;

    /// Listens to any changes in `userMetrics` from [Firebase]
    final userMetrics = watchStream<FirebaseService, UserMetrics?>(
      (firebaseService) => firebaseService.listenToUserMetrics(),
    ).data;

    /// Listens to `meals` from the currently selected day
    final meals =
        watchStream<HomeController, List<Meal>?>(
          (homeController) => homeController.mealsStream,
          allowStreamChange: true,
          preserveState: false,
        ).data ??
        [];

    /// Calculates total calories for `List<Meals>`
    final currentCalories = meals.fold<double>(
      0,
      (total, meal) => total + (meal.nutrition?.calories ?? 0),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ///
            /// APP BAR
            ///
            HomeAppBar(
              title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
              imagePath: 'https://thedeliciousplate.com/wp-content/uploads/2024/01/Mediterranean-tomato-and-cucumber-salad-11.jpg',
              onCalendarPressed: () => homeController.updateDateViaPicker(context),
              dayString: getDateString(
                date: activeDate,
              ),
              currentCalories: currentCalories.round(),
              dailyCalories: userMetrics?.dailyCalories.round(),
            ),

            ///
            /// MEALS
            ///
            if (meals.isNotEmpty)
              SliverList.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];

                  return HomeMealListTile(
                    onDeletePressed: () async {
                      unawaited(
                        HapticFeedback.lightImpact(),
                      );
                      unawaited(
                        homeController.deleteMeal(
                          meal: meal,
                        ),
                      );
                    },
                    onCopyPressed: () async {
                      unawaited(
                        HapticFeedback.lightImpact(),
                      );
                      unawaited(
                        homeController.onMealPressed(
                          context,
                          passedMeal: meal,
                          isCopyingMeal: true,
                        ),
                      );
                    },
                    meal: meal,
                  );
                },
              ),

            ///
            /// ADD MEAL
            ///
            HomeAddMeal(
              onPressed: () => homeController.onMealPressed(context),
            ),

            ///
            /// BOTTOM SPACING
            ///
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
