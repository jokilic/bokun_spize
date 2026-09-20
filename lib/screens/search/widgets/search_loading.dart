import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/durations.dart';
import 'search_list_tile_loading.dart';

class SearchLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: 2,
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
      child: SearchListTileLoading(),
    ),
  );
}
