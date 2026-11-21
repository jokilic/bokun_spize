import 'dart:developer';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../screens/account/account_controller.dart';
import '../util/typedefs.dart';

class StorageService extends ValueNotifier<({CalendarDays calendarDays, MealOpenedNumbers mealOpenedNumbers, SettingsValues settingsValues})> {
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
         mealOpenedNumbers: (
           aiAddMealOpenedNumber: 0,
           manualAddMealOpenedNumber: 0,
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
      final mealOpenedNumbers = await Future.wait([
        sharedPreferences.getInt(aiAddMealOpenedNumberKey),
        sharedPreferences.getInt(manualAddMealOpenedNumberKey),
      ]);

      final savedTheme = await sharedPreferences.getString(themeKey);

      updateState(
        weightsCalendarDays: calendarDays.firstOrNull ?? defaultCalendarDays,
        walksCalendarDays: calendarDays.lastOrNull ?? defaultCalendarDays,
        aiAddMealOpenedNumber: mealOpenedNumbers.firstOrNull ?? 0,
        manualAddMealOpenedNumber: mealOpenedNumbers.lastOrNull ?? 0,
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
  static const aiAddMealOpenedNumberKey = 'aiAddMealOpenedNumber';
  static const manualAddMealOpenedNumberKey = 'manualAddMealOpenedNumber';

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

  /// Increments and persists the AI meal screen open count up to six
  int incrementAIAddMealOpenedNumber() {
    final currentNumber = value.mealOpenedNumbers.aiAddMealOpenedNumber;

    if (currentNumber > 5) {
      return currentNumber;
    }

    final updatedNumber = currentNumber + 1;

    sharedPreferences.setInt(
      aiAddMealOpenedNumberKey,
      updatedNumber,
    );

    updateState(
      aiAddMealOpenedNumber: updatedNumber,
    );

    return updatedNumber;
  }

  /// Increments and persists the manual meal screen open count up to six
  int incrementManualAddMealOpenedNumber() {
    final currentNumber = value.mealOpenedNumbers.manualAddMealOpenedNumber;

    if (currentNumber > 5) {
      return currentNumber;
    }

    final updatedNumber = currentNumber + 1;

    sharedPreferences.setInt(
      manualAddMealOpenedNumberKey,
      updatedNumber,
    );

    updateState(
      manualAddMealOpenedNumber: updatedNumber,
    );

    return updatedNumber;
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
    int? aiAddMealOpenedNumber,
    int? manualAddMealOpenedNumber,
    ThemeEnum? theme,
  }) => value = (
    calendarDays: (
      weightsCalendarDays: weightsCalendarDays ?? value.calendarDays.weightsCalendarDays,
      walksCalendarDays: walksCalendarDays ?? value.calendarDays.walksCalendarDays,
    ),
    mealOpenedNumbers: (
      aiAddMealOpenedNumber: aiAddMealOpenedNumber ?? value.mealOpenedNumbers.aiAddMealOpenedNumber,
      manualAddMealOpenedNumber: manualAddMealOpenedNumber ?? value.mealOpenedNumbers.manualAddMealOpenedNumber,
    ),
    settingsValues: (
      theme: theme ?? value.settingsValues.theme,
    ),
  );
}
