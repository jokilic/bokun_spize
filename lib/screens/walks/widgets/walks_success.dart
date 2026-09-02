import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/steps_with_date/steps_with_date.dart';
import 'walks_list_tile.dart';

class WalksSuccess extends StatelessWidget {
  final List<StepsWithDate> stepsWithDate;
  final int calendarDays;

  const WalksSuccess({
    required this.stepsWithDate,
    required this.calendarDays,
  });

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      ///
      /// STEPS TITLE
      ///
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal,
          vertical: 12,
        ),
        sliver: SliverToBoxAdapter(
          child: Animate(
            effects: const [
              FadeEffect(
                duration: BokunSpizeDurations.stateTransition,
                curve: Curves.easeOut,
              ),
              MoveEffect(
                begin: Offset(0, 12),
                end: Offset.zero,
                duration: BokunSpizeDurations.stateTransition,
                curve: Curves.easeOutCubic,
              ),
            ],
            child: const Text(
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
      ),

      ///
      /// STEPS LIST
      ///
      SliverList.builder(
        itemCount: stepsWithDate.length,
        itemBuilder: (context, index) {
          final stepWithDate = stepsWithDate[index];

          final previousStepsWithDate = index + 1 < stepsWithDate.length ? stepsWithDate[index + 1] : null;

          return Animate(
            key: ValueKey(stepWithDate.dateTime.microsecondsSinceEpoch),
            delay: BokunSpizeDurations.stateTransitionStagger * index.clamp(0, 6),
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
            child: WalksListTile(
              onPressed: HapticFeedback.lightImpact,
              stepWithDate: stepWithDate,
              previousStepsWithDate: previousStepsWithDate,
            ),
          );
        },
      ),
    ],
  );
}
