import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:watch_it/watch_it.dart';

import '../../models/meal/food.dart';
import '../../models/meal/meal.dart';
import '../../models/meal/nutrition.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/firebase_service.dart';
import '../../util/day.dart';
import '../../util/dependencies.dart';
import 'home_controller.dart';
import 'widgets/home_add_meal.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_meal_list_tile.dart';

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
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ///
            /// APP BAR
            ///
            HomeAppBar(
              userName: userName ?? 'Đurđa',
              userPhoto: 'https://upload.wikimedia.org/wikipedia/commons/2/21/Danny_DeVito_by_Gage_Skidmore.jpg',
              onCalendarPressed: () => homeController.updateDateViaPicker(context),
              dayString: getDateString(
                date: activeDate,
              ),
              currentCalories: currentCalories.round(),
              dailyCalories: userMetrics?.dailyCalories.toInt(),
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
                    meal: meal,
                  );
                },
              ),

            ///
            /// ADD MEAL
            ///
            HomeAddMeal(
              onPressed: () {
                final newMeal = Meal(
                  id: const Uuid().v1(),
                  createdAt: DateTime.now(),
                  isLoading: false,
                  name: 'hello there',
                  foods: [
                    Food(
                      name: 'banana',
                      quantity: 3,
                      unit: 'kg ',
                      nutrition: Nutrition(
                        calories: 100,
                        protein: 20,
                        carbs: 10,
                        fat: 5,
                      ),
                    ),
                  ],
                  color: Colors.yellow,
                  emoji: '🍌',
                  nutrition: Nutrition(
                    calories: 400,
                    protein: 100,
                    carbs: 50,
                    fat: 10,
                  ),
                  originalText: 'Hello there some text',
                );

                getIt.get<FirebaseService>().writeMeal(
                  newMeal: newMeal,
                );
              },
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
