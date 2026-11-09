import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationTime {
  final int hour;
  final int minute;

  const NotificationTime({
    required this.hour,
    required this.minute,
  }) : assert(hour >= 0 && hour <= 23),
       assert(minute >= 0 && minute <= 59);

  factory NotificationTime.fromString(
    String? value, {
    required NotificationTime fallback,
  }) {
    final parts = value?.split(':');

    if (parts == null || parts.length != 2) {
      return fallback;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return fallback;
    }

    return NotificationTime(
      hour: hour,
      minute: minute,
    );
  }

  DateTime toDateTime() => DateTime(
    2000,
    1,
    1,
    hour,
    minute,
  );

  String toFirestoreValue() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationTime && hour == other.hour && minute == other.minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

class NotificationSettings {
  static const defaultWeighReminderTime = NotificationTime(
    hour: 8,
    minute: 0,
  );
  static const defaultDailySummaryTime = NotificationTime(
    hour: 20,
    minute: 0,
  );

  final bool weighReminderEnabled;
  final NotificationTime weighReminderTime;
  final bool dailySummaryEnabled;
  final NotificationTime dailySummaryTime;
  final bool announcementsEnabled;
  final String timezone;
  final String locale;
  final DateTime? nextWeighReminderAt;
  final DateTime? lastWeighReminderSentAt;
  final DateTime? nextDailySummaryAt;
  final DateTime? lastDailySummarySentAt;
  final DateTime? lastAnnouncementSentAt;

  const NotificationSettings({
    required this.weighReminderEnabled,
    required this.weighReminderTime,
    required this.dailySummaryEnabled,
    required this.dailySummaryTime,
    required this.announcementsEnabled,
    required this.timezone,
    required this.locale,
    this.nextWeighReminderAt,
    this.lastWeighReminderSentAt,
    this.nextDailySummaryAt,
    this.lastDailySummarySentAt,
    this.lastAnnouncementSentAt,
  });

  factory NotificationSettings.defaults({
    required String timezone,
    required String locale,
  }) => NotificationSettings(
    weighReminderEnabled: false,
    weighReminderTime: defaultWeighReminderTime,
    dailySummaryEnabled: false,
    dailySummaryTime: defaultDailySummaryTime,
    announcementsEnabled: false,
    timezone: timezone,
    locale: locale,
  );

  factory NotificationSettings.fromMap(Map<String, dynamic> map) => NotificationSettings(
    weighReminderEnabled: map['weighReminderEnabled'] as bool? ?? false,
    weighReminderTime: NotificationTime.fromString(
      map['weighReminderTime'] as String?,
      fallback: defaultWeighReminderTime,
    ),
    dailySummaryEnabled: map['dailySummaryEnabled'] as bool? ?? false,
    dailySummaryTime: NotificationTime.fromString(
      map['dailySummaryTime'] as String?,
      fallback: defaultDailySummaryTime,
    ),
    announcementsEnabled: map['announcementsEnabled'] as bool? ?? false,
    timezone: map['timezone'] as String? ?? 'UTC',
    locale: map['locale'] as String? ?? 'hr',
    nextWeighReminderAt: dateTimeFromValue(map['nextWeighReminderAt']),
    lastWeighReminderSentAt: dateTimeFromValue(map['lastWeighReminderSentAt']),
    nextDailySummaryAt: dateTimeFromValue(map['nextDailySummaryAt']),
    lastDailySummarySentAt: dateTimeFromValue(map['lastDailySummarySentAt']),
    lastAnnouncementSentAt: dateTimeFromValue(map['lastAnnouncementSentAt']),
  );

  NotificationSettings copyWith({
    bool? weighReminderEnabled,
    NotificationTime? weighReminderTime,
    bool? dailySummaryEnabled,
    NotificationTime? dailySummaryTime,
    bool? announcementsEnabled,
    String? timezone,
    String? locale,
  }) => NotificationSettings(
    weighReminderEnabled: weighReminderEnabled ?? this.weighReminderEnabled,
    weighReminderTime: weighReminderTime ?? this.weighReminderTime,
    dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
    dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
    announcementsEnabled: announcementsEnabled ?? this.announcementsEnabled,
    timezone: timezone ?? this.timezone,
    locale: locale ?? this.locale,
    nextWeighReminderAt: nextWeighReminderAt,
    lastWeighReminderSentAt: lastWeighReminderSentAt,
    nextDailySummaryAt: nextDailySummaryAt,
    lastDailySummarySentAt: lastDailySummarySentAt,
    lastAnnouncementSentAt: lastAnnouncementSentAt,
  );

  Map<String, dynamic> toMap({bool includeServerFields = false}) => {
    'weighReminderEnabled': weighReminderEnabled,
    'weighReminderTime': weighReminderTime.toFirestoreValue(),
    'dailySummaryEnabled': dailySummaryEnabled,
    'dailySummaryTime': dailySummaryTime.toFirestoreValue(),
    'announcementsEnabled': announcementsEnabled,
    'timezone': timezone,
    'locale': locale,
    if (includeServerFields) ...{
      if (nextWeighReminderAt != null) 'nextWeighReminderAt': Timestamp.fromDate(nextWeighReminderAt!),
      if (lastWeighReminderSentAt != null) 'lastWeighReminderSentAt': Timestamp.fromDate(lastWeighReminderSentAt!),
      if (nextDailySummaryAt != null) 'nextDailySummaryAt': Timestamp.fromDate(nextDailySummaryAt!),
      if (lastDailySummarySentAt != null) 'lastDailySummarySentAt': Timestamp.fromDate(lastDailySummarySentAt!),
      if (lastAnnouncementSentAt != null) 'lastAnnouncementSentAt': Timestamp.fromDate(lastAnnouncementSentAt!),
    },
  };

  static DateTime? dateTimeFromValue(Object? value) => switch (value) {
    final Timestamp timestamp => timestamp.toDate(),
    final DateTime dateTime => dateTime,
    final String dateTime => DateTime.tryParse(dateTime),
    _ => null,
  };
}
