import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/durations.dart';
import 'meals_list_tile_loading.dart';

class MealsLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: 8,
    itemBuilder: (context, index) => Animate(
      key: ValueKey(index),
      delay: BokunSpizeDurations.stateTransitionStagger * index,
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
      ],
      child: MealsListTileLoading(),
    ),
  );
}
