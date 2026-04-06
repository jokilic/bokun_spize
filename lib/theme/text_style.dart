import 'package:flutter/material.dart';

abstract class BokunSpizeTextStyles {
  static const button = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static const textField = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const appBarTitleSmall = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const appBarTitleBig = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const appBarSubtitleBig = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const homeTitle = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const homeTitleBold = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const homeMealTitle = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const homeMealTime = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const homeMealNote = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const homeMealKcal = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const homeDayKcal = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const homeMealValue = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
}

class BokunSpizeTextThemesExtension extends ThemeExtension<BokunSpizeTextThemesExtension> {
  final TextStyle button;
  final TextStyle textField;
  final TextStyle appBarTitleSmall;
  final TextStyle appBarTitleBig;
  final TextStyle appBarSubtitleBig;
  final TextStyle homeTitle;
  final TextStyle homeTitleBold;
  final TextStyle homeMealTitle;
  final TextStyle homeMealTime;
  final TextStyle homeMealNote;
  final TextStyle homeMealKcal;
  final TextStyle homeDayKcal;
  final TextStyle homeMealValue;

  const BokunSpizeTextThemesExtension({
    required this.button,
    required this.textField,
    required this.appBarTitleSmall,
    required this.appBarTitleBig,
    required this.appBarSubtitleBig,
    required this.homeTitle,
    required this.homeTitleBold,
    required this.homeMealTitle,
    required this.homeMealTime,
    required this.homeMealNote,
    required this.homeMealKcal,
    required this.homeDayKcal,
    required this.homeMealValue,
  });

  @override
  ThemeExtension<BokunSpizeTextThemesExtension> copyWith({
    TextStyle? button,
    TextStyle? textField,
    TextStyle? appBarTitleSmall,
    TextStyle? appBarTitleBig,
    TextStyle? appBarSubtitleBig,
    TextStyle? homeTitle,
    TextStyle? homeTitleBold,
    TextStyle? homeMealTitle,
    TextStyle? homeMealTime,
    TextStyle? homeMealNote,
    TextStyle? homeMealKcal,
    TextStyle? homeDayKcal,
    TextStyle? homeMealValue,
  }) => BokunSpizeTextThemesExtension(
    button: button ?? this.button,
    textField: textField ?? this.textField,
    appBarTitleSmall: appBarTitleSmall ?? this.appBarTitleSmall,
    appBarTitleBig: appBarTitleBig ?? this.appBarTitleBig,
    appBarSubtitleBig: appBarSubtitleBig ?? this.appBarSubtitleBig,
    homeTitle: homeTitle ?? this.homeTitle,
    homeTitleBold: homeTitleBold ?? this.homeTitleBold,
    homeMealTitle: homeMealTitle ?? this.homeMealTitle,
    homeMealTime: homeMealTime ?? this.homeMealTime,
    homeMealNote: homeMealNote ?? this.homeMealNote,
    homeMealKcal: homeMealKcal ?? this.homeMealKcal,
    homeDayKcal: homeDayKcal ?? this.homeDayKcal,
    homeMealValue: homeMealValue ?? this.homeMealValue,
  );

  @override
  ThemeExtension<BokunSpizeTextThemesExtension> lerp(
    covariant ThemeExtension<BokunSpizeTextThemesExtension>? other,
    double t,
  ) {
    if (other is! BokunSpizeTextThemesExtension) {
      return this;
    }

    return BokunSpizeTextThemesExtension(
      button: TextStyle.lerp(button, other.button, t)!,
      textField: TextStyle.lerp(textField, other.textField, t)!,
      appBarTitleSmall: TextStyle.lerp(appBarTitleSmall, other.appBarTitleSmall, t)!,
      appBarTitleBig: TextStyle.lerp(appBarTitleBig, other.appBarTitleBig, t)!,
      appBarSubtitleBig: TextStyle.lerp(appBarSubtitleBig, other.appBarSubtitleBig, t)!,
      homeTitle: TextStyle.lerp(homeTitle, other.homeTitle, t)!,
      homeTitleBold: TextStyle.lerp(homeTitleBold, other.homeTitleBold, t)!,
      homeMealTitle: TextStyle.lerp(homeMealTitle, other.homeMealTitle, t)!,
      homeMealTime: TextStyle.lerp(homeMealTime, other.homeMealTime, t)!,
      homeMealNote: TextStyle.lerp(homeMealNote, other.homeMealNote, t)!,
      homeMealKcal: TextStyle.lerp(homeMealKcal, other.homeMealKcal, t)!,
      homeDayKcal: TextStyle.lerp(homeDayKcal, other.homeDayKcal, t)!,
      homeMealValue: TextStyle.lerp(homeMealValue, other.homeMealValue, t)!,
    );
  }
}
