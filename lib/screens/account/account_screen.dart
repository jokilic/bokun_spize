import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../constants/constants.dart';
import '../../services/firebase_service.dart';
import '../../services/notification_service.dart';
import '../../services/screen_service.dart';
import '../../services/theme_service.dart';
import '../../theme/extensions.dart';
import '../../util/dependencies.dart';
import '../../util/snackbars.dart';
import '../meals/meals_controller.dart';
import '../walks/walks_controller.dart';
import '../weights/weights_controller.dart';
import 'account_controller.dart';
import 'widgets/account_content.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<AccountController>(
      () => AccountController(
        firebase: getIt.get<FirebaseService>(),
        notification: getIt.get<NotificationService>(),
        theme: getIt.get<ThemeService>(),
      ),
    );
  }

  @override
  void dispose() {
    // unRegisterIfNotDisposed<MealsController>();
    super.dispose();
  }

  /// Signs out and cancels user-specific listeners
  Future<void> handleLogOut() async {
    if (isLoggingOut) {
      return;
    }

    if (mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(
        () => isLoggingOut = true,
      );
    }

    try {
      await getIt.get<FirebaseService>().logOut();
    } catch (error, stackTrace) {
      log(
        'Signing out failed',
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(
          () => isLoggingOut = false,
        );
        showSnackbar(
          context,
          text: 'accountLogoutFailure'.tr(),
          icon: PhosphorIconsBold.warningOctagon,
        );
      }
      return;
    }

    try {
      /// Reset the default tab for the next sign-in
      getIt.get<ScreenService>().changeNavigationBarItem(
        MainScreenItem.meals,
      );

      await Future.wait([
        unRegisterIfNotDisposed<MealsController>(),
        unRegisterIfNotDisposed<WeightsController>(),
        unRegisterIfNotDisposed<WalksController>(),
        unRegisterIfNotDisposed<AccountController>(),
      ]);
    } catch (error, stackTrace) {
      log(
        'Cleaning up after sign-out failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      ///
      /// ACCOUNT CONTENT
      ///
      ExcludeFocus(
        excluding: isLoggingOut,
        child: AccountContent(
          onLogOut: handleLogOut,
        ),
      ),

      ///
      /// LOGGING OUT OVERLAY
      ///
      if (isLoggingOut) ...[
        const ModalBarrier(
          color: Colors.black38,
          dismissible: false,
        ),

        BlockSemantics(
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: context.colors.scaffoldBackground,
                borderRadius: BorderRadius.circular(listTileRadius),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: context.colors.text,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'accountLogoutProgress'.tr(),
                        style: context.textStyles.listTileTitle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ],
  );
}
