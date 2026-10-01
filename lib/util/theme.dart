import 'package:flutter/material.dart';

import '../screens/account/account_controller.dart';

ThemeMode getThemeModeFromEnum({
  required ThemeEnum themeEnum,
}) => switch (themeEnum) {
  ThemeEnum.light => ThemeMode.light,
  ThemeEnum.dark => ThemeMode.dark,
  ThemeEnum.system => ThemeMode.system,
};

ThemeEnum getThemeEnumFromMode({
  required ThemeMode themeMode,
}) => switch (themeMode) {
  ThemeMode.system => ThemeEnum.system,
  ThemeMode.light => ThemeEnum.light,
  ThemeMode.dark => ThemeEnum.dark,
};
