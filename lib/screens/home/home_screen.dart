import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

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
      HomeController.new,
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

    /// Listens to any changes in `userMetrics` from [Firebase]
    final userMetrics = watchStream<FirebaseService, UserMetrics?>(
      (firebaseService) => firebaseService.listenToUserMetrics(),
    ).data;

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
              userName: 'bla',
              userPhoto: 'aaa',
              currentCalories: 1200,
              dailyCalories: userMetrics?.dailyCalories.toInt() ?? 12,
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
