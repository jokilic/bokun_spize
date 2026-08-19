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

/// Get all weights recorded on the calendar day before the latest measurement
List<WeightTrack> getWeightTracksFromPreviousCalendarDay({
  required List<WeightTrack> weightTracks,
}) {
  if (weightTracks.isEmpty) {
    return [];
  }

  final currentDateTime = weightTracks.first.dateTime;
  final currentDate = DateTime.utc(
    currentDateTime.year,
    currentDateTime.month,
    currentDateTime.day,
  );
  final previousDate = currentDate.subtract(const Duration(days: 1));

  return weightTracks.where((weightTrack) {
    final dateTime = weightTrack.dateTime;
    final date = DateTime.utc(dateTime.year, dateTime.month, dateTime.day);

    return date == previousDate;
  }).toList();
}

/// Compare the latest weight with the average weight from the previous calendar day
double? getWeightChange({
  required List<WeightTrack> weightTracks,
  required double? lastWeight,
}) {
  final previousDayWeightTracks = getWeightTracksFromPreviousCalendarDay(
    weightTracks: weightTracks,
  );

  final weightChange = previousDayWeightTracks.isNotEmpty && lastWeight != null
      ? lastWeight -
            previousDayWeightTracks.fold<double>(
                  0,
                  (sum, weightTrack) => sum + weightTrack.weight,
                ) /
                previousDayWeightTracks.length
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

/// Get the calendar-day span covered by the latest-to-previous-day change
int? getWeightChangeWithinDays({
  required List<WeightTrack> weightTracks,
}) {
  final previousDayWeightTracks = getWeightTracksFromPreviousCalendarDay(
    weightTracks: weightTracks,
  );

  return previousDayWeightTracks.isNotEmpty ? 1 : null;
}
