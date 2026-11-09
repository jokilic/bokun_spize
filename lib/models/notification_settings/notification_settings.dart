import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettings {
  final bool weighReminderEnabled;
  final bool dailySummaryEnabled;
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
    required this.dailySummaryEnabled,
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
    dailySummaryEnabled: false,
    announcementsEnabled: false,
    timezone: timezone,
    locale: locale,
  );

  factory NotificationSettings.fromMap(Map<String, dynamic> map) => NotificationSettings(
    weighReminderEnabled: map['weighReminderEnabled'] as bool? ?? false,
    dailySummaryEnabled: map['dailySummaryEnabled'] as bool? ?? false,
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
    bool? dailySummaryEnabled,
    bool? announcementsEnabled,
    String? timezone,
    String? locale,
  }) => NotificationSettings(
    weighReminderEnabled: weighReminderEnabled ?? this.weighReminderEnabled,
    dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
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
    'dailySummaryEnabled': dailySummaryEnabled,
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
