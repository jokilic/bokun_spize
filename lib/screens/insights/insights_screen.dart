import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import '../../widgets/bokun_spize_navigation_bar.dart';
import 'insights_controller.dart';
import 'widgets/insights_app_bar.dart';

class InsightsScreen extends WatchingStatefulWidget {
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<InsightsController>(
      () => InsightsController(
        firebase: getIt.get<FirebaseService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<InsightsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final insightsController = getIt.get<InsightsController>();

    /// User name
    final userName = firebaseService.userName;

    /// Listens to `weightTracks`
    final weightTracks =
        watchStream<InsightsController, List<WeightTrack>?>(
          (insightsController) => insightsController.weightTracksStream,
          allowStreamChange: true,
          preserveState: false,
        ).data ??
        [];

    return Scaffold(
      bottomNavigationBar: BokunSpizeNavigationBar(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ///
            /// APP BAR
            ///
            InsightsAppBar(
              title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
              imagePath: 'https://thedeliciousplate.com/wp-content/uploads/2024/01/Mediterranean-tomato-and-cucumber-salad-11.jpg',
              currentWeight: 73.567,
              changeWithinLast7Days: null,
            ),

            ///
            /// WEIGHTS
            ///
            // if (meals.isNotEmpty)
            //   SliverList.builder(
            //     itemCount: meals.length,
            //     itemBuilder: (context, index) {
            //       final meal = meals[index];

            //       return JournalListTile(
            //         onDeletePressed: () async {
            //           unawaited(
            //             HapticFeedback.lightImpact(),
            //           );
            //           unawaited(
            //             journalController.deleteMeal(
            //               meal: meal,
            //             ),
            //           );
            //         },
            //         onCopyPressed: () async {
            //           unawaited(
            //             HapticFeedback.lightImpact(),
            //           );
            //           unawaited(
            //             journalController.onMealPressed(
            //               context,
            //               passedMeal: meal,
            //               isCopyingMeal: true,
            //             ),
            //           );
            //         },
            //         meal: meal,
            //       );
            //     },
            //   ),

            ///
            /// ADD WEIGHT
            ///
            // JournalAddMeal(
            //   onPressed: () => journalController.onMealPressed(context),
            // ),

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
