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
    value = getThemeModeFromEnum(
      themeEnum: newThemeEnum,
    );

    storage.setTheme(
      newThemeEnum,
    );
  }
}
