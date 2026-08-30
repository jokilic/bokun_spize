import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends ValueNotifier<({int weightsCalendarDays, int walksCalendarDays})> {
  ///
  /// CONSTRUCTOR
  ///

  final SharedPreferencesAsync sharedPreferences;

  StorageService({
    required this.sharedPreferences,
  }) : super((
         weightsCalendarDays: defaultCalendarDays,
         walksCalendarDays: defaultCalendarDays,
       ));

  ///
  /// INIT
  ///

  /// Gets values from storage or falls back to defaults
  Future<void> init() async {
    final weightsCalendarDays = await sharedPreferences.getInt(weightsCalendarDaysKey);
    final walksCalendarDays = await sharedPreferences.getInt(walksCalendarDaysKey);

    updateState(
      weightsCalendarDays: weightsCalendarDays ?? defaultCalendarDays,
      walksCalendarDays: walksCalendarDays ?? defaultCalendarDays,
    );
  }

  ///
  /// VARIABLES
  ///

  static const defaultCalendarDays = 7;
  static const weightsCalendarDaysKey = 'weightsCalendarDays';
  static const walksCalendarDaysKey = 'walksCalendarDays';

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

  /// Updates `state`
  void updateState({
    int? weightsCalendarDays,
    int? walksCalendarDays,
  }) => value = (
    weightsCalendarDays: weightsCalendarDays ?? value.weightsCalendarDays,
    walksCalendarDays: walksCalendarDays ?? value.walksCalendarDays,
  );
}
