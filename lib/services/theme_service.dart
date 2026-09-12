import 'package:flutter/material.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  ///
  /// CONSTRUCTOR
  ///

  ThemeService() : super(ThemeMode.system);

  ///
  /// METHODS
  ///

  /// Toggles active `theme`
  void toggleTheme() => value = value != ThemeMode.light ? ThemeMode.light : ThemeMode.dark;
}
