import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../models/weight_track/weight_track.dart';
import '../../../util/weight_track.dart';
import 'weights_list_tile.dart';

class WeightsSuccess extends StatelessWidget {
  final List<WeightTrack> weightTracks;
  final int calendarDays;
  final Function(WeightTrack weightTrack) onDeletePressed;

  const WeightsSuccess({
    required this.weightTracks,
    required this.calendarDays,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      ///
      /// WEIGHTS TITLE
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
      /// WEIGHTS LIST
      ///
      SliverList.builder(
        itemCount: weightTracks.length,
        itemBuilder: (context, index) {
          final weightTrack = weightTracks[index];

          final previousWeightChange = getPreviousWeightChange(
            weightTracks: weightTracks,
            weightTrack: weightTrack,
            index: index,
          );

          return WeightsListTile(
            onPressed: HapticFeedback.lightImpact,
            onDeletePressed: () => onDeletePressed(weightTrack),
            weightTrack: weightTrack,
            weightChange: previousWeightChange,
          );
        },
      ),
    ],
  );
}
