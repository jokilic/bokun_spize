import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health/health.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/durations.dart';
import '../../services/storage_service.dart';
import '../../theme/extensions.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../util/steps_with_date.dart';
import '../../widgets/navigation_bar_widget.dart';
import 'walks_controller.dart';
import 'widgets/walks_app_bar.dart';
import 'widgets/walks_empty.dart';
import 'widgets/walks_error.dart';
import 'widgets/walks_graph.dart';
import 'widgets/walks_loading.dart';
import 'widgets/walks_success.dart';

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
    ).resumeStepsRefresh();
  }

  @override
  void dispose() {
    getIt.get<WalksController>().pauseStepsRefresh();
    // unRegisterIfNotDisposed<WalksController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageService = getIt.get<StorageService>();
    final walksController = getIt.get<WalksController>();

    final state = watchIt<WalksController>().value;

    final error = state.error;
    final isLoading = state.isLoading;
    final permissionAuthorized = state.permissionAuthorized;

    final isWalking = state.isWalking;

    final graphCalendarDays = watchIt<StorageService>().value.calendarDays.walksCalendarDays;

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

    final showRefreshButton = !isLoading && (stepsWithDate.isEmpty || (error != null || permissionAuthorized == false));

    final stepsChange = getStepsChange(
      stepsWithDate: completedStepsWithDate,
      latestSteps: latestCompletedStepsWithDate?.steps,
      calendarDays: graphCalendarDays,
    );

    final stepsChangeWithinDays = getStepsChangeWithinDays(
      stepsWithDate: completedStepsWithDate,
      calendarDays: graphCalendarDays,
    );

    return ColoredBox(
      color: context.colors.scaffoldBackground,
      child: Scaffold(
        bottomNavigationBar: NavigationBarWidget(),
        floatingActionButton: showRefreshButton
            ? SizedBox(
                height: 68,
                width: 68,
                child: FloatingActionButton(
                  heroTag: const ValueKey('walks-fab'),
                  elevation: 0,
                  backgroundColor: context.colors.fat,
                  foregroundColor: context.colors.listTileBackground,
                  splashColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  shape: const CircleBorder(),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    walksController.retrySteps();
                  },
                  child: PhosphorIcon(
                    PhosphorIconsBold.arrowClockwise,
                    color: context.colors.buttonText,
                    size: 32,
                  ),
                ),
              )
            : null,
        body: Animate(
          effects: const [
            FadeEffect(
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOut,
            ),
            MoveEffect(
              begin: Offset(0, 18),
              end: Offset.zero,
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOutCubic,
            ),
            ScaleEffect(
              begin: Offset(0.985, 0.985),
              end: Offset(1, 1),
              alignment: Alignment.topCenter,
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOutCubic,
            ),
          ],
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              slivers: [
                ///
                /// APP BAR
                ///
                WalksAppBar(
                  isLoading: isLoading,
                  dayString: latestStepsWithDate != null
                      ? getDateString(
                          date: latestStepsWithDate.dateTime,
                          dateFormat: 'EEEE, dd.MM.yyyy.',
                          languageCode: context.locale.languageCode,
                        )
                      : 'walksErrorNoSteps'.tr(),
                  currentSteps: latestStepsWithDate?.steps,
                  stepsChange: stepsChange,
                  stepsChangeWithinDays: stepsChangeWithinDays,
                ),

                ///
                /// GRAPH
                ///
                if (completedStepsWithDate.length >= 2 || isLoading)
                  WalksGraph(
                    isLoading: isLoading,
                    onSelectedDays: (newWalksCalendarDays) {
                      HapticFeedback.lightImpact();
                      storageService.setWalksCalendarDays(newWalksCalendarDays);
                    },
                    dayEntries: walksController.graphCalendarDayOptions,
                    stepsWithDate: stepsWithDate,
                    calendarDays: graphCalendarDays,
                  ),

                ///
                /// SUCCESS
                ///
                if (stepsWithDate.isNotEmpty)
                  WalksSuccess(
                    stepsWithDate: stepsWithDate,
                    calendarDays: graphCalendarDays,
                    isWalking: isWalking,
                  ),

                ///
                /// EMPTY
                ///
                if (!isLoading && stepsWithDate.isEmpty && error == null) WalksEmpty(),

                ///
                /// LOADING
                ///
                if (isLoading) WalksLoading(),

                ///
                /// ERROR
                ///
                if (!isLoading && (error != null || (permissionAuthorized != null && !permissionAuthorized)))
                  WalksError(
                    error: error ?? 'walksErrorProperPermissionNotGranted'.tr(),
                    permissionAuthorized: permissionAuthorized,
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
        ),
      ),
    );
  }
}
