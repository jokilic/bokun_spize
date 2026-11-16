import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../models/weight_track/weight_track.dart';
import '../../../theme/extensions.dart';
import '../../../util/date_time.dart';
import '../../../util/format.dart';

class WeightsListTile extends StatelessWidget {
  final Function() onPressed;
  final Function() onDeletePressed;
  final WeightTrack weightTrack;
  final double? weightChange;
  final int index;

  const WeightsListTile({
    required this.onPressed,
    required this.onDeletePressed,
    required this.weightTrack,
    required this.weightChange,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = weightChange != null
        ? switch (weightChange!) {
            < 0 => context.colors.protein,
            > 0 => context.colors.delete,
            _ => context.colors.text,
          }
        : context.colors.text;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(listTileRadius),
        child: SwipeActionCell(
          index: index,
          key: ValueKey(weightTrack.id),
          backgroundColor: context.colors.scaffoldBackground,
          openAnimationDuration: 175,
          closeAnimationDuration: 175,
          deleteAnimationDuration: 175,
          openAnimationCurve: Curves.easeIn,
          closeAnimationCurve: Curves.easeIn,
          leadingActions: [
            SwipeAction(
              onTap: (handler) async {
                await handler(true);
                await onDeletePressed();
              },
              color: context.colors.delete,
              backgroundRadius: listTileRadius,
              icon: PhosphorIcon(
                PhosphorIconsBold.trash,
                color: context.colors.buttonText,
                size: 26,
              ),
            ),
          ],
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(listTileRadius),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(listTileRadius),
              highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(listTileRadius),
                  color: context.colors.listTileBackground.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ///
                    /// ICON
                    ///
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.all(listTileIconRadius / 4),
                        color: context.colors.carbs,
                        child: PhosphorIcon(
                          PhosphorIconsBold.personSimple,
                          color: context.colors.buttonText,
                          size: listTileIconRadius / 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    ///
                    /// TEXT
                    ///
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///
                          /// TITLE
                          ///
                          Text(
                            capitalizeFirstLetter(
                                  getDateString(
                                    date: weightTrack.dateTime,
                                    dateFormat: 'EEE, dd MMM',
                                    languageCode: context.locale.languageCode,
                                    includeYearIfNotCurrentYear: true,
                                  ),
                                ) ??
                                '--',
                            style: context.textStyles.listTileTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          ///
                          /// SUBTITLE
                          ///
                          Text(
                            getDateString(
                              date: weightTrack.dateTime,
                              dateFormat: 'HH:mm',
                              useTodayYesterdayTomorrow: false,
                              languageCode: context.locale.languageCode,
                            ),
                            style: context.textStyles.listTileSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    ///
                    /// WEIGHT & CHANGE
                    ///
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ///
                        /// WEIGHT
                        ///
                        Text.rich(
                          TextSpan(
                            text: weightTrack.weight.toStringAsFixed(1),
                            style: context.textStyles.listTilePrimaryValue,
                            children: [
                              const WidgetSpan(
                                child: SizedBox(width: 4),
                              ),
                              TextSpan(
                                text: 'kilogram'.tr(),
                                style: context.textStyles.listTilePrimaryValueUnit,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        ///
                        /// CHANGE
                        ///
                        if (weightChange != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PhosphorIcon(
                                switch (weightChange!) {
                                  > 0 => PhosphorIconsBold.arrowUp,
                                  < 0 => PhosphorIconsBold.arrowDown,
                                  _ => PhosphorIconsBold.minus,
                                },
                                color: changeColor,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${weightChange!.abs().toStringAsFixed(1)}${'kilogram'.tr()}',
                                style: context.textStyles.listTileStatus.copyWith(
                                  color: changeColor,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
