import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../models/notification/daily_summary.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/date_time.dart';
import '../../../../util/spacing.dart';
import '../../../../widgets/text_field_widget.dart';

class ViewNotificationHistorySheet extends StatelessWidget {
  final DailySummary dailySummary;
  final Function() onDeletePressed;

  const ViewNotificationHistorySheet({
    required this.dailySummary,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final titleDate = getDateString(
      date: dailySummary.dayBeingSummarized,
      dateFormat: 'dd MMM',
      languageCode: context.locale.languageCode,
      includeYearIfNotCurrentYear: true,
      lowercaseTodayYesterdayTomorrow: true,
    );
    final date = getDateString(
      date: dailySummary.dayBeingSummarized,
      dateFormat: 'dd MMM',
      languageCode: context.locale.languageCode,
      includeYearIfNotCurrentYear: true,
    );
    final time = getDateString(
      date: dailySummary.summaryAt,
      dateFormat: 'HH:mm',
      useTodayYesterdayTomorrow: false,
      languageCode: context.locale.languageCode,
    );

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
            /// TITLE & ACTIONS
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
                      /// DELETE BUTTON
                      ///
                      IconButton(
                        onPressed: () {
                          onDeletePressed();
                          Navigator.of(context).pop();
                        },
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.trash,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: context.colors.delete,
                          foregroundColor: context.colors.buttonText,
                        ),
                      ),

                      ///
                      /// TITLE
                      ///
                      Expanded(
                        child: Text(
                          'notificationHistoryListTileTitle'.tr(
                            args: [titleDate],
                          ),
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
            /// DATE & TIME
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
                  child: Text.rich(
                    TextSpan(
                      text: date,
                      children: [
                        WidgetSpan(
                          child: PhosphorIcon(
                            PhosphorIconsBold.dotOutline,
                            size: 16,
                            color: context.colors.text,
                          ),
                        ),
                        TextSpan(
                          text: time,
                        ),
                      ],
                    ),
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
            /// SUMMARY
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: marginHorizontal,
                vertical: 8,
              ),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 3,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 18),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                    ScaleEffect(
                      begin: Offset(0.98, 0.98),
                      end: Offset(1, 1),
                      alignment: Alignment.topCenter,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: TextFieldWidget(
                    readOnly: true,
                    minLines: 5,
                    maxLines: 8,
                    controller: TextEditingController(
                      text: dailySummary.notificationForLanguage(
                        context.locale.languageCode,
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    title: 'notificationsDailySummaryTitle'.tr(),
                    textColor: context.colors.text,
                  ),
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
