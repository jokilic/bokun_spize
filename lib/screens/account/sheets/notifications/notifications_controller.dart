import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart' hide NotificationSettings;
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../models/notification/notification_settings.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/analytics.dart';
import '../../../../util/date_time.dart';
import '../../../../util/null_state.dart';
import '../../../../util/snackbars.dart';
import '../../../../widgets/blurred_modal_bottom_sheet.dart';
import '../../../../widgets/time_sheet.dart';

class NotificationsController
    extends
        ValueNotifier<
          ({
            NotificationSettings? settings,
            AuthorizationStatus? permissionStatus,
            bool isLoading,
            bool isSaving,
            bool isUpdatingPermission,
            String? error,
          })
        >
    with WidgetsBindingObserver
    implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;
  final NotificationService notification;
  final Locale locale;
  final Future<void> Function() onHistoryPressed;

  NotificationsController({
    required this.firebase,
    required this.notification,
    required this.locale,
    required this.onHistoryPressed,
  }) : super((
         settings: null,
         permissionStatus: null,
         isLoading: false,
         isSaving: false,
         isUpdatingPermission: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  /// Starts lifecycle observation and initial loading
  void init() {
    WidgetsBinding.instance.addObserver(this);
    loadInitialData();
  }

  /// Refreshes permission after returning from operating-system settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshPermission();
    }
  }

  ///
  /// DISPOSE
  ///

  /// Stops publishing async results after the sheet is dismissed
  @override
  void onDispose() {
    isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  var isDisposed = false;

  ///
  /// GETTERS
  ///

  /// Reports whether the operating system can deliver notifications
  bool get permissionGranted => switch (value.permissionStatus) {
    AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
    AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently || AuthorizationStatus.notDetermined || null => false,
  };

  /// Returns localized text for the current operating-system permission
  String get permissionStatusText => switch (value.permissionStatus) {
    AuthorizationStatus.authorized => 'notificationsPermissionAuthorized'.tr(),
    AuthorizationStatus.provisional => 'notificationsPermissionProvisional'.tr(),
    AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently => 'notificationsPermissionDenied'.tr(),
    AuthorizationStatus.notDetermined || null => 'notificationsPermissionNotDetermined'.tr(),
  };

  ///
  /// METHODS
  ///

  /// Fetches settings and permission status concurrently
  Future<void> loadInitialData() async {
    if (isDisposed || value.isLoading) {
      return;
    }

    updateState(
      isLoading: true,
      error: null,
    );

    try {
      final results = await Future.wait<Object>([
        firebase.getAndRefreshNotificationSettings(
          locale: locale,
        ),
        notification.refreshPermissionStatus(),
      ]);

      if (isDisposed) {
        return;
      }

      updateState(
        settings: results[0] as NotificationSettings,
        permissionStatus: results[1] as AuthorizationStatus,
        isLoading: false,
        error: null,
      );
    } catch (error) {
      log(
        'Loading notification settings failed',
        error: error,
      );

      updateState(
        isLoading: false,
        error: 'notificationsLoadFailure'.tr(),
      );
    }
  }

  /// Optimistically updates settings and restores the previous value on failure
  Future<void> updateSettings(
    BuildContext context, {
    required NotificationSettings newSettings,
  }) async {
    final previousSettings = value.settings;

    if (isDisposed || value.isSaving || previousSettings == null) {
      return;
    }

    updateState(
      settings: newSettings,
      isSaving: true,
    );

    final success = await firebase.writeNotificationSettings(
      settings: newSettings,
    );
    if (success) {
      recordPreferenceChanges(previousSettings, newSettings);
    }

    if (isDisposed) {
      return;
    }

    updateState(
      settings: success ? newSettings : previousSettings,
      isSaving: false,
    );

    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: 'notificationsSaveFailure'.tr(),
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Records saved preference changes using fixed categories without reminder times
  void recordPreferenceChanges(NotificationSettings previous, NotificationSettings current) {
    final changes = [
      if (previous.weighReminderEnabled != current.weighReminderEnabled) (preference: 'weigh_reminder', change: current.weighReminderEnabled ? 'enabled' : 'disabled'),
      if (previous.weighReminderTime != current.weighReminderTime) (preference: 'weigh_reminder', change: 'schedule'),
      if (previous.dailySummaryEnabled != current.dailySummaryEnabled) (preference: 'daily_summary', change: current.dailySummaryEnabled ? 'enabled' : 'disabled'),
      if (previous.dailySummaryTime != current.dailySummaryTime) (preference: 'daily_summary', change: 'schedule'),
      if (previous.announcementsEnabled != current.announcementsEnabled) (preference: 'announcements', change: current.announcementsEnabled ? 'enabled' : 'disabled'),
    ];

    for (final (:preference, :change) in changes) {
      unawaited(
        firebase.analytics.record(
          AnalyticsEvent.notificationPreferenceChanged,
          parameters: {'preference': preference, 'change': change},
        ),
      );
    }
  }

  /// Requests notification permission and publishes the resulting status
  Future<void> requestPermission() async {
    if (isDisposed || value.isUpdatingPermission) {
      return;
    }

    unawaited(
      HapticFeedback.lightImpact(),
    );

    updateState(
      isUpdatingPermission: true,
    );

    final permissionStatus = await notification.requestPermission();

    if (isDisposed) {
      return;
    }

    updateState(
      permissionStatus: permissionStatus,
      isUpdatingPermission: false,
    );
  }

  /// Reads and publishes the latest operating-system permission status
  Future<void> refreshPermission() async {
    if (isDisposed || value.settings == null) {
      return;
    }

    final permissionStatus = await notification.refreshPermissionStatus();

    if (isDisposed) {
      return;
    }

    updateState(
      permissionStatus: permissionStatus,
    );
  }

  /// Opens application settings and refreshes permission afterward
  Future<void> openSettings() async {
    unawaited(
      HapticFeedback.lightImpact(),
    );
    await notification.openSystemSettings();
    await refreshPermission();
  }

  /// Opens notification history from the current sheet
  Future<void> openHistory() async {
    unawaited(
      HapticFeedback.lightImpact(),
    );
    await onHistoryPressed();
  }

  /// Handles notification permission status presses
  Future<void> handlePermissionStatusPressed() async {
    final permissionStatus = value.permissionStatus;

    if (value.isUpdatingPermission || permissionStatus == null) {
      return;
    }

    if (permissionStatus == AuthorizationStatus.notDetermined) {
      await requestPermission();
      return;
    }

    await openSettings();
  }

  /// Updates notification settings when notification permission is granted
  Future<void> handleSettingsPressed(
    BuildContext context, {
    required NotificationSettings newSettings,
  }) async {
    if (!permissionGranted) {
      await handlePermissionStatusPressed();

      if (!permissionGranted) {
        return;
      }
    }

    await updateSettings(
      context,
      newSettings: newSettings,
    );
  }

  /// Opens [TimeSheet] and updates the weigh reminder time
  Future<void> updateWeighReminderTimeViaPicker(BuildContext context) async {
    final settings = value.settings;

    if (settings == null) {
      return;
    }

    unawaited(
      HapticFeedback.lightImpact(),
    );

    await showBlurredModalBottomSheet(
      context: context,
      builder: (sheetContext) => TimeSheet(
        subtitle: 'notificationsWeighReminderTimeSubtitle'.tr(),
        primaryColor: sheetContext.colors.carbs,
        dateValue: settings.weighReminderTime,
        onTimeChanged: (newTime) => updateSettings(
          context,
          newSettings: settings.copyWith(
            weighReminderTime: DateTime(
              2020,
              1,
              1,
              newTime.hour,
              newTime.minute,
            ),
          ),
        ),
      ),
    );
  }

  /// Returns the localized weigh reminder time
  String getWeighReminderTime(BuildContext context) {
    final settings = value.settings;

    if (settings == null) {
      return '--';
    }

    return getDateString(
      date: settings.weighReminderTime,
      dateFormat: 'HH:mm',
      useTodayYesterdayTomorrow: false,
      languageCode: context.locale.languageCode,
    );
  }

  /// Opens [TimeSheet] and updates the daily summary time
  Future<void> updateDailySummaryTimeViaPicker(BuildContext context) async {
    final settings = value.settings;

    if (settings == null) {
      return;
    }

    unawaited(
      HapticFeedback.lightImpact(),
    );

    await showBlurredModalBottomSheet(
      context: context,
      builder: (sheetContext) => TimeSheet(
        subtitle: 'notificationsDailySummaryTimeSubtitle'.tr(),
        primaryColor: sheetContext.colors.protein,
        dateValue: settings.dailySummaryTime,
        onTimeChanged: (newTime) => updateSettings(
          context,
          newSettings: settings.copyWith(
            dailySummaryTime: DateTime(
              2020,
              1,
              1,
              newTime.hour,
              newTime.minute,
            ),
          ),
        ),
      ),
    );
  }

  /// Returns the localized daily summary time
  String getDailySummaryTime(BuildContext context) {
    final settings = value.settings;

    if (settings == null) {
      return '--';
    }

    return getDateString(
      date: settings.dailySummaryTime,
      dateFormat: 'HH:mm',
      useTodayYesterdayTomorrow: false,
      languageCode: context.locale.languageCode,
    );
  }

  /// Updates notifications state while preserving omitted values
  void updateState({
    NotificationSettings? settings,
    AuthorizationStatus? permissionStatus,
    bool? isLoading,
    bool? isSaving,
    bool? isUpdatingPermission,
    Object? error = nullStateNoChange,
  }) {
    if (isDisposed) {
      return;
    }

    value = (
      settings: settings ?? value.settings,
      permissionStatus: permissionStatus ?? value.permissionStatus,
      isLoading: isLoading ?? value.isLoading,
      isSaving: isSaving ?? value.isSaving,
      isUpdatingPermission: isUpdatingPermission ?? value.isUpdatingPermission,
      error: identical(error, nullStateNoChange) ? value.error : error as String?,
    );
  }
}
