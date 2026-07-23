import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../models/meal/meal.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import 'home_controller.dart';
import 'widgets/home_app_bar.dart';

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
    final homeController = getIt.get<HomeController>();

    /// Currently selected day
    final activeDate = watchIt<HomeController>().value;

    /// Listens to any changes in `userMetrics` from [Firebase]
    final userMetrics = watchStream<FirebaseService, UserMetrics?>(
      (firebaseService) => firebaseService.listenToUserMetrics(),
    ).data;

    /// Listens to meals from the currently selected day
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
              userName: activeDate.toIso8601String(),
              userPhoto: 'aaa',
              currentCalories: currentCalories.round(),
              dailyCalories: userMetrics?.dailyCalories.toInt() ?? 12,
              onCalendarPressed: () => homeController.updateDateViaPicker(context),
            ),

            SliverToBoxAdapter(
              child: Container(
                height: 300,
                width: 200,
                color: Colors.green,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                width: 200,
                color: Colors.red,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                width: 200,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
