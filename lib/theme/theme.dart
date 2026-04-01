import 'package:flutter/material.dart';

import 'colors.dart';
import 'extensions.dart';
import 'text_style.dart';

class BokunSpizeTheme {
  ///
  /// LIGHT
  ///

  static ThemeData light({
    required Color? primaryColor,
  }) {
    final defaultTheme = ThemeData.light(
      useMaterial3: true,
    );

    final lightAppColors = getLightAppColors(
      primaryColor: primaryColor,
    );

    final lightTextTheme = getLightTextTheme(
      primaryColor: primaryColor,
    );

    return defaultTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor ?? lightAppColors.buttonPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            primaryColor ?? lightAppColors.buttonPrimary,
          ),
          foregroundColor: WidgetStateProperty.all(
            lightAppColors.buttonBackground,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            lightTextTheme.button,
          ),
        ),
      ),
      splashColor: Colors.transparent,
      highlightColor: lightAppColors.buttonBackground,
      scaffoldBackgroundColor: lightAppColors.scaffoldBackground,
      canvasColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: primaryColor ?? lightAppColors.buttonPrimary,
        cursorColor: primaryColor ?? lightAppColors.buttonPrimary,
        selectionHandleColor: primaryColor ?? lightAppColors.buttonPrimary,
      ),
      extensions: [
        lightAppColors,
        lightTextTheme,
      ],
    );
  }

  static BokunSpizeColorsExtension getLightAppColors({
    required Color? primaryColor,
  }) => BokunSpizeColorsExtension(
    text: BokunSpizeColors.lightThemeText,
    buttonPrimary: primaryColor ?? BokunSpizeColors.primaryLight,
    delete: BokunSpizeColors.red,
    protein: BokunSpizeColors.blue,
    carbs: BokunSpizeColors.orange,
    fat: BokunSpizeColors.purple,
    listTileBackground: BokunSpizeColors.lightThemeBackground,
    buttonBackground: BokunSpizeColors.lightThemeBackground,
    scaffoldBackground: BokunSpizeColors.lightThemeScaffold,
    disabledText: BokunSpizeColors.lightThemeText,
    disabledBackground: BokunSpizeColors.lightThemeBackground,
  );

  static BokunSpizeTextThemesExtension getLightTextTheme({
    required Color? primaryColor,
  }) => getTextThemesExtension(
    colorsExtension: getLightAppColors(
      primaryColor: primaryColor,
    ),
  );

  ///
  /// DARK
  ///

  static ThemeData dark({
    required Color? primaryColor,
  }) {
    final defaultTheme = ThemeData.dark(
      useMaterial3: true,
    );

    final darkAppColors = getDarkAppColors(
      primaryColor: primaryColor,
    );

    final darkTextTheme = getDarkTextTheme(
      primaryColor: primaryColor,
    );

    return defaultTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor ?? darkAppColors.buttonPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            primaryColor ?? darkAppColors.buttonPrimary,
          ),
          foregroundColor: WidgetStateProperty.all(
            darkAppColors.buttonBackground,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            darkTextTheme.button,
          ),
        ),
      ),
      splashColor: Colors.transparent,
      highlightColor: darkAppColors.buttonBackground,
      scaffoldBackgroundColor: darkAppColors.scaffoldBackground,
      canvasColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: primaryColor ?? darkAppColors.buttonPrimary,
        cursorColor: primaryColor ?? darkAppColors.buttonPrimary,
        selectionHandleColor: primaryColor ?? darkAppColors.buttonPrimary,
      ),
      extensions: [
        darkAppColors,
        darkTextTheme,
      ],
    );
  }

  static BokunSpizeColorsExtension getDarkAppColors({
    required Color? primaryColor,
  }) => BokunSpizeColorsExtension(
    text: BokunSpizeColors.darkThemeText,
    buttonPrimary: primaryColor ?? BokunSpizeColors.primaryDark,
    delete: BokunSpizeColors.red,
    protein: BokunSpizeColors.blue,
    carbs: BokunSpizeColors.orange,
    fat: BokunSpizeColors.purple,
    listTileBackground: BokunSpizeColors.darkThemeBackground,
    buttonBackground: BokunSpizeColors.darkThemeBackground,
    scaffoldBackground: BokunSpizeColors.darkThemeScaffold,
    disabledText: BokunSpizeColors.darkThemeText,
    disabledBackground: BokunSpizeColors.darkThemeBackground,
  );

  static BokunSpizeTextThemesExtension getDarkTextTheme({
    required Color? primaryColor,
  }) => getTextThemesExtension(
    colorsExtension: getDarkAppColors(
      primaryColor: primaryColor,
    ),
  );
}
