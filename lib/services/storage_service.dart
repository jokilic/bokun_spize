import 'dart:developer';

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

  /// Gets values from `Storage` or falls back to defaults
  Future<void> init() async {
    try {
      final calendarDays = await Future.wait(
        [
          sharedPreferences.getInt(weightsCalendarDaysKey),
          sharedPreferences.getInt(walksCalendarDaysKey),
        ],
      );

      updateState(
        weightsCalendarDays: calendarDays.firstOrNull ?? defaultCalendarDays,
        walksCalendarDays: calendarDays.lastOrNull ?? defaultCalendarDays,
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
