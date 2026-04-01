import 'package:flutter/material.dart';

abstract class BokunSpizeColors {
  ///
  /// LIGHT THEME
  ///

  static const lightThemeText = Color(0xFF171717);
  static const lightThemeBackground = Color(0xFFE8E8E8);
  static const lightThemeScaffold = Color(0xFFDADADA);

  ///
  /// DARK THEME
  ///

  static const darkThemeText = Color(0xFFFFFFFF);
  static const darkThemeBackground = Color(0xFF262837);
  static const darkThemeScaffold = Color(0xFF1F1D2C);

  ///
  /// PRIMARY COLORS
  ///

  static const primaryLight = green;
  static const primaryDark = darkPurple;

  static const green = Color(0xFF499F68);
  static const red = Color(0xFFEE6055);
  static const blue = Color(0xFF3DA5D9);
  static const orange = Color(0xFFDE9151);
  static const purple = Color(0xFFCBBAED);
  static const darkPurple = Color(0xFF4F5094);
}

class BokunSpizeColorsExtension extends ThemeExtension<BokunSpizeColorsExtension> {
  final Color text;
  final Color buttonPrimary;
  final Color delete;
  final Color protein;
  final Color carbs;
  final Color fat;
  final Color listTileBackground;
  final Color buttonBackground;
  final Color scaffoldBackground;
  final Color disabledText;
  final Color disabledBackground;

  BokunSpizeColorsExtension({
    required this.text,
    required this.buttonPrimary,
    required this.delete,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.listTileBackground,
    required this.buttonBackground,
    required this.scaffoldBackground,
    required this.disabledText,
    required this.disabledBackground,
  });

  @override
  ThemeExtension<BokunSpizeColorsExtension> copyWith({
    Color? text,
    Color? buttonPrimary,
    Color? delete,
    Color? protein,
    Color? carbs,
    Color? fat,
    Color? listTileBackground,
    Color? buttonBackground,
    Color? filledButtonBackground,
    Color? scaffoldBackground,
    Color? disabledText,
    Color? disabledBackground,
  }) => BokunSpizeColorsExtension(
    text: text ?? this.text,
    buttonPrimary: buttonPrimary ?? this.buttonPrimary,
    delete: delete ?? this.delete,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    listTileBackground: listTileBackground ?? this.listTileBackground,
    buttonBackground: buttonBackground ?? this.buttonBackground,
    scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
    disabledText: disabledText ?? this.disabledText,
    disabledBackground: disabledBackground ?? this.disabledBackground,
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
      text: Color.lerp(text, other.text, t)!,
      buttonPrimary: Color.lerp(buttonPrimary, other.buttonPrimary, t)!,
      delete: Color.lerp(delete, other.delete, t)!,
      protein: Color.lerp(protein, other.protein, t)!,
      carbs: Color.lerp(carbs, other.carbs, t)!,
      fat: Color.lerp(fat, other.fat, t)!,
      listTileBackground: Color.lerp(listTileBackground, other.listTileBackground, t)!,
      buttonBackground: Color.lerp(buttonBackground, other.buttonBackground, t)!,
      scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      disabledBackground: Color.lerp(disabledBackground, other.disabledBackground, t)!,
    );
  }
}
