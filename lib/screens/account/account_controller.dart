import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:uuid/uuid.dart';

import '../../models/contact_message/contact_message.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import '../../services/notification_service.dart';
import '../../services/theme_service.dart';
import '../../theme/extensions.dart';
import '../../util/analytics.dart';
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
import 'sheets/notification_history/notification_history_sheet.dart';
import 'sheets/notifications/notifications_sheet.dart';
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
  final NotificationService notification;
  final ThemeService theme;

  AccountController({
    required this.firebase,
    required this.notification,
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
      onSavePressed: (newName) async {
        if (newName.isEmpty || newName == initialName) {
          return;
        }

        unawaited(
          HapticFeedback.lightImpact(),
        );
        final success = await firebase.updateUserName(
          newName: newName,
        );

        if (success) {
          unawaited(
            firebase.analytics.countHealthInteraction(
              HealthAnalyticsEvent.profileSettingsSaved,
            ),
          );
        }
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

          if (success) {
            unawaited(
              firebase.analytics.countHealthInteraction(
                HealthAnalyticsEvent.profileSettingsSaved,
              ),
            );
          }

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

    unawaited(
      firebase.analytics.countHealthInteraction(
        HealthAnalyticsEvent.nutritionGoalsOpened,
      ),
    );

    showBlurredModalBottomSheet(
      context: context,
      builder: (context) => MacroGoalsSheet(
        activeColor: userMetrics.gender == Gender.female ? context.colors.fat : context.colors.carbs,
        bmr: userMetrics.bmr ?? 0,
        initialDailyMacroValues: dailyMacroValues,
        calculateDailyMacroValues: userMetrics.calculateDailyMacroValues,
        macroGoalsExist: macroGoalsExist,
        onSavePressed: (dailyMacroValues) async {
          final success = await firebase.updateUserMetrics(
            newUserMetrics: userMetrics.copyWith(
              dailyCalories: dailyMacroValues.calories,
              dailyProtein: dailyMacroValues.protein,
              dailyCarbs: dailyMacroValues.carbs,
              dailyFat: dailyMacroValues.fat,
            ),
          );

          if (success) {
            unawaited(
              firebase.analytics.countHealthInteraction(
                HealthAnalyticsEvent.nutritionGoalsSaved,
              ),
            );
          }

          return success;
        },
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
        final changed = newTheme != value.theme;

        theme.updateTheme(
          newThemeEnum: newTheme,
        );

        updateState(
          theme: newTheme,
        );

        if (changed) {
          unawaited(
            firebase.analytics.record(
              AnalyticsEvent.themeChanged,
              parameters: {
                'mode': newTheme.name,
              },
            ),
          );
        }
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
      onLanguageChanged: (newLocale) async {
        final changed = newLocale != context.locale;
        await context.setLocale(newLocale);

        if (changed) {
          unawaited(
            firebase.analytics.record(
              AnalyticsEvent.languageChanged,
              parameters: {
                'language': newLocale.languageCode,
              },
            ),
          );
        }
        await firebase.getAndRefreshNotificationSettings(
          locale: newLocale,
        );
        await notification.synchronizeRegistration(
          locale: newLocale.languageCode,
        );
      },
    ),
  );

  /// Opens [NotificationsSheet]
  Future<void> openNotificationsSheet(BuildContext context) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => NotificationsSheet(
      locale: sheetContext.locale,
      onHistoryPressed: () => openNotificationHistorySheet(sheetContext),
    ),
  );

  /// Opens [ContactSheet]
  Future<void> openContactSheet(BuildContext context) async {
    unawaited(firebase.analytics.record(AnalyticsEvent.contactFormOpened));
    await showBlurredModalBottomSheet(
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

          unawaited(
            firebase.analytics.record(
              success ? AnalyticsEvent.contactMessageSent : AnalyticsEvent.contactMessageFailed,
            ),
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
  }

  /// Opens [MessagesSheet]
  Future<void> openMessagesSheet(BuildContext context) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => MessagesSheet(),
  );

  /// Opens [NotificationHistorySheet]
  Future<void> openNotificationHistorySheet(BuildContext context) async {
    unawaited(
      firebase.analytics.record(
        AnalyticsEvent.notificationHistoryOpened,
      ),
    );

    await showBlurredModalBottomSheet(
      context: context,
      builder: (sheetContext) => NotificationHistorySheet(),
    );
  }

  /// Opens [AccountDeleteSheet] and forwards confirmation after it closes
  Future<void> openDeleteAccountSheet(
    BuildContext context, {
    required bool requiresPassword,
    required Future<void> Function(String? password) onDeleteConfirmed,
  }) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => AccountDeleteSheet(
      deleteWord: 'accountDeleteSheetWord'.tr(),
      requiresPassword: requiresPassword,
      onDeleteConfirmed: onDeleteConfirmed,
    ),
  );

  /// Updates `state`
  void updateState({
    ThemeEnum? theme,
  }) => value = (
    theme: theme ?? value.theme,
  );
}
