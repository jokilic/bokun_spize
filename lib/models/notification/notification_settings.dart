import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettings {
  final bool weighReminderEnabled;
  final DateTime weighReminderTime;
  final bool dailySummaryEnabled;
  final DateTime dailyRecapTime;
  final bool dailyRecapStepsEnabled;
  final bool announcementsEnabled;
  final String timezone;
  final String locale;

  const NotificationSettings({
    required this.weighReminderEnabled,
    required this.weighReminderTime,
    required this.dailySummaryEnabled,
    required this.dailyRecapTime,
    required this.dailyRecapStepsEnabled,
    required this.announcementsEnabled,
    required this.timezone,
    required this.locale,
  });

  factory NotificationSettings.defaults({
    required String timezone,
    required String locale,
  }) => NotificationSettings(
    weighReminderEnabled: false,
    weighReminderTime: DateTime(2020, 1, 1, 9),
    dailySummaryEnabled: false,
    dailyRecapTime: DateTime(2020, 1, 1, 8),
    dailyRecapStepsEnabled: false,
    announcementsEnabled: false,
    timezone: timezone,
    locale: locale,
  );

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    final weighReminderTime = switch (map['weighReminderTime']) {
      final Timestamp value => value.toDate(),
      final DateTime value => value.toLocal(),
      _ => DateTime(2020, 1, 1, 9),
    };
    final dailyRecapTime = switch (map['dailyRecapTime']) {
      final Timestamp value => value.toDate(),
      final DateTime value => value.toLocal(),
      _ => DateTime(2020, 1, 1, 8),
    };

    return NotificationSettings(
      weighReminderEnabled: map['weighReminderEnabled'] as bool? ?? false,
      weighReminderTime: DateTime(
        2020,
        1,
        1,
        weighReminderTime.hour,
        weighReminderTime.minute,
      ),
      dailySummaryEnabled: map['dailySummaryEnabled'] as bool? ?? false,
      dailyRecapTime: DateTime(
        2020,
        1,
        1,
        dailyRecapTime.hour,
        dailyRecapTime.minute,
      ),
      dailyRecapStepsEnabled: map['dailyRecapStepsEnabled'] as bool? ?? false,
      announcementsEnabled: map['announcementsEnabled'] as bool? ?? false,
      timezone: map['timezone'] as String? ?? 'UTC',
      locale: map['locale'] as String? ?? 'hr',
    );
  }

  NotificationSettings copyWith({
    bool? weighReminderEnabled,
    DateTime? weighReminderTime,
    bool? dailySummaryEnabled,
    DateTime? dailyRecapTime,
    bool? dailyRecapStepsEnabled,
    bool? announcementsEnabled,
    String? timezone,
    String? locale,
  }) => NotificationSettings(
    weighReminderEnabled: weighReminderEnabled ?? this.weighReminderEnabled,
    weighReminderTime: weighReminderTime ?? this.weighReminderTime,
    dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
    dailyRecapTime: dailyRecapTime ?? this.dailyRecapTime,
    dailyRecapStepsEnabled: dailyRecapStepsEnabled ?? this.dailyRecapStepsEnabled,
    announcementsEnabled: announcementsEnabled ?? this.announcementsEnabled,
    timezone: timezone ?? this.timezone,
    locale: locale ?? this.locale,
  );

  Map<String, dynamic> toMap() => {
    'weighReminderEnabled': weighReminderEnabled,
    'weighReminderTime': Timestamp.fromDate(weighReminderTime),
    'dailySummaryEnabled': dailySummaryEnabled,
    'dailyRecapTime': Timestamp.fromDate(dailyRecapTime),
    'dailyRecapStepsEnabled': dailyRecapStepsEnabled,
    'announcementsEnabled': announcementsEnabled,
    'timezone': timezone,
    'locale': locale,
  };
}
