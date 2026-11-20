import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../models/notification/daily_summary.dart';
import '../../../../services/firebase_service.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/date_time.dart';
import '../../../../util/dependencies.dart';
import '../../../../util/snackbars.dart';
import '../../../../util/spacing.dart';
import '../../../../widgets/blurred_modal_bottom_sheet.dart';
import 'notification_history_empty.dart';
import 'notification_history_list_tile.dart';
import 'view_notification_history_sheet.dart';

class NotificationHistorySheet extends WatchingStatefulWidget {
  @override
  State<NotificationHistorySheet> createState() => NotificationHistorySheetState();
}

class NotificationHistorySheetState extends State<NotificationHistorySheet> {
  /// Deletes [dailySummary] from Firebase
  Future<void> deleteDailySummary(
    BuildContext context, {
    required DailySummary dailySummary,
  }) async {
    final success = await getIt.get<FirebaseService>().deleteDailySummary(
      dailySummary: dailySummary,
    );

    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: 'dailySummaryDeleteFailure'.tr(),
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Opens [ViewNotificationHistorySheet]
  Future<void> openViewNotificationHistorySheet(
    BuildContext context, {
    required DailySummary dailySummary,
  }) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => ViewNotificationHistorySheet(
      dailySummary: dailySummary,
      onDeletePressed: () {
        HapticFeedback.lightImpact();
        deleteDailySummary(
          context,
          dailySummary: dailySummary,
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    /// Listens to any changes in the current user's `dailySummaries` from [Firebase]
    final dailySummaries =
        watchStream<FirebaseService, List<DailySummary>>(
          (firebaseService) => firebaseService.listenToDailySummaries(),
          initialValue: const <DailySummary>[],
        ).data ??
        const <DailySummary>[];

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: ColoredBox(
        color: context.colors.scaffoldBackground,
        child: CustomScrollView(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            ///
            /// TITLE & CLOSE BUTTON
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 10),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ///
                      /// PLACEHOLDER BUTTON
                      ///
                      Opacity(
                        opacity: 0,
                        child: IgnorePointer(
                          child: IconButton(
                            onPressed: null,
                            icon: const PhosphorIcon(
                              PhosphorIconsBold.x,
                              size: 22,
                            ),
                            style: IconButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                              foregroundColor: context.colors.text,
                            ),
                          ),
                        ),
                      ),

                      ///
                      /// TITLE
                      ///
                      Expanded(
                        child: Text(
                          'notificationHistoryTitle'.tr(),
                          style: context.textStyles.sheetTitle,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      ///
                      /// CLOSE BUTTON
                      ///
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.x,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                          foregroundColor: context.colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ///
            /// SUBTITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 2,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 8),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Text(
                    'notificationHistorySheetSubtitle'.tr(),
                    style: context.textStyles.sheetSubtitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),

            ///
            /// DAILY SUMMARIES
            ///
            if (dailySummaries.isNotEmpty)
              SliverList.builder(
                itemCount: dailySummaries.length,
                findChildIndexCallback: (key) {
                  final index = dailySummaries.indexWhere(
                    (dailySummary) => ValueKey(dailySummary.id) == key,
                  );
                  return index == -1 ? null : index;
                },
                itemBuilder: (context, index) {
                  final dailySummary = dailySummaries[index];

                  final listTileKey = ValueKey(dailySummary.id);
                  final listTile = NotificationHistoryListTile(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      openViewNotificationHistorySheet(
                        context,
                        dailySummary: dailySummary,
                      );
                    },
                    color: context.colors.protein,
                    icon: PhosphorIconsBold.chartLine,
                    title: dailySummary.notificationForLanguage(
                      context.locale.languageCode,
                    ),
                    titleDate: getDateString(
                      date: dailySummary.dayBeingSummarized,
                      dateFormat: 'dd MMM',
                      languageCode: context.locale.languageCode,
                      includeYearIfNotCurrentYear: true,
                      lowercaseTodayYesterdayTomorrow: true,
                    ),
                    date: getDateString(
                      date: dailySummary.dayBeingSummarized,
                      dateFormat: 'dd MMM',
                      languageCode: context.locale.languageCode,
                      includeYearIfNotCurrentYear: true,
                    ),
                    time: getDateString(
                      date: dailySummary.summaryAt,
                      dateFormat: 'HH:mm',
                      useTodayYesterdayTomorrow: false,
                      languageCode: context.locale.languageCode,
                      lowercaseTodayYesterdayTomorrow: true,
                    ),
                  );

                  if (index >= 6) {
                    return KeyedSubtree(
                      key: listTileKey,
                      child: listTile,
                    );
                  }

                  return Animate(
                    key: listTileKey,
                    delay: BokunSpizeDurations.stateTransitionStagger * (3 + index),
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
                        begin: Offset(0.98, 0.98),
                        end: Offset(1, 1),
                        alignment: Alignment.topCenter,
                        duration: BokunSpizeDurations.stateTransition,
                        curve: Curves.easeOutCubic,
                      ),
                    ],
                    child: listTile,
                  );
                },
              ),

            ///
            /// EMPTY
            ///
            if (dailySummaries.isEmpty) NotificationHistoryEmpty(),

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
