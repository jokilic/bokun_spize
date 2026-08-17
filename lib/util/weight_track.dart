import 'dart:core';

import '../models/weight_track/weight_track.dart';

List<WeightTrack> getWeightTracksForGraph({
  required List<WeightTrack> weightTracks,
  required int daysToShow,
}) {
  final sortedWeightTracks = [...weightTracks]
    ..sort(
      (a, b) => b.dateTime.compareTo(
        a.dateTime,
      ),
    );

  final latestDateTime = sortedWeightTracks.isEmpty ? null : sortedWeightTracks.first.dateTime;
  final latestDate = latestDateTime == null
      ? null
      : DateTime.utc(
          latestDateTime.year,
          latestDateTime.month,
          latestDateTime.day,
        );

  final visibleWeightTracks = sortedWeightTracks
      .where((weightTrack) {
        if (latestDate == null) {
          return false;
        }

        final dateTime = weightTrack.dateTime;
        final date = DateTime.utc(
          dateTime.year,
          dateTime.month,
          dateTime.day,
        );
        final differenceInDays = latestDate.difference(date).inDays;

        return differenceInDays >= 0 && differenceInDays < daysToShow;
      })
      .toList()
      .reversed
      .toList();

  return visibleWeightTracks;
}

/// Get previous weights recorded within seven calendar days of the current one
List<WeightTrack> getPreviousWeightTracksWithinSevenDays({
  required List<WeightTrack> weightTracks,
}) {
  if (weightTracks.isEmpty) {
    return [];
  }

  final currentDateTime = weightTracks.first.dateTime;
  final currentDate = DateTime(
    currentDateTime.year,
    currentDateTime.month,
    currentDateTime.day,
  );

  return weightTracks.skip(1).where((weightTrack) {
    final dateTime = weightTrack.dateTime;
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final differenceInDays = currentDate.difference(date).inDays;

    return differenceInDays >= 0 && differenceInDays <= 7;
  }).toList();
}

/// Compare the current weight with the average of previous weights from the last seven days
double? getWeightChange({
  required List<WeightTrack> weightTracks,
  required double? lastWeight,
}) {
  final previousWeightTracks = getPreviousWeightTracksWithinSevenDays(
    weightTracks: weightTracks,
  );

  final weightChange = previousWeightTracks.length > 1 && lastWeight != null
      ? lastWeight -
            previousWeightTracks.fold<double>(
                  0,
                  (sum, weightTrack) => sum + weightTrack.weight,
                ) /
                previousWeightTracks.length
      : null;

  return weightChange;
}

/// Compare the current weight with the previous weight
double? getPreviousWeightChange({
  required List<WeightTrack> weightTracks,
  required WeightTrack weightTrack,
  required int index,
}) {
  final previousWeightTrack = index + 1 < weightTracks.length ? weightTracks[index + 1] : null;
  final weightChange = previousWeightTrack != null ? weightTrack.weight - previousWeightTrack.weight : null;

  return weightChange;
}

/// Get the calendar-day span covered by the weights used for the change
int? getWeightChangeWithinDays({
  required List<WeightTrack> weightTracks,
}) {
  final previousWeightTracks = getPreviousWeightTracksWithinSevenDays(
    weightTracks: weightTracks,
  );

  if (previousWeightTracks.length <= 1) {
    return null;
  }

  final currentDateTime = weightTracks.first.dateTime;
  final oldestComparedDateTime = previousWeightTracks.last.dateTime;
  final currentDate = DateTime(
    currentDateTime.year,
    currentDateTime.month,
    currentDateTime.day,
  );
  final oldestComparedDate = DateTime(
    oldestComparedDateTime.year,
    oldestComparedDateTime.month,
    oldestComparedDateTime.day,
  );

  return currentDate.difference(oldestComparedDate).inDays.abs();
}
