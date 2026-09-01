import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
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
            onPressed: HapticFeedback.lightImpact,
            stepWithDate: stepWithDate,
            previousStepsWithDate: previousStepsWithDate,
          );
        },
      ),
    ],
  );
}
