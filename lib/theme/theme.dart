import 'package:flutter/material.dart';

import 'colors.dart';

// TODO: Implement commented out text themes

class BokunSpizeTheme {
  ///
  /// LIGHT
  ///

  static ThemeData light() {
    final defaultTheme = ThemeData.light(
      useMaterial3: true,
    );

    final lightAppColors = getLightAppColors();

    // final lightTextTheme = getLightTextTheme();

    return defaultTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightAppColors.protein,
      ),
      scaffoldBackgroundColor: lightAppColors.scaffoldBackground,
      highlightColor: lightAppColors.listTileBackground.withValues(alpha: 0.5),
      shadowColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: lightAppColors.protein,
        cursorColor: lightAppColors.protein,
        selectionHandleColor: lightAppColors.protein,
      ),
      extensions: [
        lightAppColors,
        // lightTextTheme,
      ],
    );
  }

  static BokunSpizeColorsExtension getLightAppColors() => BokunSpizeColorsExtension(
    scaffoldBackground: BokunSpizeColors.lightThemeScaffold,
    listTileBackground: BokunSpizeColors.lightThemeBackground,
    text: BokunSpizeColors.lightThemeText,
    buttonText: BokunSpizeColors.lightThemeBackground,
    delete: BokunSpizeColors.red,
    protein: BokunSpizeColors.green,
    carbs: BokunSpizeColors.blue,
    fat: BokunSpizeColors.bordeaux,
  );

  // static BokunSpizeTextThemesExtension getLightTextTheme() => getTextThemesExtension(
  //   colorsExtension: getLightAppColors(),
  // );

  ///
  /// DARK
  ///

  static ThemeData dark() {
    final defaultTheme = ThemeData.dark(
      useMaterial3: true,
    );

    final darkAppColors = getDarkAppColors();

    // final darkTextTheme = getDarkTextTheme();

    return defaultTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkAppColors.protein,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkAppColors.scaffoldBackground,
      highlightColor: darkAppColors.listTileBackground.withValues(alpha: 0.5),
      shadowColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: darkAppColors.protein,
        cursorColor: darkAppColors.protein,
        selectionHandleColor: darkAppColors.protein,
      ),
      extensions: [
        darkAppColors,
        // darkTextTheme,
      ],
    );
  }

  static BokunSpizeColorsExtension getDarkAppColors() => BokunSpizeColorsExtension(
    scaffoldBackground: BokunSpizeColors.darkThemeScaffold,
    listTileBackground: BokunSpizeColors.darkThemeBackground,
    text: BokunSpizeColors.darkThemeText,
    buttonText: BokunSpizeColors.darkThemeText,
    delete: BokunSpizeColors.red,
    protein: BokunSpizeColors.green,
    carbs: BokunSpizeColors.blue,
    fat: BokunSpizeColors.bordeaux,
  );

  // static BokunSpizeTextThemesExtension getDarkTextTheme() => getTextThemesExtension(
  //   colorsExtension: getDarkAppColors(),
  // );
}
