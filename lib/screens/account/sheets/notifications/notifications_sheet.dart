import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart' hide NotificationSettings;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../models/notification/notification_settings.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/date_time.dart';
import '../../../../util/dependencies.dart';
import '../../../../util/snackbars.dart';
import '../../../../util/spacing.dart';
import '../../../../widgets/blurred_modal_bottom_sheet.dart';
import '../../../../widgets/time_sheet.dart';
import 'notifications_controller.dart';
import 'notifications_sheet_list_tile.dart';

class NotificationsSheet extends WatchingStatefulWidget {
  final Locale locale;
  final Future<void> Function() onHistoryPressed;

  const NotificationsSheet({
    required this.locale,
    required this.onHistoryPressed,
  });

  @override
  State<NotificationsSheet> createState() => NotificationsSheetState();
}

class NotificationsSheetState extends State<NotificationsSheet> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<NotificationsController>(
      () => NotificationsController(
        firebase: getIt.get<FirebaseService>(),
        notification: getIt.get<NotificationService>(),
        locale: widget.locale,
      ),
      afterRegister: (controller) => controller.init(),
    );

    /// Observes app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    /// Stops observing app lifecycle changes
    WidgetsBinding.instance.removeObserver(this);
    unRegisterIfNotDisposed<NotificationsController>();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// Refreshes permission after returning from operating-system settings
    if (state == AppLifecycleState.resumed) {
      refreshPermission();
    }
  }

  /// Returns the controller registered for the active sheet
  NotificationsController get notificationsController => getIt.get<NotificationsController>();

  /// Reports whether the operating system can currently deliver notifications
  bool get permissionGranted => notificationsController.permissionGranted;

  /// Returns localized text for the current operating-system permission
  String get permissionStatusText => switch (notificationsController.value.permissionStatus) {
    AuthorizationStatus.authorized => 'notificationsPermissionAuthorized'.tr(),
    AuthorizationStatus.provisional => 'notificationsPermissionProvisional'.tr(),
    AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently => 'notificationsPermissionDenied'.tr(),
    AuthorizationStatus.notDetermined || null => 'notificationsPermissionNotDetermined'.tr(),
  };

  /// Show optimistic preference update and restore previous value if update fails
  Future<void> updateSettings(NotificationSettings newSettings) async {
    if (notificationsController.value.isSaving) {
      return;
    }

    final success = await notificationsController.updateSettings(newSettings);

    if (!mounted) {
      return;
    }

    if (!success) {
      showSnackbar(
        context,
        text: 'notificationsSaveFailure'.tr(),
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Request notification permission from an explicit button press
  Future<void> requestPermission() async {
    if (notificationsController.value.isUpdatingPermission) {
      return;
    }

    unawaited(
      HapticFeedback.lightImpact(),
    );

    await notificationsController.requestPermission();
  }

  /// Open application settings and refresh the new permission state
  Future<void> openSettings() async {
    unawaited(
      HapticFeedback.lightImpact(),
    );
    await notificationsController.openSettings();
  }

  /// Read the latest operating-system permission state
  Future<void> refreshPermission() async => await notificationsController.refreshPermission();

  /// Handles notification permission status presses
  Future<void> handlePermissionStatusPressed() async {
    final permissionStatus = notificationsController.value.permissionStatus;

    if (notificationsController.value.isUpdatingPermission || permissionStatus == null) {
      return;
    }

    if (permissionStatus == AuthorizationStatus.notDetermined) {
      await requestPermission();
      return;
    }

    await openSettings();
  }

  /// Updates notification settings when notification permission is granted
  Future<void> handleSettingsPressed(NotificationSettings newSettings) async {
    if (!permissionGranted) {
      await handlePermissionStatusPressed();

      if (!permissionGranted) {
        return;
      }
    }

    await updateSettings(newSettings);
  }

  /// Opens [TimeSheet] and updates the weigh reminder time
  Future<void> updateWeighReminderTimeViaPicker(BuildContext context) async {
    final settings = notificationsController.value.settings;

    if (settings == null) {
      return;
    }

    await showBlurredModalBottomSheet(
      context: context,
      builder: (context) => TimeSheet(
        subtitle: 'notificationsWeighReminderTimeSubtitle'.tr(),
        primaryColor: context.colors.carbs,
        dateValue: settings.weighReminderTime,
        onTimeChanged: (newTime) => updateSettings(
          settings.copyWith(
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
    final settings = notificationsController.value.settings;

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
    final settings = notificationsController.value.settings;

    if (settings == null) {
      return;
    }

    await showBlurredModalBottomSheet(
      context: context,
      builder: (context) => TimeSheet(
        subtitle: 'notificationsDailySummaryTimeSubtitle'.tr(),
        primaryColor: context.colors.protein,
        dateValue: settings.dailySummaryTime,
        onTimeChanged: (newTime) => updateSettings(
          settings.copyWith(
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
    final settings = notificationsController.value.settings;

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

  /// Builds the sheet shell while controller data is loading or unavailable
  Widget buildInitialState(
    BuildContext context, {
    required bool isLoading,
    required String? error,
  }) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: ColoredBox(
      color: context.colors.scaffoldBackground,
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onHistoryPressed();
                    },
                    tooltip: 'notificationHistoryTitle'.tr(),
                    icon: const PhosphorIcon(
                      PhosphorIconsBold.notification,
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      foregroundColor: context.colors.text,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'notificationsTitle'.tr(),
                      style: context.textStyles.sheetTitle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: Navigator.of(context).pop,
                    icon: const PhosphorIcon(
                      PhosphorIconsBold.x,
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      foregroundColor: context.colors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Text(
                'notificationsSheetSubtitle'.tr(),
                style: context.textStyles.sheetSubtitle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator(
                        color: context.colors.account,
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhosphorIcon(
                              PhosphorIconsBold.warningOctagon,
                              color: context.colors.delete,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              error ?? 'notificationsLoadFailure'.tr(),
                              style: context.textStyles.infoCardDescription,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: notificationsController.loadInitialData,
                              icon: const PhosphorIcon(
                                PhosphorIconsBold.arrowClockwise,
                                size: 18,
                              ),
                              label: Text('tryAgain'.tr()),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: getBottomSpacing(context),
            ),
          ),
        ],
      ),
    ),
  );

  /// Selects the loading, error or loaded sheet from controller state
  @override
  Widget build(BuildContext context) {
    final state = watchIt<NotificationsController>().value;
    final settings = state.settings;
    final permissionStatus = state.permissionStatus;

    if (settings == null || permissionStatus == null) {
      return buildInitialState(
        context,
        isLoading: state.isLoading,
        error: state.error,
      );
    }

    return buildLoadedState(
      context,
      settings: settings,
      permissionStatus: permissionStatus,
      isUpdatingPermission: state.isUpdatingPermission,
    );
  }

  /// Builds notification controls after controller data is available
  Widget buildLoadedState(
    BuildContext context, {
    required NotificationSettings settings,
    required AuthorizationStatus permissionStatus,
    required bool isUpdatingPermission,
  }) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: ColoredBox(
      color: context.colors.scaffoldBackground,
      child: CustomScrollView(
        shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          ///
          /// TITLE & CLOSE BUTTON
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 10),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Row(
                  children: [
                    ///
                    /// NOTIFICATION HISTORY BUTTON
                    ///
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onHistoryPressed();
                      },
                      tooltip: 'notificationHistoryTitle'.tr(),
                      icon: const PhosphorIcon(
                        PhosphorIconsBold.notification,
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                        foregroundColor: context.colors.text,
                      ),
                    ),

                    ///
                    /// TITLE
                    ///
                    Expanded(
                      child: Text(
                        'notificationsTitle'.tr(),
                        style: context.textStyles.sheetTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    ///
                    /// CLOSE BUTTON
                    ///
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const PhosphorIcon(
                        PhosphorIconsBold.x,
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                        foregroundColor: context.colors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ///
          /// SUBTITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 2,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 8),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Text(
                  'notificationsSheetSubtitle'.tr(),
                  style: context.textStyles.sheetSubtitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),

          ///
          /// NOTIFICATION STATUS
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: marginHorizontal,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 3,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 8),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(listTileRadius),
                  child: InkWell(
                    onTap: isUpdatingPermission ? null : handlePermissionStatusPressed,
                    borderRadius: BorderRadius.circular(listTileRadius),
                    highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(listTileRadius),
                        color: context.colors.listTileBackground.withValues(alpha: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///
                          /// ICON
                          ///
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: PhosphorIcon(
                              permissionGranted ? PhosphorIconsBold.checkFat : PhosphorIconsBold.warningOctagon,
                              color: permissionGranted ? context.colors.protein : context.colors.delete,
                              size: listTileIconRadius / 2.5,
                            ),
                          ),
                          const SizedBox(width: 12),

                          ///
                          /// TEXT
                          ///
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  permissionStatusText,
                                  style: context.textStyles.infoCardTitle.copyWith(
                                    color: permissionGranted ? context.colors.protein : context.colors.delete,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  permissionGranted ? 'notificationsPermissionReady'.tr() : 'notificationsPermissionBlocked'.tr(),
                                  style: context.textStyles.infoCardDescription,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          ///
          /// RECORD YOUR WEIGHT
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: marginHorizontal,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * (permissionStatus == AuthorizationStatus.authorized ? 3 : 4),
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 18),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                  ScaleEffect(
                    begin: Offset(0.98, 0.98),
                    end: Offset(1, 1),
                    alignment: Alignment.topCenter,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: NotificationsSheetListTile(
                  onPressed: () => handleSettingsPressed(
                    settings.copyWith(
                      weighReminderEnabled: !settings.weighReminderEnabled,
                    ),
                  ),
                  isActive: settings.weighReminderEnabled,
                  color: context.colors.carbs,
                  icon: PhosphorIconsBold.personSimple,
                  title: 'notificationsWeighReminderTitle'.tr(),
                  subtitle: 'notificationsWeighReminderSubtitle'.tr(),
                  belowTextWidget: settings.weighReminderEnabled
                      ? Container(
                          padding: const EdgeInsets.only(
                            top: 6,
                            left: 76,
                          ),
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              updateWeighReminderTimeViaPicker(context);
                            },
                            icon: PhosphorIcon(
                              PhosphorIconsBold.clock,
                              color: context.colors.text,
                              size: 18,
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: const StadiumBorder(),
                              textStyle: context.textStyles.smallButton,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              backgroundColor: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                              foregroundColor: context.colors.text,
                            ),
                            label: Text(
                              getWeighReminderTime(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          ///
          /// REVIEW PREVIOUS DAY
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: marginHorizontal,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * (permissionStatus == AuthorizationStatus.authorized ? 4 : 5),
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 18),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                  ScaleEffect(
                    begin: Offset(0.98, 0.98),
                    end: Offset(1, 1),
                    alignment: Alignment.topCenter,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: NotificationsSheetListTile(
                  onPressed: () => handleSettingsPressed(
                    settings.copyWith(
                      dailySummaryEnabled: !settings.dailySummaryEnabled,
                    ),
                  ),
                  isActive: settings.dailySummaryEnabled,
                  color: context.colors.protein,
                  icon: PhosphorIconsBold.chartLine,
                  title: 'notificationsDailySummaryTitle'.tr(),
                  subtitle: 'notificationsDailySummarySubtitle'.tr(),
                  belowTextWidget: settings.dailySummaryEnabled
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 76,
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              updateDailySummaryTimeViaPicker(context);
                            },
                            icon: PhosphorIcon(
                              PhosphorIconsBold.clock,
                              color: context.colors.text,
                              size: 18,
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: const StadiumBorder(),
                              textStyle: context.textStyles.smallButton,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              backgroundColor: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                              foregroundColor: context.colors.text,
                            ),
                            label: Text(
                              getDailySummaryTime(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          ///
          /// ANNOUNCEMENTS
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: marginHorizontal,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * (permissionStatus == AuthorizationStatus.authorized ? 5 : 6),
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 18),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                  ScaleEffect(
                    begin: Offset(0.98, 0.98),
                    end: Offset(1, 1),
                    alignment: Alignment.topCenter,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: NotificationsSheetListTile(
                  onPressed: () => handleSettingsPressed(
                    settings.copyWith(
                      announcementsEnabled: !settings.announcementsEnabled,
                    ),
                  ),
                  isActive: settings.announcementsEnabled,
                  color: context.colors.fat,
                  icon: PhosphorIconsBold.megaphone,
                  title: 'notificationsAnnouncementsTitle'.tr(),
                  subtitle: 'notificationsAnnouncementsSubtitle'.tr(),
                ),
              ),
            ),
          ),

          ///
          /// BOTTOM SPACING
          ///
          SliverToBoxAdapter(
            child: SizedBox(
              height: getBottomSpacing(context),
            ),
          ),
        ],
      ),
    ),
  );
}
