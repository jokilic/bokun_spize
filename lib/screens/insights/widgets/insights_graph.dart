import 'package:flutter/widgets.dart';

import '../../../models/weight_track/weight_track.dart';

class InsightsGraph extends StatelessWidget {
  final List<WeightTrack> weightTracks;

  const InsightsGraph({
    required this.weightTracks,
  });

  @override
  Widget build(BuildContext context) => const SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    sliver: SliverToBoxAdapter(
      child: Placeholder(
        fallbackHeight: 160,
      ),
    ),
  );
}
