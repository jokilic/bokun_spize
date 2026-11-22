import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../models/notification/notification_settings.dart';
import '../../../../theme/extensions.dart';
import 'notifications_controller.dart';
import 'notifications_sheet_list_tile.dart';

class NotificationsSuccess extends StatelessWidget {
  final NotificationsController controller;
  final NotificationSettings settings;
  final bool isUpdatingPermission;

  const NotificationsSuccess({
    required this.controller,
    required this.settings,
    required this.isUpdatingPermission,
  });

  @override
  Widget build(BuildContext context) => SliverList.list(
    children: [
      ///
      /// NOTIFICATION STATUS
      ///
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal,
          vertical: 8,
        ),
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
              onTap: isUpdatingPermission ? null : controller.handlePermissionStatusPressed,
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
                        controller.permissionGranted ? PhosphorIconsBold.checkFat : PhosphorIconsBold.warningOctagon,
                        color: controller.permissionGranted ? context.colors.protein : context.colors.delete,
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
                            controller.permissionStatusText,
                            style: context.textStyles.infoCardTitle.copyWith(
                              color: controller.permissionGranted ? context.colors.protein : context.colors.delete,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.permissionGranted ? 'notificationsPermissionReady'.tr() : 'notificationsPermissionBlocked'.tr(),
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

      ///
      /// RECORD YOUR WEIGHT
      ///
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal,
          vertical: 8,
        ),
        child: Animate(
          delay: BokunSpizeDurations.stateTransitionStagger * 4,
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
            onPressed: () => controller.handleSettingsPressed(
              context,
              newSettings: settings.copyWith(
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
                      onPressed: () => controller.updateWeighReminderTimeViaPicker(context),
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
                        controller.getWeighReminderTime(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),

      ///
      /// REVIEW PREVIOUS DAY
      ///
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal,
          vertical: 8,
        ),
        child: Animate(
          delay: BokunSpizeDurations.stateTransitionStagger * 5,
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
            onPressed: () => controller.handleSettingsPressed(
              context,
              newSettings: settings.copyWith(
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
                      onPressed: () => controller.updateDailySummaryTimeViaPicker(context),
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
                        controller.getDailySummaryTime(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),

      ///
      /// ANNOUNCEMENTS
      ///
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal,
          vertical: 8,
        ),
        child: Animate(
          delay: BokunSpizeDurations.stateTransitionStagger * 6,
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
            onPressed: () => controller.handleSettingsPressed(
              context,
              newSettings: settings.copyWith(
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
    ],
  );
}
