import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/weight_track.dart';
import '../../widgets/navigation_bar_widget.dart';
import 'weights_controller.dart';
import 'widgets/weights_app_bar.dart';
import 'widgets/weights_graph.dart';
import 'widgets/weights_list_tile.dart';

class WeightsScreen extends WatchingStatefulWidget {
  @override
  State<WeightsScreen> createState() => _WeightsScreenState();
}

class _WeightsScreenState extends State<WeightsScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<WeightsController>(
      () => WeightsController(
        firebase: getIt.get<FirebaseService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<WeightsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final weightsController = getIt.get<WeightsController>();

    /// User name
    final userName = firebaseService.userName;

    /// Listens to `weightTracks`
    final weightTracks =
        watchStream<WeightsController, List<WeightTrack>?>(
          (weightsController) => weightsController.weightTracksStream,
          allowStreamChange: true,
          preserveState: false,
        ).data ??
        [];

    /// Store last `weightTrack`
    final lastWeightTrack = weightTracks.firstOrNull;

    /// Number of previous calendar days used for the weight comparison
    const weightChangeCalendarDays = 7;

    /// Calculate `weightChange`
    final weightChange = getWeightChange(
      weightTracks: weightTracks,
      lastWeight: lastWeightTrack?.weight,
      calendarDays: weightChangeCalendarDays,
    );

    /// Calculate `weightChangeWithinDays`
    final weightChangeWithinDays = getWeightChangeWithinDays(
      weightTracks: weightTracks,
      calendarDays: weightChangeCalendarDays,
    );

    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(),
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          heroTag: const ValueKey('weights-fab'),
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
              weightsController.onAddWeightPressed(
                context: context,
                initialWeight: lastWeightTrack?.weight ?? 75.0,
              ),
            );
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
            WeightsAppBar(
              title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
              timeString: lastWeightTrack != null
                  ? getDateString(
                      date: lastWeightTrack.dateTime,
                      dateFormat: 'EEEE, dd.MM.yyyy.',
                    )
                  : 'Unesi težinu',
              currentWeight: lastWeightTrack?.weight,
              weightChange: weightChange,
              weightChangeWithinDays: weightChangeWithinDays,
            ),

            if (weightTracks.length >= 2 && weightChangeWithinDays != null) ...[
              ///
              /// GRAPH TITLE
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    switch (weightChangeWithinDays) {
                      0 => 'Progress today',
                      1 => 'Progress from yesterday',
                      final int days => 'Progress from $days days',
                    },
                    style: const TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.black,
                    ),
                  ),
                ),
              ),

              ///
              /// GRAPH
              ///
              WeightsGraph(
                weightTracks: weightTracks,
                weightChangeWithinDays: weightChangeWithinDays,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],

            ///
            /// WEIGHTS TITLE
            ///
            if (weightTracks.isNotEmpty) ...[
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Recent logs',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.black,
                    ),
                  ),
                ),
              ),

              ///
              /// WEIGHTS LIST
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

                  return WeightsListTile(
                    onDeletePressed: () async {
                      unawaited(
                        HapticFeedback.lightImpact(),
                      );
                      unawaited(
                        weightsController.deleteWeightTrack(
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
            /// NO WEIGHT
            ///
            if (weightTracks.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsBold.chartLine,
                        color: BokunSpizeColors.primary,
                        size: 96,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Weight journal',
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
