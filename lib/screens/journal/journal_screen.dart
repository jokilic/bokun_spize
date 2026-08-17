import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../models/meal/meal.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../widgets/navigation_bar_widget.dart';
import 'journal_controller.dart';
import 'widgets/journal_app_bar.dart';
import 'widgets/journal_list_tile/journal_list_tile.dart';

class JournalScreen extends WatchingStatefulWidget {
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<JournalController>(
      () => JournalController(
        firebase: getIt.get<FirebaseService>(),
        ai: getIt.get<AIService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<JournalController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final journalController = getIt.get<JournalController>();

    /// User name
    final userName = firebaseService.userName;

    /// Currently selected day
    final activeDate = watchIt<JournalController>().value;

    /// Listens to any changes in `userMetrics` from [Firebase]
    final userMetrics = watchStream<FirebaseService, UserMetrics?>(
      (firebaseService) => firebaseService.listenToUserMetrics(),
    ).data;

    /// Listens to `meals` from the currently selected day
    final meals =
        watchStream<JournalController, List<Meal>?>(
          (journalController) => journalController.mealsStream,
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
      bottomNavigationBar: NavigationBarWidget(),
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          heroTag: const ValueKey('insights-fab'),
          elevation: 0,
          backgroundColor: BokunSpizeColors.primary,
          foregroundColor: BokunSpizeColors.white,
          splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          shape: const CircleBorder(),
          onPressed: () {
            unawaited(
              HapticFeedback.lightImpact(),
            );
            unawaited(
              journalController.onMealPressed(context),
            );
          },
          child: const Icon(
            Icons.add_rounded,
            size: 40,
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
            JournalAppBar(
              title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
              imagePath: 'https://thedeliciousplate.com/wp-content/uploads/2024/01/Mediterranean-tomato-and-cucumber-salad-11.jpg',
              onCalendarPressed: () => journalController.updateDateViaPicker(context),
              dayString: getDateString(
                date: activeDate,
                dateFormat: 'EEEE, dd.MM.yyyy.',
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

                  return JournalListTile(
                    onDeletePressed: () async {
                      unawaited(
                        HapticFeedback.lightImpact(),
                      );
                      unawaited(
                        journalController.deleteMeal(
                          meal: meal,
                        ),
                      );
                    },
                    onCopyPressed: () async {
                      unawaited(
                        HapticFeedback.lightImpact(),
                      );
                      unawaited(
                        journalController.onMealPressed(
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
            /// NO MEALS
            ///
            if (meals.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsBold.notebook,
                        color: BokunSpizeColors.primary,
                        size: 96,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Dnevnik obroka',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.neutralDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Trenutno nema upisa',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.neutralDark,
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
                height: MediaQuery.paddingOf(context).bottom + 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
