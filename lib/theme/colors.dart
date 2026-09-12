import 'package:flutter/material.dart';

abstract class BokunSpizeColors {
  ///
  /// LIGHT THEME
  ///

  static const lightThemeText = Color(0xFF121412);
  static const lightThemeBackground = Color(0xFFEBECED);
  static const lightThemeScaffold = Color(0xFFDBDEE1);

  ///
  /// DARK THEME
  ///

  static const darkThemeText = Color(0xFFFFFFFF);
  static const darkThemeBackground = Color(0xFF2A2C42);
  static const darkThemeScaffold = Color(0xFF181825);

  ///
  /// PRIMARY COLORS
  ///

  static const green = Color(0xFF3B7D5E);
  static const blue = Color(0xFF4F5094);
  static const bordeaux = Color(0xFF885A89);
  static const red = Color(0xFF9D5C63);
}

class BokunSpizeColorsExtension extends ThemeExtension<BokunSpizeColorsExtension> {
  final Color scaffoldBackground;
  final Color listTileBackground;
  final Color text;
  final Color buttonText;
  final Color delete;
  final Color protein;
  final Color carbs;
  final Color fat;

  BokunSpizeColorsExtension({
    required this.scaffoldBackground,
    required this.listTileBackground,
    required this.text,
    required this.buttonText,
    required this.delete,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  ThemeExtension<BokunSpizeColorsExtension> copyWith({
    Color? scaffoldBackground,
    Color? listTileBackground,
    Color? text,
    Color? buttonText,
    Color? delete,
    Color? protein,
    Color? carbs,
    Color? fat,
  }) => BokunSpizeColorsExtension(
    scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
    listTileBackground: listTileBackground ?? this.listTileBackground,
    text: text ?? this.text,
    buttonText: buttonText ?? this.buttonText,
    delete: delete ?? this.delete,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
  );

  @override
  ThemeExtension<BokunSpizeColorsExtension> lerp(
    covariant ThemeExtension<BokunSpizeColorsExtension>? other,
    double t,
  ) {
    if (other is! BokunSpizeColorsExtension) {
      return this;
    }

    return BokunSpizeColorsExtension(
      scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      listTileBackground: Color.lerp(listTileBackground, other.listTileBackground, t)!,
      text: Color.lerp(text, other.text, t)!,
      buttonText: Color.lerp(buttonText, other.buttonText, t)!,
      delete: Color.lerp(delete, other.delete, t)!,
      protein: Color.lerp(protein, other.protein, t)!,
      carbs: Color.lerp(carbs, other.carbs, t)!,
      fat: Color.lerp(fat, other.fat, t)!,
    );
  }
}
