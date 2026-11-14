import 'dart:developer';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../screens/account/account_controller.dart';
import '../util/typedefs.dart';

class StorageService extends ValueNotifier<({CalendarDays calendarDays, SettingsValues settingsValues})> {
  ///
  /// CONSTRUCTOR
  ///

  final SharedPreferencesAsync sharedPreferences;

  StorageService({
    required this.sharedPreferences,
  }) : super((
         calendarDays: (
           weightsCalendarDays: defaultCalendarDays,
           walksCalendarDays: defaultCalendarDays,
         ),
         settingsValues: (
           theme: defaultTheme,
         ),
       ));

  ///
  /// INIT
  ///

  /// Gets values from `Storage` or falls back to defaults
  Future<void> init() async {
    try {
      final calendarDays = await Future.wait([
        sharedPreferences.getInt(weightsCalendarDaysKey),
        sharedPreferences.getInt(walksCalendarDaysKey),
      ]);

      final savedTheme = await sharedPreferences.getString(themeKey);

      updateState(
        weightsCalendarDays: calendarDays.firstOrNull ?? defaultCalendarDays,
        walksCalendarDays: calendarDays.lastOrNull ?? defaultCalendarDays,
        theme:
            ThemeEnum.values
                .where(
                  (theme) => theme.name == savedTheme,
                )
                .firstOrNull ??
            defaultTheme,
      );
    } catch (error) {
      log(
        'StorageService initialization failed',
        error: error,
      );
    }
  }

  ///
  /// VARIABLES
  ///

  static const defaultCalendarDays = 7;
  static const defaultTheme = ThemeEnum.system;

  static const weightsCalendarDaysKey = 'weightsCalendarDays';
  static const walksCalendarDaysKey = 'walksCalendarDays';

  static const themeKey = 'theme';
  static const notificationDeviceIdKey = 'notificationDeviceId';
  static const notificationAnnouncementTopicKey = 'notificationAnnouncementTopic';

  ///
  /// METHODS
  ///

  /// Persists and updates the number of days shown in the weights calendar
  void setWeightsCalendarDays(int calendarDays) {
    sharedPreferences.setInt(
      weightsCalendarDaysKey,
      calendarDays,
    );

    updateState(
      weightsCalendarDays: calendarDays,
    );
  }

  /// Persists and updates the number of days shown in the walks calendar
  void setWalksCalendarDays(int calendarDays) {
    sharedPreferences.setInt(
      walksCalendarDaysKey,
      calendarDays,
    );

    updateState(
      walksCalendarDays: calendarDays,
    );
  }

  /// Persists and updates the selected theme
  void setTheme(ThemeEnum theme) {
    sharedPreferences.setString(
      themeKey,
      theme.name,
    );

    updateState(
      theme: theme,
    );
  }

  /// Returns the stable identifier used for this application installation
  Future<String> getNotificationDeviceId() async {
    final storedDeviceId = await sharedPreferences.getString(
      notificationDeviceIdKey,
    );
    final deviceIdPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    if (storedDeviceId != null && deviceIdPattern.hasMatch(storedDeviceId)) {
      return storedDeviceId;
    }

    /// Uses `v4` because the installation ID should be random and opaque
    final deviceId = const Uuid().v4();

    await sharedPreferences.setString(
      notificationDeviceIdKey,
      deviceId,
    );

    return deviceId;
  }

  /// Returns the announcement topic last synchronized for this installation
  Future<String?> getNotificationAnnouncementTopic() => sharedPreferences.getString(
    notificationAnnouncementTopicKey,
  );

  /// Persists the announcement topic currently synchronized for this installation
  Future<void> setNotificationAnnouncementTopic(String? topic) async {
    if (topic == null) {
      await sharedPreferences.remove(notificationAnnouncementTopicKey);
      return;
    }

    await sharedPreferences.setString(
      notificationAnnouncementTopicKey,
      topic,
    );
  }

  /// Updates `state`
  void updateState({
    int? weightsCalendarDays,
    int? walksCalendarDays,
    ThemeEnum? theme,
  }) => value = (
    calendarDays: (
      weightsCalendarDays: weightsCalendarDays ?? value.calendarDays.weightsCalendarDays,
      walksCalendarDays: walksCalendarDays ?? value.calendarDays.walksCalendarDays,
    ),
    settingsValues: (
      theme: theme ?? value.settingsValues.theme,
    ),
  );
}
