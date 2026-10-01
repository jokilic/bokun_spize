import 'package:flutter/material.dart';

import '../screens/account/account_controller.dart';

ThemeMode getThemeModeFromEnum({
  required ThemeEnum themeEnum,
}) => switch (themeEnum) {
  ThemeEnum.light => ThemeMode.light,
  ThemeEnum.dark => ThemeMode.dark,
  ThemeEnum.system => ThemeMode.system,
};
