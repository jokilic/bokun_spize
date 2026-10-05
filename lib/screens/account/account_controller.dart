import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/contact_message/contact_message.dart';
import '../../services/firebase_service.dart';
import '../../services/theme_service.dart';
import '../../util/app_version.dart';
import '../../util/device_info.dart';
import '../../util/theme.dart';
import '../../util/typedefs.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import 'sheets/account_delete_sheet.dart';
import 'sheets/account_name_sheet.dart';
import 'sheets/contact_sheet.dart';
import 'sheets/language_sheet.dart';
import 'sheets/theme_sheet.dart';
import 'sheets/user_metrics_sheet.dart';

enum ThemeEnum {
  light,
  dark,
  system,
}

class AccountController extends ValueNotifier<SettingsValues> {
  ///
  /// CONSTRUCTOR
  ///

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

  /// Opens [AccountNameSheet]
  Future<void> onEditNamePressed(
    BuildContext context, {
    required String? initialName,
  }) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => AccountNameSheet(
      initialName: initialName,
      onSavePressed: (newName) {
        if (newName.isEmpty || newName == initialName) {
          return;
        }

        HapticFeedback.lightImpact();
        firebase.updateUserName(
          newName: newName,
        );
      },
    ),
  );

  /// Opens [UserMetricsSheet]
  Future<void> openUserMetricsSheet(BuildContext context) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (context) => UserMetricsSheet(),
  );

  /// Opens [ThemeSheet]
  Future<void> openThemeSheet(
    BuildContext context, {
    required ThemeEnum initialTheme,
  }) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (context) => ThemeSheet(
      showConfirmButton: false,
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

  /// Opens [LanguageSheet]
  Future<void> openLanguageSheet(
    BuildContext context, {
    required Locale initialLanguage,
  }) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => LanguageSheet(
      showConfirmButton: false,
      initialLanguage: initialLanguage,
      onLanguageChanged: context.setLocale,
    ),
  );

  /// Opens [ContactSheet]
  Future<void> openContactSheet(BuildContext context) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => ContactSheet(
      onSendPressed: (message) async {
        unawaited(
          HapticFeedback.lightImpact(),
        );

        final userUid = firebase.userUid ?? '--';
        final userEmail = firebase.userEmail ?? '--';

        final createdAt = DateTime.now();
        final metadata = await Future.wait<String?>([
          getAppVersion(),
          getDeviceInfo(),
        ]);

        final contactMessage = ContactMessage(
          message: message,
          userUid: userUid,
          userEmail: userEmail,
          appVersion: metadata[0] ?? '--',
          platformData: metadata[1] ?? '--',
          createdAt: createdAt,
        );

        await firebase.writeContactMessage(
          contactMessage: contactMessage,
        );
      },
    ),
  );

  /// Opens [DeleteAccountSheet]
  Future<void> openDeleteAccountSheet(
    BuildContext context, {
    required bool requiresPassword,
    required Function(bool isDeleted) onHandleDelete,
  }) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => AccountDeleteSheet(
      deleteWord: 'accountDeleteSheetWord'.tr(),
      requiresPassword: requiresPassword,
      onDeletePressed: (password) async {
        unawaited(
          HapticFeedback.lightImpact(),
        );

        final isDeleted = await firebase.deleteUser(
          email: firebase.userEmail,
          password: password,
        );

        onHandleDelete(isDeleted);
      },
    ),
  );

  /// Updates `state`
  void updateState({
    ThemeEnum? theme,
  }) => value = (
    theme: theme ?? value.theme,
  );
}
