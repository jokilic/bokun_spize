import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart' hide NotificationSettings;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/notification_settings/notification_settings.dart';
import '../../../theme/extensions.dart';
import '../../../util/spacing.dart';
import '../../../widgets/blurred_modal_bottom_sheet.dart';
import '../../../widgets/time_sheet.dart';

class NotificationsSheet extends StatefulWidget {
  final NotificationSettings initialSettings;
  final AuthorizationStatus initialPermissionStatus;
  final Future<bool> Function(NotificationSettings settings) onSettingsChanged;
  final Future<AuthorizationStatus> Function() onPermissionRequested;
  final Future<AuthorizationStatus> Function() onPermissionRefreshed;
  final Future<bool> Function() onOpenSettingsPressed;

  const NotificationsSheet({
    required this.initialSettings,
    required this.initialPermissionStatus,
    required this.onSettingsChanged,
    required this.onPermissionRequested,
    required this.onPermissionRefreshed,
    required this.onOpenSettingsPressed,
  });

  /// Creates mutable notification sheet state
  @override
  State<NotificationsSheet> createState() => NotificationsSheetState();
}

class NotificationsSheetState extends State<NotificationsSheet> with WidgetsBindingObserver {
  late NotificationSettings settings;
  late AuthorizationStatus permissionStatus;
  bool isSaving = false;
  bool isUpdatingPermission = false;

  /// Starts observing app lifecycle changes for permission refreshes
  @override
  void initState() {
    super.initState();
    settings = widget.initialSettings;
    permissionStatus = widget.initialPermissionStatus;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Stops observing app lifecycle changes
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Refreshes permission after returning from operating-system settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshPermission());
    }
  }

  /// Reports whether the operating system can currently deliver notifications
  bool get permissionGranted => switch (permissionStatus) {
    AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
    AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently || AuthorizationStatus.notDetermined => false,
  };

  /// Returns the translation key for the current operating-system permission
  String get permissionStatusKey => switch (permissionStatus) {
    AuthorizationStatus.authorized => 'notificationsPermissionAuthorized',
    AuthorizationStatus.provisional => 'notificationsPermissionProvisional',
    AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently => 'notificationsPermissionDenied',
    AuthorizationStatus.notDetermined => 'notificationsPermissionNotDetermined',
  };

  /// Persists one optimistic preference update and restores the previous value on failure
  Future<void> updateSettings(NotificationSettings newSettings) async {
    if (isSaving) {
      return;
    }

    final previousSettings = settings;

    setState(() {
      settings = newSettings;
      isSaving = true;
    });

    final success = await widget.onSettingsChanged(newSettings);

    if (!mounted) {
      return;
    }

    setState(() {
      if (!success) {
        settings = previousSettings;
      }
      isSaving = false;
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('notificationsSaveFailure'.tr()),
        ),
      );
    }
  }

  /// Requests notification permission from an explicit button press
  Future<void> requestPermission() async {
    if (isUpdatingPermission) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => isUpdatingPermission = true);

    final status = await widget.onPermissionRequested();

    if (!mounted) {
      return;
    }

    setState(() {
      permissionStatus = status;
      isUpdatingPermission = false;
    });
  }

  /// Opens application settings and refreshes the resulting permission state
  Future<void> openSettings() async {
    HapticFeedback.lightImpact();
    await widget.onOpenSettingsPressed();
    await refreshPermission();
  }

  /// Reads the latest operating-system permission state
  Future<void> refreshPermission() async {
    final status = await widget.onPermissionRefreshed();

    if (!mounted) {
      return;
    }

    setState(() => permissionStatus = status);
  }

  /// Opens the shared time picker for a scheduled notification preference
  Future<void> openTimePicker({required bool isWeighReminder}) async {
    final initialTime = isWeighReminder ? settings.weighReminderTime : settings.dailySummaryTime;

    await showBlurredModalBottomSheet(
      context: context,
      builder: (sheetContext) => TimeSheet(
        primaryColor: context.colors.carbs,
        dateValue: initialTime.toDateTime(),
        subtitle: isWeighReminder ? 'notificationsWeighTimeSubtitle'.tr() : 'notificationsDailyTimeSubtitle'.tr(),
        onTimeChanged: (newTime) {
          HapticFeedback.lightImpact();
          final notificationTime = NotificationTime(
            hour: newTime.hour,
            minute: newTime.minute,
          );

          unawaited(
            updateSettings(
              isWeighReminder ? settings.copyWith(weighReminderTime: notificationTime) : settings.copyWith(dailySummaryTime: notificationTime),
            ),
          );
        },
      ),
    );
  }

  /// Builds the notification preferences sheet
  @override
  Widget build(BuildContext context) => ClipRRect(
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
                    Opacity(
                      opacity: 0,
                      child: IgnorePointer(
                        child: IconButton(
                          onPressed: null,
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.x,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'notificationsTitle'.tr(),
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 0.6,
                          color: context.colors.text,
                        ),
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
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              marginHorizontal,
              8,
              marginHorizontal,
              16,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'notificationsSheetSubtitle'.tr(),
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.text,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: marginHorizontal,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(listTileRadius),
                  color: context.colors.listTileBackground.withValues(alpha: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          permissionGranted ? PhosphorIconsBold.checkCircle : PhosphorIconsBold.warningCircle,
                          color: permissionGranted ? context.colors.protein : context.colors.delete,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            permissionStatusKey.tr(),
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: context.colors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      permissionGranted ? 'notificationsPermissionReady'.tr() : 'notificationsPermissionBlocked'.tr(),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.colors.text.withValues(alpha: 0.7),
                      ),
                    ),
                    if (!permissionGranted) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isUpdatingPermission
                              ? null
                              : permissionStatus == AuthorizationStatus.notDetermined
                              ? requestPermission
                              : openSettings,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: const StadiumBorder(),
                            backgroundColor: context.colors.carbs,
                            foregroundColor: context.colors.buttonText,
                          ),
                          child: Text(
                            permissionStatus == AuthorizationStatus.notDetermined ? 'notificationsAllowAction'.tr() : 'notificationsOpenSettingsAction'.tr(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          NotificationPreferenceTile(
            title: 'notificationsWeighReminderTitle'.tr(),
            subtitle: 'notificationsWeighReminderSubtitle'.tr(),
            enabled: settings.weighReminderEnabled,
            permissionGranted: permissionGranted,
            time: settings.weighReminderTime,
            onChanged: (enabled) => updateSettings(
              settings.copyWith(weighReminderEnabled: enabled),
            ),
            onTimePressed: () => openTimePicker(isWeighReminder: true),
          ),
          NotificationPreferenceTile(
            title: 'notificationsDailySummaryTitle'.tr(),
            subtitle: 'notificationsDailySummarySubtitle'.tr(),
            enabled: settings.dailySummaryEnabled,
            permissionGranted: permissionGranted,
            time: settings.dailySummaryTime,
            onChanged: (enabled) => updateSettings(
              settings.copyWith(dailySummaryEnabled: enabled),
            ),
            onTimePressed: () => openTimePicker(isWeighReminder: false),
          ),
          NotificationPreferenceTile(
            title: 'notificationsAnnouncementsTitle'.tr(),
            subtitle: 'notificationsAnnouncementsSubtitle'.tr(),
            enabled: settings.announcementsEnabled,
            permissionGranted: permissionGranted,
            onChanged: (enabled) => updateSettings(
              settings.copyWith(announcementsEnabled: enabled),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              marginHorizontal,
              12,
              marginHorizontal,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${settings.timezone} · ${settings.locale.toUpperCase()}',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.colors.text.withValues(alpha: 0.55),
                ),
                textAlign: TextAlign.center,
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
}

class NotificationPreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final bool permissionGranted;
  final NotificationTime? time;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTimePressed;

  const NotificationPreferenceTile({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.permissionGranted,
    required this.onChanged,
    this.time,
    this.onTimePressed,
  });

  /// Builds one persisted notification preference control
  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal,
      vertical: 8,
    ),
    sliver: SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(listTileRadius),
          color: context.colors.listTileBackground.withValues(alpha: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: context.colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.colors.text.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: enabled,
                  activeThumbColor: context.colors.carbs,
                  onChanged: onChanged,
                ),
              ],
            ),
            if (enabled && !permissionGranted) ...[
              const SizedBox(height: 10),
              Text(
                'notificationsDeliveryBlocked'.tr(),
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colors.delete,
                ),
              ),
            ],
            if (enabled && time != null && onTimePressed != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onTimePressed,
                icon: const PhosphorIcon(
                  PhosphorIconsBold.clock,
                  size: 18,
                ),
                label: Text(time!.toFirestoreValue()),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.carbs,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
