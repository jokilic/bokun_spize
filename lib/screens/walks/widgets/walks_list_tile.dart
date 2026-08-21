import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../models/steps_with_date/steps_with_date.dart';
import '../../../util/date_time.dart';
import '../../../util/format.dart';

class WalksListTile extends StatelessWidget {
  final StepsWithDate stepWithDate;
  final StepsWithDate? previousStepsWithDate;

  const WalksListTile({
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
            > 0 => BokunSpizeColors.green,
            < 0 => BokunSpizeColors.red,
            _ => BokunSpizeColors.black,
          }
        : BokunSpizeColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
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
                    PhosphorIconsBold.personSimpleWalk,
                    color: BokunSpizeColors.green,
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
                              date: stepWithDate.dateTime,
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
                      isToday ? 'Current day' : 'Daily total',
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
                  /// STEPS
                  ///
                  Text.rich(
                    TextSpan(
                      text: NumberFormat.decimalPattern('en').format(stepWithDate.steps),
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
                          text: 'steps',
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
                          NumberFormat.decimalPattern('en').format(stepsChange.abs()),
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
    );
  }
}
