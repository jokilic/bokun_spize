class NotificationSettings {
  final bool weighReminderEnabled;
  final int weighReminderHour;
  final int weighReminderMinute;
  final bool dailySummaryEnabled;
  final bool announcementsEnabled;
  final String timezone;
  final String locale;

  const NotificationSettings({
    required this.weighReminderEnabled,
    required this.weighReminderHour,
    required this.weighReminderMinute,
    required this.dailySummaryEnabled,
    required this.announcementsEnabled,
    required this.timezone,
    required this.locale,
  });

  factory NotificationSettings.defaults({
    required String timezone,
    required String locale,
  }) => NotificationSettings(
    weighReminderEnabled: false,
    weighReminderHour: 9,
    weighReminderMinute: 0,
    dailySummaryEnabled: false,
    announcementsEnabled: false,
    timezone: timezone,
    locale: locale,
  );

  factory NotificationSettings.fromMap(Map<String, dynamic> map) => NotificationSettings(
    weighReminderEnabled: map['weighReminderEnabled'] as bool? ?? false,
    weighReminderHour: map['weighReminderHour'] as int? ?? 9,
    weighReminderMinute: map['weighReminderMinute'] as int? ?? 0,
    dailySummaryEnabled: map['dailySummaryEnabled'] as bool? ?? false,
    announcementsEnabled: map['announcementsEnabled'] as bool? ?? false,
    timezone: map['timezone'] as String? ?? 'UTC',
    locale: map['locale'] as String? ?? 'hr',
  );

  NotificationSettings copyWith({
    bool? weighReminderEnabled,
    int? weighReminderHour,
    int? weighReminderMinute,
    bool? dailySummaryEnabled,
    bool? announcementsEnabled,
    String? timezone,
    String? locale,
  }) => NotificationSettings(
    weighReminderEnabled: weighReminderEnabled ?? this.weighReminderEnabled,
    weighReminderHour: weighReminderHour ?? this.weighReminderHour,
    weighReminderMinute: weighReminderMinute ?? this.weighReminderMinute,
    dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
    announcementsEnabled: announcementsEnabled ?? this.announcementsEnabled,
    timezone: timezone ?? this.timezone,
    locale: locale ?? this.locale,
  );

  Map<String, dynamic> toMap() => {
    'weighReminderEnabled': weighReminderEnabled,
    'weighReminderHour': weighReminderHour,
    'weighReminderMinute': weighReminderMinute,
    'dailySummaryEnabled': dailySummaryEnabled,
    'announcementsEnabled': announcementsEnabled,
    'timezone': timezone,
    'locale': locale,
  };
}
