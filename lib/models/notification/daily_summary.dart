import 'package:cloud_firestore/cloud_firestore.dart';

class DailySummary {
  final String id;
  final DateTime dayBeingSummarized;
  final DateTime summaryAt;
  final String timezone;
  final Map<String, String> notification;
  final String methodOfCreation;

  const DailySummary({
    required this.id,
    required this.dayBeingSummarized,
    required this.summaryAt,
    required this.timezone,
    required this.notification,
    required this.methodOfCreation,
  });

  factory DailySummary.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    final dayBeingSummarized = map['dayBeingSummarized'];
    final summaryAt = map['summaryAt'];
    final notification = map['notification'];

    return DailySummary(
      id: id,
      dayBeingSummarized: switch (dayBeingSummarized) {
        final Timestamp value => value.toDate(),
        final DateTime value => value,
        final String value => DateTime.parse(value),
        _ => throw FormatException(
          'Invalid DailySummary dayBeingSummarized: $dayBeingSummarized',
        ),
      },
      summaryAt: switch (summaryAt) {
        final Timestamp value => value.toDate(),
        final DateTime value => value,
        final String value => DateTime.parse(value),
        _ => throw FormatException(
          'Invalid DailySummary summaryAt: $summaryAt',
        ),
      },
      timezone: map['timezone'] as String? ?? 'UTC',
      notification: notification is Map
          ? notification.map(
              (key, value) => MapEntry(
                key.toString(),
                value.toString(),
              ),
            )
          : const <String, String>{},
      methodOfCreation: map['methodOfCreation'] as String? ?? '--',
    );
  }

  String notificationForLanguage(String languageCode) => notification[languageCode] ?? notification['en'] ?? notification.values.firstOrNull ?? '';

  @override
  String toString() =>
      'DailySummary(id: $id, dayBeingSummarized: $dayBeingSummarized, summaryAt: $summaryAt, timezone: $timezone, notification: $notification, methodOfCreation: $methodOfCreation)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          dayBeingSummarized == other.dayBeingSummarized &&
          summaryAt == other.summaryAt &&
          timezone == other.timezone &&
          notification == other.notification &&
          methodOfCreation == other.methodOfCreation;

  @override
  int get hashCode => id.hashCode ^ dayBeingSummarized.hashCode ^ summaryAt.hashCode ^ timezone.hashCode ^ notification.hashCode ^ methodOfCreation.hashCode;
}
