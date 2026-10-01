import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';
import '../../services/theme_service.dart';
import '../../util/theme.dart';
import '../../util/typedefs.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import 'widgets/language_sheet.dart';
import 'widgets/theme_sheet.dart';
import 'widgets/user_metrics_sheet.dart';

enum ThemeEnum {
  light,
  dark,
  system,
}

class AccountController extends ValueNotifier<SettingsValues> {
  ///
  /// CONSTRUCTOR
  ///

  // TODO: Firebase perhaps not necessary
  final FirebaseService firebase;
  final ThemeService theme;

  AccountController({
    required this.firebase,
    required this.theme,
  }) : super((
         theme: getThemeEnumFromMode(
           themeMode: theme.value,
         ),
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
  Future<void> openThemeSheet(
    BuildContext context, {
    required ThemeEnum initialTheme,
  }) async => showBlurredModalBottomSheet(
    context: context,
    builder: (context) => ThemeSheet(
      initialTheme: initialTheme,
      onThemeChanged: (newTheme) {
        theme.updateTheme(
          newThemeEnum: newTheme,
        );

        updateState(
          theme: newTheme,
        );
      },
    ),
  );

  /// Opens [LanguageSheet] with the active app language selected
  Future<void> openLanguageSheet(
    BuildContext context,
  ) async => showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => LanguageSheet(
      initialLanguage: context.locale,
      onLanguageChanged: (newLanguage) => context.setLocale(newLanguage),
    ),
  );

  // /// Opens [DeleteAccountSheet]
  // Future<void> openDeleteAccountSheet(BuildContext context) async => showBlurredModalBottomSheet(
  //   context: context,
  //   builder: (context) => DeleteAccountSheet(),
  // );

  /// Updates `state`
  void updateState({
    ThemeEnum? theme,
  }) => value = (
    theme: theme ?? value.theme,
  );
}
