import 'package:material_ui/material_ui.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../util/dependencies.dart';
import 'notifications_controller.dart';
import 'notifications_empty.dart';
import 'notifications_error.dart';
import 'notifications_loading.dart';
import 'notifications_success.dart';

class NotificationsContent extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<NotificationsController>();
    final state = watchIt<NotificationsController>().value;

    final settings = state.settings;
    final hasLoadedData = settings != null && state.permissionStatus != null;

    ///
    /// SUCCESS
    ///
    if (hasLoadedData) {
      return NotificationsSuccess(
        settings: settings,
        isUpdatingPermission: state.isUpdatingPermission,
        permissionGranted: controller.permissionGranted,
        permissionStatusText: controller.permissionStatusText,
        weighReminderTime: controller.getWeighReminderTime(context),
        dailySummaryTime: controller.getDailySummaryTime(context),
        handlePermissionStatusPressed: controller.handlePermissionStatusPressed,
        handleSettingsPressed: controller.handleSettingsPressed,
        updateWeighReminderTimeViaPicker: controller.updateWeighReminderTimeViaPicker,
        updateDailySummaryTimeViaPicker: controller.updateDailySummaryTimeViaPicker,
      );
    }

    ///
    /// LOADING
    ///
    if (state.isLoading) {
      return NotificationsLoading();
    }

    ///
    /// ERROR
    ///
    if (state.error != null) {
      return NotificationsError(
        error: state.error!,
        onRetryPressed: controller.loadInitialData,
      );
    }

    ///
    /// EMPTY
    ///
    return NotificationsEmpty();
  }
}
