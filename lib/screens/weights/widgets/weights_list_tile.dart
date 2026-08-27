import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../models/weight_track/weight_track.dart';
import '../../../util/date_time.dart';
import '../../../util/format.dart';

class WeightsListTile extends StatelessWidget {
  final Future<void> Function() onDeletePressed;
  final WeightTrack weightTrack;
  final double? weightChange;

  const WeightsListTile({
    required this.onDeletePressed,
    required this.weightTrack,
    required this.weightChange,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = weightChange != null
        ? switch (weightChange!) {
            > 0 => BokunSpizeColors.red,
            < 0 => BokunSpizeColors.green,
            _ => BokunSpizeColors.black,
          }
        : BokunSpizeColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(listTileRadius),
        child: SwipeActionCell(
          key: ValueKey(weightTrack.id),
          backgroundColor: BokunSpizeColors.grey,
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
              color: BokunSpizeColors.red,
              backgroundRadius: listTileRadius,
              icon: const PhosphorIcon(
                PhosphorIconsBold.trash,
                color: BokunSpizeColors.white,
                size: 26,
              ),
            ),
          ],
          child: Material(
            color: BokunSpizeColors.white,
            borderRadius: BorderRadius.circular(listTileRadius),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(listTileRadius),
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
                      padding: const EdgeInsets.all(12),
                      color: BokunSpizeColors.grey,
                      child: const PhosphorIcon(
                        PhosphorIconsBold.personSimple,
                        color: BokunSpizeColors.blue,
                        size: 24,
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
                                  dateFormat: 'EEE, dd.MM.',
                                ),
                              ) ??
                              '--',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: BokunSpizeColors.black,
                          ),
                          maxLines: 1,
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
                          ),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: BokunSpizeColors.black.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ///
                      /// WEIGHT
                      ///
                      Text.rich(
                        TextSpan(
                          text: weightTrack.weight.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: BokunSpizeColors.black,
                          ),
                          children: [
                            const WidgetSpan(
                              child: SizedBox(width: 4),
                            ),
                            TextSpan(
                              text: 'kg',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                                letterSpacing: 1.5,
                                color: BokunSpizeColors.black.withValues(alpha: 0.7),
                              ),
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
                              '${weightChange!.abs().toStringAsFixed(1)}kg',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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
    );
  }
}
