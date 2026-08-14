import 'package:flutter/widgets.dart';

import '../../../models/weight_track/weight_track.dart';

class InsightsListTile extends StatelessWidget {
  final Future<void> Function() onDeletePressed;
  final WeightTrack weightTrack;

  const InsightsListTile({
    required this.onDeletePressed,
    required this.weightTrack,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
