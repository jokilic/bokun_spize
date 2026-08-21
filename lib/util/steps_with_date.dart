import 'dart:core';

import '../models/steps_with_date/steps_with_date.dart';

List<StepsWithDate> getStepsWithDateForGraph({
  required List<StepsWithDate> stepsWithDate,
  required int stepsChangeWithinDays,
}) {
  final sortedStepsWithDate = [...stepsWithDate]
    ..sort(
      (a, b) => b.dateTime.compareTo(a.dateTime),
    );

  final latestDateTime = sortedStepsWithDate.firstOrNull?.dateTime;
  final latestDate = latestDateTime == null
      ? null
      : DateTime.utc(
          latestDateTime.year,
          latestDateTime.month,
          latestDateTime.day,
        );

  return sortedStepsWithDate
      .where((stepWithDate) {
        if (latestDate == null) {
          return false;
        }

        final dateTime = stepWithDate.dateTime;
        final date = DateTime.utc(
          dateTime.year,
          dateTime.month,
          dateTime.day,
        );
        final differenceInDays = latestDate.difference(date).inDays;

        return differenceInDays >= 0 && differenceInDays <= stepsChangeWithinDays;
      })
      .toList()
      .reversed
      .toList();
}

/// Gets step totals from the requested calendar days before the latest entry
List<StepsWithDate> getPreviousStepsWithinDays({
  required List<StepsWithDate> stepsWithDate,
  required int calendarDays,
}) {
  if (stepsWithDate.isEmpty || calendarDays <= 0) {
    return [];
  }

  final sortedStepsWithDate = [...stepsWithDate]
    ..sort(
      (a, b) => b.dateTime.compareTo(a.dateTime),
    );
  final currentDateTime = sortedStepsWithDate.first.dateTime;
  final currentDate = DateTime.utc(
    currentDateTime.year,
    currentDateTime.month,
    currentDateTime.day,
  );

  return sortedStepsWithDate.where((stepWithDate) {
    final dateTime = stepWithDate.dateTime;
    final date = DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
    final differenceInDays = currentDate.difference(date).inDays;

    return differenceInDays >= 1 && differenceInDays <= calendarDays;
  }).toList();
}

/// Compares the latest step total with the average from previous calendar days
double? getStepsChange({
  required List<StepsWithDate> stepsWithDate,
  required int? latestSteps,
  required int calendarDays,
}) {
  final previousSteps = getPreviousStepsWithinDays(
    stepsWithDate: stepsWithDate,
    calendarDays: calendarDays,
  );

  return previousSteps.isNotEmpty && latestSteps != null
      ? latestSteps -
            previousSteps.fold<double>(
                  0,
                  (sum, stepWithDate) => sum + stepWithDate.steps,
                ) /
                previousSteps.length
      : null;
}

/// Compares a step total with the preceding entry in a newest-first list
int? getPreviousStepsChange({
  required List<StepsWithDate> stepsWithDate,
  required StepsWithDate stepWithDate,
  required int index,
}) {
  final previousStepWithDate = index + 1 < stepsWithDate.length ? stepsWithDate[index + 1] : null;

  return previousStepWithDate != null ? stepWithDate.steps - previousStepWithDate.steps : null;
}

/// Gets the calendar-day span covered by the step totals used for the change
int? getStepsChangeWithinDays({
  required List<StepsWithDate> stepsWithDate,
  required int calendarDays,
}) {
  final previousSteps = getPreviousStepsWithinDays(
    stepsWithDate: stepsWithDate,
    calendarDays: calendarDays,
  );

  if (previousSteps.isEmpty) {
    return null;
  }

  final latestStepWithDate = stepsWithDate.reduce(
    (a, b) => a.dateTime.isAfter(b.dateTime) ? a : b,
  );
  final currentDate = DateTime.utc(
    latestStepWithDate.dateTime.year,
    latestStepWithDate.dateTime.month,
    latestStepWithDate.dateTime.day,
  );
  final oldestComparedDate = previousSteps
      .map(
        (stepWithDate) => DateTime.utc(
          stepWithDate.dateTime.year,
          stepWithDate.dateTime.month,
          stepWithDate.dateTime.day,
        ),
      )
      .reduce((a, b) => a.isBefore(b) ? a : b);

  return currentDate.difference(oldestComparedDate).inDays;
}
