import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../services/firebase_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
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
    // unRegisterIfNotDisposed<WeightsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final weightsController = getIt.get<WeightsController>();

    /// User name
    final userName = firebaseService.userName;

    /// Reference to `state`
    final state = watchIt<WeightsController>().value;

    final error = state.error;
    final isLoading = state.isLoading;
    final weightTracks = state.weightTracks;
    final graphCalendarDays = state.graphCalendarDays;

    /// Store last `weightTrack`
    final lastWeightTrack = weightTracks.firstOrNull;

    /// Calculate `weightChange`
    final weightChange = getWeightChange(
      weightTracks: weightTracks,
      lastWeight: lastWeightTrack?.weight,
      calendarDays: graphCalendarDays,
    );

    /// Calculate `weightChangeWithinDays`
    final weightChangeWithinDays = getWeightChangeWithinDays(
      weightTracks: weightTracks,
      calendarDays: graphCalendarDays,
    );

    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(),
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          heroTag: const ValueKey('weights-fab'),
          elevation: 0,
          backgroundColor: BokunSpizeColors.blue,
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
                weightTrackId: const Uuid().v1(),
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

            if (weightTracks.length >= 2) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: marginHorizontal,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ///
                      /// GRAPH TITLE
                      ///
                      const Expanded(
                        child: Text(
                          'Recent progress',
                          style: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: BokunSpizeColors.black,
                          ),
                        ),
                      ),

                      ///
                      /// GRAPH BUTTON
                      ///
                      PopupMenuButton<int>(
                        menuPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        position: PopupMenuPosition.under,
                        offset: const Offset(0, 8),
                        elevation: 0,
                        color: BokunSpizeColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (calendarDays) => weightsController.updateState(
                          graphCalendarDays: calendarDays,
                        ),
                        itemBuilder: (context) => weightsController.graphCalendarDayOptions
                            .map(
                              (calendarDays) => PopupMenuItem<int>(
                                value: calendarDays,
                                child: Text(
                                  '$calendarDays days',
                                  style: const TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: BokunSpizeColors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: BokunSpizeColors.white.withValues(alpha: 0.5),
                            shape: const StadiumBorder(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 4, 16, 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const PhosphorIcon(
                                  PhosphorIconsBold.caretDown,
                                  color: BokunSpizeColors.black,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$graphCalendarDays days',
                                  style: const TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 16,
                                    height: 1.6,
                                    fontWeight: FontWeight.w600,
                                    color: BokunSpizeColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ///
              /// GRAPH
              ///
              WeightsGraph(
                weightTracks: weightTracks,
                calendarDays: graphCalendarDays,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],

            if (weightTracks.isNotEmpty) ...[
              ///
              /// WEIGHTS TITLE
              ///
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: marginHorizontal,
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
                    onDeletePressed: () {
                      HapticFeedback.lightImpact();
                      weightsController.deleteWeightTrack(
                        weightTrack: weightTrack,
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
            if (!isLoading && weightTracks.isEmpty && error == null)
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: marginHorizontal,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsBold.chartLine,
                        color: BokunSpizeColors.blue,
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
                      PhosphorIcon(
                        PhosphorIconsBold.chartLine,
                        color: BokunSpizeColors.blue,
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
                      const PhosphorIcon(
                        PhosphorIconsBold.warningOctagon,
                        color: BokunSpizeColors.blue,
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
