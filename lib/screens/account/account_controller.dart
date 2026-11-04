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
    final updatedUserMetrics = await showBlurredModalBottomSheet<UserMetrics>(
      context: context,
      builder: (context) => UserMetricsSheet(
        passedUserMetrics: userMetrics,
        lastWeightTrack: lastWeightTrack,
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
          onlyBodyMetrics: true,
          onlyMacroGoals: false,
        ),
      ),
    );

    if (updatedUserMetrics == null || !context.mounted) {
      return;
    }

    /// Updating was successful, open [MacroGoalsSheet] with proper `UserMetrics`
    await openMacroGoalsSheet(
      context,
      userMetrics: updatedUserMetrics,
    );
  }

  /// Opens [MacroGoalsSheet] with saved or calculated daily goals
  Future<void> openMacroGoalsSheet(
    BuildContext context, {
    required UserMetrics userMetrics,
  }) async {
    final bmr = userMetrics.bmr ?? 0;
    final dailyCalories = userMetrics.dailyCalories ?? userMetrics.tdee ?? bmr;

    // TODO: Depending on BMR and TDEE, I want the daily macro values to be calculated on device (put logic in `user_metrics.dart`). We pass over those calculated values as initial and then the user can tweak them...

    // final dailyProtein = userMetrics.dailyProtein ?? 150;
    // final dailyCarbs = userMetrics.dailyCarbs ?? 250;
    // final dailyFat = userMetrics.dailyFat ?? 70;

    await showBlurredModalBottomSheet(
      context: context,
      builder: (context) => MacroGoalsSheet(
        activeColor: userMetrics.gender == Gender.female ? context.colors.fat : context.colors.carbs,
        bmr: bmr,
        initialDailyCalories: dailyCalories,
        initialDailyProtein: dailyProtein,
        initialDailyCarbs: dailyCarbs,
        initialDailyFat: dailyFat,
        onSavePressed: ({required dailyCalories, required dailyProtein, required dailyCarbs, required dailyFat}) => firebase.updateUserMetrics(
          newUserMetrics: userMetrics.copyWith(
            dailyCalories: dailyCalories,
            dailyProtein: dailyProtein,
            dailyCarbs: dailyCarbs,
            dailyFat: dailyFat,
          ),
        ),
        onDeletePressed: null,
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
