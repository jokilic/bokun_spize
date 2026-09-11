import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../models/steps_with_date/steps_with_date.dart';
import '../../../theme/extensions.dart';
import '../../../util/date_time.dart';
import '../../../util/format.dart';

class WalksListTile extends StatelessWidget {
  final Function() onPressed;
  final StepsWithDate stepWithDate;
  final StepsWithDate? previousStepsWithDate;

  const WalksListTile({
    required this.onPressed,
    required this.stepWithDate,
    required this.previousStepsWithDate,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(
      stepWithDate.dateTime,
      DateTime.now(),
    );
    final stepsChange = previousStepsWithDate != null ? stepWithDate.steps - previousStepsWithDate!.steps : null;

    final changeColor = stepsChange != null
        ? switch (stepsChange) {
            > 0 => context.colors.protein,
            < 0 => context.colors.delete,
            _ => context.colors.text,
          }
        : context.colors.text;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
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
                    color: context.colors.fat,
                    child: PhosphorIcon(
                      PhosphorIconsBold.personSimpleWalk,
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
                                date: stepWithDate.dateTime,
                                dateFormat: 'dd.MM.',
                              ),
                            ) ??
                            '--',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: context.colors.text,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      ///
                      /// SUBTITLE
                      ///
                      Text(
                        capitalizeFirstLetter(
                              getDateString(
                                date: stepWithDate.dateTime,
                                dateFormat: 'EEEE',
                                useTodayYesterdayTomorrow: false,
                              ),
                            ) ??
                            '--',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.colors.text.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                ///
                /// STEPS & CHANGE
                ///
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ///
                    /// STEPS
                    ///
                    Text.rich(
                      TextSpan(
                        text: stepWithDate.steps.round().toStringAsFixed(0),
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: context.colors.text,
                        ),
                        children: [
                          const WidgetSpan(
                            child: SizedBox(width: 4),
                          ),
                          TextSpan(
                            text: 'steps',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              letterSpacing: 1.5,
                              color: context.colors.text.withValues(alpha: 0.7),
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
                    if (stepsChange != null && !isToday)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PhosphorIcon(
                            switch (stepsChange) {
                              > 0 => PhosphorIconsBold.arrowUp,
                              < 0 => PhosphorIconsBold.arrowDown,
                              _ => PhosphorIconsBold.minus,
                            },
                            color: changeColor,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            stepsChange.abs().round().toStringAsFixed(0),
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
    );
  }
}
