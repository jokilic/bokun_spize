import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
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

          return Animate(
            key: ValueKey(weightTrack.id),
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
            child: WeightsListTile(
              onPressed: HapticFeedback.lightImpact,
              onDeletePressed: () => onDeletePressed(weightTrack),
              weightTrack: weightTrack,
              weightChange: previousWeightChange,
            ),
          );
        },
      ),
    ],
  );
}
