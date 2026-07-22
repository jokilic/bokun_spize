import 'package:cloud_firestore/cloud_firestore.dart';

class WeightTrack {
  final DateTime dateTime;
  final double weight;

  WeightTrack({
    required this.dateTime,
    required this.weight,
  });

  WeightTrack copyWith({
    DateTime? dateTime,
    double? weight,
  }) => WeightTrack(
    dateTime: dateTime ?? this.dateTime,
    weight: weight ?? this.weight,
  );

  factory WeightTrack.fromMap(Map<String, dynamic> map) {
    final dateTime = map['dateTime'];

    return WeightTrack(
      dateTime: switch (dateTime) {
        final Timestamp value => value.toDate(),
        final DateTime value => value,
        final String value => DateTime.parse(value),
        _ => throw FormatException('Invalid WeightTrack dateTime: $dateTime'),
      },
      weight: (map['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'dateTime': dateTime,
    'weight': weight,
  };

  @override
  String toString() => 'WeightTrack(dateTime: $dateTime, weight: $weight)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is WeightTrack && runtimeType == other.runtimeType && dateTime == other.dateTime && weight == other.weight;

  @override
  int get hashCode => dateTime.hashCode ^ weight.hashCode;
}
