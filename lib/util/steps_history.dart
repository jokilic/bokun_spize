import 'package:flutter/services.dart';

import '../models/steps_with_date/steps_with_date.dart';

class StepsHistory {
  const StepsHistory();

  static const channel = MethodChannel(
    'com.josipkilic.bokun_spize/steps_history',
  );

  /// Finds the oldest step record accessible under the current permissions
  Future<DateTime?> getEarliestStepDate(DateTime endTime) async {
    final timestamp = await channel.invokeMethod<int>(
      'getEarliestStepDate',
      {'endTime': endTime.millisecondsSinceEpoch},
    );

    return timestamp == null ? null : DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Reads aggregated calendar-day totals without downloading individual samples
  Future<List<StepsWithDate>> getDailySteps(DateTime startTime, DateTime endTime) async {
    final rows = await channel.invokeListMethod<dynamic>(
      'getDailySteps',
      {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      },
    );

    return (rows ?? []).map((row) {
      final data = Map<String, dynamic>.from(row as Map);

      return StepsWithDate(
        dateTime: DateTime.fromMillisecondsSinceEpoch(data['date'] as int),
        steps: data['steps'] as int,
      );
    }).toList();
  }
}
