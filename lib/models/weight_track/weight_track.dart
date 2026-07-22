import 'package:cloud_firestore/cloud_firestore.dart';

class WeightTrack {
  final String id;
  final DateTime dateTime;
  final double weight;

  WeightTrack({
    required this.id,
    required this.dateTime,
    required this.weight,
  });

  WeightTrack copyWith({
    String? id,
    DateTime? dateTime,
    double? weight,
  }) => WeightTrack(
    id: id ?? this.id,
    dateTime: dateTime ?? this.dateTime,
    weight: weight ?? this.weight,
  );

  factory WeightTrack.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    final dateTime = map['dateTime'];

    return WeightTrack(
      id: id,
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
    'id': id,
    'dateTime': dateTime,
    'weight': weight,
  };

  @override
  String toString() => 'WeightTrack(id: $id, dateTime: $dateTime, weight: $weight)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WeightTrack && runtimeType == other.runtimeType && id == other.id && dateTime == other.dateTime && weight == other.weight;

  @override
  int get hashCode => id.hashCode ^ dateTime.hashCode ^ weight.hashCode;
}
