import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_style.dart';
import 'theme.dart';

extension BokunSpizeThemeExtension on ThemeData {
  BokunSpizeColorsExtension get bokunSpizeColors =>
      extension<BokunSpizeColorsExtension>() ??
      BokunSpizeTheme.getLightAppColors(
        primaryColor: BokunSpizeColors.primaryLight,
      );
  BokunSpizeTextThemesExtension get bokunSpizeTextStyles =>
      extension<BokunSpizeTextThemesExtension>() ??
      BokunSpizeTheme.getLightTextTheme(
        primaryColor: BokunSpizeColors.primaryLight,
      );
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);
  BokunSpizeColorsExtension get colors => theme.bokunSpizeColors;
  BokunSpizeTextThemesExtension get textStyles => theme.bokunSpizeTextStyles;
}

BokunSpizeTextThemesExtension getTextThemesExtension({
  required BokunSpizeColorsExtension colorsExtension,
}) => BokunSpizeTextThemesExtension(
  button: BokunSpizeTextStyles.button.copyWith(
    color: colorsExtension.text,
  ),
  textField: BokunSpizeTextStyles.textField.copyWith(
    color: colorsExtension.text,
  ),
  appBarTitleSmall: BokunSpizeTextStyles.appBarTitleSmall.copyWith(
    color: colorsExtension.text,
  ),
  appBarTitleBig: BokunSpizeTextStyles.appBarTitleBig.copyWith(
    color: colorsExtension.text,
  ),
  appBarSubtitleBig: BokunSpizeTextStyles.appBarSubtitleBig.copyWith(
    color: colorsExtension.text,
  ),
  homeTitle: BokunSpizeTextStyles.homeTitle.copyWith(
    color: colorsExtension.text,
  ),
  homeTitleBold: BokunSpizeTextStyles.homeTitleBold.copyWith(
    color: colorsExtension.text,
  ),
  homeMealTitle: BokunSpizeTextStyles.homeMealTitle.copyWith(
    color: colorsExtension.text,
  ),
  homeMealTime: BokunSpizeTextStyles.homeMealTime.copyWith(
    color: colorsExtension.text,
  ),
  homeMealNote: BokunSpizeTextStyles.homeMealNote.copyWith(
    color: colorsExtension.text,
  ),
  homeMealKcal: BokunSpizeTextStyles.homeMealKcal.copyWith(
    color: colorsExtension.text,
  ),
  homeDayKcal: BokunSpizeTextStyles.homeDayKcal.copyWith(
    color: colorsExtension.text,
  ),
  homeMealValue: BokunSpizeTextStyles.homeMealValue.copyWith(
    color: colorsExtension.text,
  ),
);
