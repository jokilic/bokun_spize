import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../services/firebase_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../util/steps_with_date.dart';
import '../../widgets/navigation_bar_widget.dart';
import 'walks_controller.dart';
import 'widgets/walks_app_bar.dart';
import 'widgets/walks_graph.dart';
import 'widgets/walks_list_tile.dart';

class WalksScreen extends WatchingStatefulWidget {
  @override
  State<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends State<WalksScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<WalksController>(
      () => WalksController(
        health: Health(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    // unRegisterIfNotDisposed<WalksController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final walksController = getIt.get<WalksController>();

    /// User name
    final userName = firebaseService.userName;

    /// Reference to `state`
    final state = watchIt<WalksController>().value;

    final error = state.error;
    final isLoading = state.isLoading;
    final permissionAuthorized = state.permissionAuthorized;
    final graphCalendarDays = state.graphCalendarDays;

    final stepsWithDate = [...?state.stepsWithDate]
      ..sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      );
    final latestStepsWithDate = stepsWithDate.firstOrNull;

    final currentDateTime = DateTime.now();
    final completedStepsWithDate = stepsWithDate
        .where(
          (stepWithDate) => !DateUtils.isSameDay(
            stepWithDate.dateTime,
            currentDateTime,
          ),
        )
        .toList();
    final latestCompletedStepsWithDate = completedStepsWithDate.firstOrNull;

    final showRefreshButton = !isLoading && stepsWithDate.isEmpty && (error != null || permissionAuthorized == false);

    final stepsChange = getStepsChange(
      stepsWithDate: completedStepsWithDate,
      latestSteps: latestCompletedStepsWithDate?.steps,
      calendarDays: graphCalendarDays,
    );

    final stepsChangeWithinDays = getStepsChangeWithinDays(
      stepsWithDate: completedStepsWithDate,
      calendarDays: graphCalendarDays,
    );

    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(),
      floatingActionButton: showRefreshButton
          ? SizedBox(
              height: 68,
              width: 68,
              child: FloatingActionButton(
                heroTag: const ValueKey('walks-fab'),
                elevation: 0,
                backgroundColor: BokunSpizeColors.yellow,
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
                    walksController.refreshSteps(),
                  );
                },
                child: const PhosphorIcon(
                  PhosphorIconsBold.arrowClockwise,
                  color: BokunSpizeColors.white,
                  size: 32,
                ),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ///
            /// APP BAR
            ///
            WalksAppBar(
              title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
              timeString: latestStepsWithDate != null
                  ? getDateString(
                      date: latestStepsWithDate.dateTime,
                      dateFormat: 'EEEE, dd.MM.yyyy.',
                    )
                  : 'Vrijeme ne postoji',
              currentSteps: latestStepsWithDate?.steps,
              stepsChange: stepsChange,
              stepsChangeWithinDays: stepsChangeWithinDays,
            ),

            if (completedStepsWithDate.length >= 2) ...[
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
                        onSelected: (calendarDays) => walksController.updateState(
                          graphCalendarDays: calendarDays,
                        ),
                        itemBuilder: (context) => walksController.graphCalendarDayOptions
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
              WalksGraph(
                stepsWithDate: completedStepsWithDate,
                calendarDays: graphCalendarDays,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],

            if (stepsWithDate.isNotEmpty) ...[
              ///
              /// STEPS TITLE
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
              /// STEPS LIST
              ///
              SliverList.builder(
                itemCount: stepsWithDate.length,
                itemBuilder: (context, index) {
                  final stepWithDate = stepsWithDate[index];
                  final previousStepsWithDate = index + 1 < stepsWithDate.length ? stepsWithDate[index + 1] : null;

                  return WalksListTile(
                    stepWithDate: stepWithDate,
                    previousStepsWithDate: previousStepsWithDate,
                  );
                },
              ),
            ],

            ///
            /// NO STEPS
            ///
            if (!isLoading && stepsWithDate.isEmpty && error == null)
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: marginHorizontal,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsBold.personSimpleWalk,
                        color: BokunSpizeColors.yellow,
                        size: 96,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Walking journal',
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
                        'No step data at this time',
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
                        PhosphorIconsBold.personSimpleWalk,
                        color: BokunSpizeColors.yellow,
                        size: 96,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Walking journal',
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
            if (error != null || (permissionAuthorized != null && !permissionAuthorized))
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
                        color: BokunSpizeColors.yellow,
                        size: 96,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (permissionAuthorized != null && !permissionAuthorized) ? 'Permission error' : 'Error',
                        style: const TextStyle(
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
                        error ?? 'Proper permission was not granted',
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
