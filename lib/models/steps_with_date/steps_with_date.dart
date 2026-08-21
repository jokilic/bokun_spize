import 'package:cloud_firestore/cloud_firestore.dart';

class StepsWithDate {
  final DateTime dateTime;
  final int steps;

  StepsWithDate({
    required this.dateTime,
    required this.steps,
  });

  StepsWithDate copyWith({
    DateTime? dateTime,
    int? steps,
  }) => StepsWithDate(
    dateTime: dateTime ?? this.dateTime,
    steps: steps ?? this.steps,
  );

  factory StepsWithDate.fromMap(Map<String, dynamic> map) {
    final dateTime = map['dateTime'];

    return StepsWithDate(
      dateTime: switch (dateTime) {
        final Timestamp value => value.toDate(),
        final DateTime value => value,
        final String value => DateTime.parse(value),
        _ => throw FormatException('Invalid StepsWithDate dateTime: $dateTime'),
      },
      steps: (map['steps'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    'dateTime': dateTime,
    'steps': steps,
  };

  @override
  String toString() => 'StepsWithDate(dateTime: $dateTime, steps: $steps)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is StepsWithDate && runtimeType == other.runtimeType && dateTime == other.dateTime && steps == other.steps;

  @override
  int get hashCode => dateTime.hashCode ^ steps.hashCode;
}
