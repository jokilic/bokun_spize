import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import 'widgets/theme/theme_sheet.dart';
import 'widgets/user_metrics_sheet.dart';

enum Language {
  en,
  hr,
}

enum Theme {
  light,
  dark,
  system,
}

class AccountController extends ValueNotifier<({Theme theme, Language language})> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  AccountController({
    required this.firebase,
  }) : super((
         theme: Theme.light,
         language: Language.en,
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
      initialTheme: ThemeData.dark(),
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
    Theme? theme,
    Language? language,
  }) => value = (
    theme: theme ?? value.theme,
    language: language ?? value.language,
  );
}
