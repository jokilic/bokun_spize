import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart' hide NotificationSettings;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/notification/notification_settings.dart';
import '../../../theme/extensions.dart';
import '../../../util/snackbars.dart';
import '../../../util/spacing.dart';
import 'notifications/notifications_sheet_list_tile.dart';

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

  @override
  State<NotificationsSheet> createState() => NotificationsSheetState();
}

class NotificationsSheetState extends State<NotificationsSheet> with WidgetsBindingObserver {
  late NotificationSettings settings;
  late AuthorizationStatus permissionStatus;

  bool isSaving = false;
  bool isUpdatingPermission = false;

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
      refreshPermission();
    }
  }

  /// Reports whether the operating system can currently deliver notifications
  bool get permissionGranted => switch (permissionStatus) {
    AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
    AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently || AuthorizationStatus.notDetermined => false,
  };

  /// Returns localized text for the current operating-system permission
  String get permissionStatusText => switch (permissionStatus) {
    AuthorizationStatus.authorized => 'notificationsPermissionAuthorized'.tr(),
    AuthorizationStatus.provisional => 'notificationsPermissionProvisional'.tr(),
    AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently => 'notificationsPermissionDenied'.tr(),
    AuthorizationStatus.notDetermined => 'notificationsPermissionNotDetermined'.tr(),
  };

  /// Show optimistic preference update and restore previous value if update fails
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

    /// Update failed, revert to previous value and show error snackbar
    setState(() {
      if (!success) {
        settings = previousSettings;

        showSnackbar(
          context,
          text: 'notificationsSaveFailure'.tr(),
          icon: PhosphorIconsBold.warningOctagon,
        );
      }

      isSaving = false;
    });
  }

  /// Request notification permission from an explicit button press
  Future<void> requestPermission() async {
    if (isUpdatingPermission) {
      return;
    }

    unawaited(
      HapticFeedback.lightImpact(),
    );

    setState(
      () => isUpdatingPermission = true,
    );

    final status = await widget.onPermissionRequested();

    if (!mounted) {
      return;
    }

    setState(() {
      permissionStatus = status;
      isUpdatingPermission = false;
    });
  }

  /// Open application settings and refresh the new permission state
  Future<void> openSettings() async {
    unawaited(
      HapticFeedback.lightImpact(),
    );
    await widget.onOpenSettingsPressed();
    await refreshPermission();
  }

  /// Read the latest operating-system permission state
  Future<void> refreshPermission() async {
    final status = await widget.onPermissionRefreshed();

    if (!mounted) {
      return;
    }

    setState(
      () => permissionStatus = status,
    );
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
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
                    /// PLACEHOLDER BUTTON
                    ///
                    Opacity(
                      opacity: 0,
                      child: IgnorePointer(
                        child: IconButton(
                          onPressed: null,
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
                      ),
                    ),

                    ///
                    /// TITLE
                    ///
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
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),

          ///
          /// NOTIFICATION STATUS
          ///
          if (permissionStatus != AuthorizationStatus.authorized)
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
                      onTap: isUpdatingPermission
                          ? null
                          : permissionStatus == AuthorizationStatus.notDetermined
                          ? requestPermission
                          : openSettings,
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
                          children: [
                            ///
                            /// ICON
                            ///
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: listTileIconRadius,
                                height: listTileIconRadius,
                                alignment: Alignment.center,
                                color: (permissionGranted ? context.colors.protein : context.colors.delete).withValues(alpha: 0.25),
                                child: PhosphorIcon(
                                  permissionGranted ? PhosphorIconsBold.checkFat : PhosphorIconsBold.warningOctagon,
                                  color: permissionGranted ? context.colors.protein : context.colors.delete,
                                  size: listTileIconRadius / 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            ///
                            /// TEXT
                            ///
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    permissionStatusText,
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: context.colors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    permissionGranted ? 'notificationsPermissionReady'.tr() : 'notificationsPermissionBlocked'.tr(),
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: context.colors.text.withValues(alpha: 0.7),
                                    ),
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
                  onPressed: () => updateSettings(
                    settings.copyWith(
                      weighReminderEnabled: !settings.weighReminderEnabled,
                    ),
                  ),
                  isActive: settings.weighReminderEnabled,
                  color: context.colors.carbs,
                  icon: PhosphorIconsBold.personSimple,
                  title: 'notificationsWeighReminderTitle'.tr(),
                  subtitle: 'notificationsWeighReminderSubtitle'.tr(),
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
                  onPressed: () => updateSettings(
                    settings.copyWith(
                      dailySummaryEnabled: !settings.dailySummaryEnabled,
                    ),
                  ),
                  isActive: settings.dailySummaryEnabled,
                  color: context.colors.protein,
                  icon: PhosphorIconsBold.chartLine,
                  title: 'notificationsDailySummaryTitle'.tr(),
                  subtitle: 'notificationsDailySummarySubtitle'.tr(),
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
                  onPressed: () => updateSettings(
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
