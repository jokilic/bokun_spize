import 'dart:core';

import '../models/weight_track/weight_track.dart';

List<WeightTrack> getWeightTracksForGraph({
  required List<WeightTrack> weightTracks,
  required int weightChangeWithinDays,
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

        return differenceInDays >= 0 && differenceInDays <= weightChangeWithinDays;
      })
      .toList()
      .reversed
      .toList();

  return visibleWeightTracks;
}

/// Get weights within the requested calendar days before the latest measurement
List<WeightTrack> getPreviousWeightTracksWithinDays({
  required List<WeightTrack> weightTracks,
  required int calendarDays,
}) {
  if (weightTracks.isEmpty || calendarDays <= 0) {
    return [];
  }

  final currentDateTime = weightTracks.first.dateTime;
  final currentDate = DateTime.utc(
    currentDateTime.year,
    currentDateTime.month,
    currentDateTime.day,
  );

  return weightTracks.where((weightTrack) {
    final dateTime = weightTrack.dateTime;
    final date = DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
    final differenceInDays = currentDate.difference(date).inDays;

    return differenceInDays >= 1 && differenceInDays <= calendarDays;
  }).toList();
}

/// Compare the latest weight with the average from the requested calendar days
double? getWeightChange({
  required List<WeightTrack> weightTracks,
  required double? lastWeight,
  required int calendarDays,
}) {
  final previousWeightTracks = getPreviousWeightTracksWithinDays(
    weightTracks: weightTracks,
    calendarDays: calendarDays,
  );

  final weightChange = previousWeightTracks.isNotEmpty && lastWeight != null
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
  required int calendarDays,
}) {
  final previousWeightTracks = getPreviousWeightTracksWithinDays(
    weightTracks: weightTracks,
    calendarDays: calendarDays,
  );

  if (previousWeightTracks.isEmpty) {
    return null;
  }

  final currentDateTime = weightTracks.first.dateTime;
  final currentDate = DateTime.utc(
    currentDateTime.year,
    currentDateTime.month,
    currentDateTime.day,
  );
  final oldestComparedDate = previousWeightTracks
      .map(
        (weightTrack) => DateTime.utc(
          weightTrack.dateTime.year,
          weightTrack.dateTime.month,
          weightTrack.dateTime.day,
        ),
      )
      .reduce((a, b) => a.isBefore(b) ? a : b);

  return currentDate.difference(oldestComparedDate).inDays;
}
