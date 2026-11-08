import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:uuid/uuid.dart';

import '../../models/contact_message/contact_message.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/extensions.dart';
import '../../util/app_version.dart';
import '../../util/device_info.dart';
import '../../util/snackbars.dart';
import '../../util/theme.dart';
import '../../util/typedefs.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import 'sheets/account_delete_sheet.dart';
import 'sheets/account_name_sheet.dart';
import 'sheets/contact_sheet.dart';
import 'sheets/language_sheet.dart';
import 'sheets/macro_goals/macro_goals_sheet.dart';
import 'sheets/messages/messages_sheet.dart';
import 'sheets/theme_sheet.dart';
import 'sheets/user_metrics/user_metrics_sheet.dart';

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
  Future<void> openUserMetricsSheet(
    BuildContext context, {
    required UserMetrics userMetrics,
    required WeightTrack? lastWeightTrack,
  }) async {
    final userMetricsExist = userMetrics.age != null && userMetrics.height != null && userMetrics.weight != null && userMetrics.gender != null;

    final updatedUserMetrics = await showBlurredModalBottomSheet<UserMetrics>(
      context: context,
      builder: (context) => UserMetricsSheet(
        passedUserMetrics: userMetrics,
        lastWeightTrack: lastWeightTrack,
        userMetricsExist: userMetricsExist,
        onSavePressed: ({required newAge, required newGender, required newHeight, required newWeight}) async {
          /// Calculate `UserMetrics` with new values
          final newUserMetrics = userMetrics.copyWith(
            age: newAge,
            gender: newGender,
            height: newHeight,
            weight: newWeight,
          );

          /// Trigger updating in [Firebase]
          final success = await firebase.updateUserMetrics(
            newUserMetrics: newUserMetrics,
          );

          return success ? newUserMetrics : null;
        },
        onDeletePressed: () => firebase.deleteUserMetrics(
          onlyMetricsAndMacros: true,
          onlyMacros: false,
        ),
      ),
    );

    if (updatedUserMetrics == null || !context.mounted) {
      return;
    }

    /// Updating was successful, open [MacroGoalsSheet] with proper `UserMetrics`
    openMacroGoalsSheet(
      context,
      userMetrics: updatedUserMetrics,
      useExistingMacroGoals: false,
    );
  }

  /// Opens [MacroGoalsSheet] with saved or calculated daily goals
  void openMacroGoalsSheet(
    BuildContext context, {
    required UserMetrics userMetrics,
    bool useExistingMacroGoals = true,
  }) {
    final dailyMacroValues = userMetrics.calculateDailyMacroValues(
      useExistingMacroGoals ? userMetrics.dailyCalories : null,
    );

    if (dailyMacroValues == null) {
      return;
    }

    final macroGoalsExist =
        useExistingMacroGoals && userMetrics.dailyCalories != null && userMetrics.dailyProtein != null && userMetrics.dailyCarbs != null && userMetrics.dailyFat != null;

    showBlurredModalBottomSheet(
      context: context,
      builder: (context) => MacroGoalsSheet(
        activeColor: userMetrics.gender == Gender.female ? context.colors.fat : context.colors.carbs,
        bmr: userMetrics.bmr ?? 0,
        initialDailyMacroValues: dailyMacroValues,
        calculateDailyMacroValues: userMetrics.calculateDailyMacroValues,
        macroGoalsExist: macroGoalsExist,
        onSavePressed: (dailyMacroValues) => firebase.updateUserMetrics(
          newUserMetrics: userMetrics.copyWith(
            dailyCalories: dailyMacroValues.calories,
            dailyProtein: dailyMacroValues.protein,
            dailyCarbs: dailyMacroValues.carbs,
            dailyFat: dailyMacroValues.fat,
          ),
        ),
        onDeletePressed: () => firebase.deleteUserMetrics(
          onlyMetricsAndMacros: false,
          onlyMacros: true,
        ),
      ),
    );
  }

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

  /// Opens [NotificationsSheet]
  Future<void> openNotificationsSheet(BuildContext context) async {}

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
          id: const Uuid().v1(),
          message: message,
          userUid: userUid,
          userEmail: userEmail,
          appVersion: metadata[0] ?? '--',
          platform: metadata[1] ?? '--',
          createdAt: createdAt,
        );

        final success = await firebase.writeContactMessage(
          contactMessage: contactMessage,
        );

        if (!context.mounted) {
          return;
        }

        showSnackbar(
          context,
          text: success ? 'accountContactSendSuccess'.tr() : 'accountContactSendFailure'.tr(),
          icon: success ? PhosphorIconsBold.checkCircle : PhosphorIconsBold.warningOctagon,
        );
      },
    ),
  );

  /// Opens [MessagesSheet]
  Future<void> openMessagesSheet(BuildContext context) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => MessagesSheet(),
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
