import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/weight_track.dart';
import '../../widgets/bokun_spize_navigation_bar.dart';
import 'insights_controller.dart';
import 'widgets/insights_app_bar.dart';
import 'widgets/insights_graph.dart';
import 'widgets/insights_list_tile.dart';

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

    /// Store last `weightTrack`
    final lastWeightTrack = weightTracks.firstOrNull;

    /// Calculate `weightChange`
    final weightChange = getWeightChange(
      weightTracks: weightTracks,
      lastWeight: lastWeightTrack?.weight,
    );

    /// Calculate the calendar-day span covered by `weightChange`
    final weightChangeWithinDays = getWeightChangeWithinDays(
      weightTracks: weightTracks,
    );

    return Scaffold(
      bottomNavigationBar: BokunSpizeNavigationBar(),
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
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
              insightsController.onAddWeightPressed(
                context: context,
                initialWeight: lastWeightTrack?.weight ?? 75.0,
              ),
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
            InsightsAppBar(
              title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
              imagePath: 'https://thedeliciousplate.com/wp-content/uploads/2024/01/Mediterranean-tomato-and-cucumber-salad-11.jpg',
              timeString: lastWeightTrack != null
                  ? getDateString(
                      date: lastWeightTrack.dateTime,
                      dateFormat: 'EEEE, dd.MM.yyyy.',
                    )
                  : 'Dodaj masu',
              currentWeight: lastWeightTrack?.weight,
              weightChange: weightChange,
              weightChangeWithinDays: weightChangeWithinDays,
            ),

            ///
            /// GRAPH
            ///
            if (weightTracks.isNotEmpty) ...[
              ///
              /// TITLE
              ///
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Napredak u 7 dana',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.neutralDark,
                    ),
                  ),
                ),
              ),

              ///
              /// GRAPH
              ///
              InsightsGraph(
                weightTracks: weightTracks,
                // TODO: Implement day picker
                daysToShow: 7,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],

            ///
            /// WEIGHTS
            ///
            if (weightTracks.isNotEmpty) ...[
              ///
              /// TITLE
              ///
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Prošli upisi',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.neutralDark,
                    ),
                  ),
                ),
              ),

              ///
              /// LIST
              ///
              SliverList.builder(
                itemCount: weightTracks.length,
                itemBuilder: (context, index) {
                  final weightTrack = weightTracks[index];

                  final previousWeightChange = getPreviousWeightChange(
                    weightTracks: weightTracks,
                    weightTrack: weightTrack,
                    index: index,
                  );

                  return InsightsListTile(
                    onDeletePressed: () async {
                      unawaited(
                        HapticFeedback.lightImpact(),
                      );
                      unawaited(
                        insightsController.deleteWeightTrack(
                          weightTrack: weightTrack,
                        ),
                      );
                    },
                    weightTrack: weightTrack,
                    weightChange: previousWeightChange,
                  );
                },
              ),
            ],

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
