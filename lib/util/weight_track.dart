import '../models/weight_track/weight_track.dart';

/// Compare the current weight with the average of up to seven previous weights
double? getWeightChange({
  required List<WeightTrack> weightTracks,
  required double? lastWeight,
}) {
  final previousWeightTracks = weightTracks.skip(1).take(7).toList();

  final weightChange = weightTracks.length > 2 && lastWeight != null
      ? lastWeight -
            previousWeightTracks.fold<double>(
                  0,
                  (sum, weightTrack) => sum + weightTrack.weight,
                ) /
                previousWeightTracks.length
      : null;

  return weightChange;
}
