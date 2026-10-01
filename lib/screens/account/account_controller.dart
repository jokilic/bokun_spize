import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import 'widgets/theme/theme_sheet.dart';
import 'widgets/user_metrics_sheet.dart';

enum LanguageEnum {
  en,
  hr,
}

enum ThemeEnum {
  light,
  dark,
  system,
}

class AccountController extends ValueNotifier<({ThemeEnum theme, LanguageEnum language})> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  AccountController({
    required this.firebase,
  }) : super((
         theme: ThemeEnum.system,
         language: LanguageEnum.en,
       ));

  ///
  /// METHODS
  ///

  /// Opens [UserMetricsSheet]
  Future<void> openUserMetricsSheet(BuildContext context) async => showBlurredModalBottomSheet(
    context: context,
    builder: (context) => UserMetricsSheet(),
  );

  /// Opens [ThemeSheet]
  Future<void> openThemeSheet(BuildContext context) async => showBlurredModalBottomSheet(
    context: context,
    builder: (context) => ThemeSheet(
      // TODO: Get proper active ThemeEnum here, depending on current theme in main.dart (system, light or dark)
      initialTheme: ThemeEnum.system,
      onThemeChanged: (newTheme) {},
    ),
  );

  // /// Opens [LanguageSheet]
  // Future<void> openLanguageSheet(BuildContext context) async => showBlurredModalBottomSheet(
  //   context: context,
  //   builder: (context) => LanguageSheet(),
  // );

  // /// Opens [DeleteAccountSheet]
  // Future<void> openDeleteAccountSheet(BuildContext context) async => showBlurredModalBottomSheet(
  //   context: context,
  //   builder: (context) => DeleteAccountSheet(),
  // );

  /// Updates `state`
  void updateState({
    ThemeEnum? theme,
    LanguageEnum? language,
  }) => value = (
    theme: theme ?? value.theme,
    language: language ?? value.language,
  );
}
