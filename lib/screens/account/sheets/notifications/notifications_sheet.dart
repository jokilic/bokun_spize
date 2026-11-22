import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/dependencies.dart';
import '../../../../util/spacing.dart';
import 'notifications_controller.dart';
import 'notifications_empty.dart';
import 'notifications_error.dart';
import 'notifications_loading.dart';
import 'notifications_success.dart';

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

class NotificationsSheetState extends State<NotificationsSheet> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<NotificationsController>(
      () => NotificationsController(
        firebase: getIt.get<FirebaseService>(),
        notification: getIt.get<NotificationService>(),
        locale: widget.locale,
        onHistoryPressed: widget.onHistoryPressed,
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<NotificationsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<NotificationsController>();
    final state = watchIt<NotificationsController>().value;

    final settings = state.settings;
    final permissionStatus = state.permissionStatus;
    final error = state.error;
    final isLoading = state.isLoading;
    final hasLoadedData = settings != null && permissionStatus != null;

    return ClipRRect(
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
                        onPressed: controller.openHistory,
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
                          backgroundColor: context.colors.listTileBackground.withValues(
                            alpha: 0.5,
                          ),
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
                          backgroundColor: context.colors.listTileBackground.withValues(
                            alpha: 0.5,
                          ),
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
            /// SUCCESS
            ///
            if (hasLoadedData)
              NotificationsSuccess(
                controller: controller,
                settings: settings,
                permissionStatus: permissionStatus,
                isUpdatingPermission: state.isUpdatingPermission,
              ),

            ///
            /// EMPTY
            ///
            if (!hasLoadedData && !isLoading && error == null) NotificationsEmpty(),

            ///
            /// LOADING
            ///
            if (!hasLoadedData && isLoading) NotificationsLoading(),

            ///
            /// ERROR
            ///
            if (!hasLoadedData && !isLoading && error != null)
              NotificationsError(
                error: error,
                onRetryPressed: controller.loadInitialData,
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
}
