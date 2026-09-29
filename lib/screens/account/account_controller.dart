import 'package:flutter/material.dart';

import '../../widgets/blurred_modal_bottom_sheet.dart';
import 'widgets/user_metrics_sheet.dart';

class AccountController {
  ///
  /// CONSTRUCTOR
  ///

  AccountController();

  ///
  /// METHODS
  ///

  /// Opens [UserMetricsSheet]
  Future<void> openUserMetricsSheet(BuildContext context) async => showBlurredModalBottomSheet(
    context: context,
    builder: (context) => UserMetricsSheet(),
  );

  /// Opens [ThemeSheet]
  // Future<void> openThemeSheet(BuildContext context) async => showBlurredModalBottomSheet(
  //   context: context,
  //   builder: (context) => ThemeSheet(),
  // );

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
}
