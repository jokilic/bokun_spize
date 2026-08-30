import 'package:flutter/material.dart';

// TODO: Initialize SharedPreferences of take the instance from the constructor
// TODO: Also create methods for `updateState` and modifying the values in SharedPreferences

class StorageService extends ValueNotifier<({int weightsCalendarDays, int walksCalendarDays})> {
  ///
  /// CONSTRUCTOR
  ///

  StorageService()
    : super((
        weightsCalendarDays: 7,
        walksCalendarDays: 7,
      ));

  ///
  /// METHODS
  ///
}
