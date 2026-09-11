import 'package:flutter/material.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  ///
  /// CONSTRUCTOR
  ///

  ThemeService() : super(ThemeMode.light);

  ///
  /// METHODS
  ///

  /// Toggles active `theme`
  void toggleTheme() => value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}
