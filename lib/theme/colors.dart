import 'package:flutter/material.dart';

abstract class BokunSpizeColors {
  ///
  /// LIGHT THEME
  ///

  static const black = Color(0xFF121C2B);
  static const whiteBackground = Color(0xFFF9F9FF);
  static const buttonBackground = Color(0xFFE4E6ED);
  static const whiteScaffold = Color(0xFFEDEDF4);
  static const disabledText = Color(0xFF2D2F34);
  static const disabledBackground = Color(0xFFE4E6ED);

  ///
  /// PRIMARY COLORS
  ///

  static const green = Color(0xFF7CA982);
  static const red = Color(0xFFE0777D);
}

class BokunSpizeColorsExtension extends ThemeExtension<BokunSpizeColorsExtension> {
  final Color text;
  final Color buttonPrimary;
  final Color delete;
  final Color listTileBackground;
  final Color buttonBackground;
  final Color scaffoldBackground;
  final Color disabledText;
  final Color disabledBackground;

  BokunSpizeColorsExtension({
    required this.text,
    required this.buttonPrimary,
    required this.delete,
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
      listTileBackground: Color.lerp(listTileBackground, other.listTileBackground, t)!,
      buttonBackground: Color.lerp(buttonBackground, other.buttonBackground, t)!,
      scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      disabledBackground: Color.lerp(disabledBackground, other.disabledBackground, t)!,
    );
  }
}
