import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import 'meal_controller.dart';

class MealScreen extends WatchingStatefulWidget {
  final String mealId;

  const MealScreen({
    required this.mealId,
  });

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<MealController>(
      () => MealController(),
      instanceName: widget.mealId,
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<MealController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final mealController = getIt.get<MealController>();

    /// User data from `Firebase`
    final userName = firebaseService.userName;

    /// Reference to `state`
    final state = watchIt<MealController>().value;

    // final activeDate = state.activeDate;
    // final error = state.error;
    // final isLoading = state.isLoading;
    // final meals = state.meals;

    return Scaffold(
      floatingActionButton: SizedBox(
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
            // mealsController.onMealPressed(context);
          },
          child: const PhosphorIcon(
            PhosphorIconsBold.plus,
            color: BokunSpizeColors.white,
            size: 32,
          ),
        ),
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
            // MealsAppBar(
            //   title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
            //   dayString: getDateString(
            //     date: activeDate,
            //     dateFormat: 'EEEE, dd.MM.yyyy.',
            //   ),
            //   currentCalories: currentCalories.round(),
            //   dailyCalories: userMetrics?.dailyCalories.round(),
            // ),

            ///
            /// BOTTOM SPACING
            ///
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom + 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
