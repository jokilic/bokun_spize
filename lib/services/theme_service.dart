import 'package:flutter/material.dart';

import '../screens/account/account_controller.dart';
import '../util/theme.dart';
import 'storage_service.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  ///
  /// CONSTRUCTOR
  ///

  final StorageService storage;

  ThemeService({
    required this.storage,
  }) : super(
         getThemeModeFromEnum(
           themeEnum: storage.value.settingsValues.theme,
         ),
       );

  ///
  /// METHODS
  ///

  /// Updates active `theme` & stores in `Storage`
  void updateTheme({required ThemeEnum newThemeEnum}) {
    // TODO: Implement this method properly, as the comment states
    // value = value != ThemeMode.light ? ThemeMode.light : ThemeMode.dark;
  }
}
