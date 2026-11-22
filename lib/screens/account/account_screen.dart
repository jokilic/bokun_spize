import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
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
  bool isDeletingAccount = false;

  bool get isAccountOperationInProgress => isLoggingOut || isDeletingAccount;

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
    if (isAccountOperationInProgress) {
      return;
    }

    if (mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(
        () => isLoggingOut = true,
      );
    }

    return;

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

    await cleanUpAfterSignOut();
  }

  /// Shows account deletion progress and restores the account screen on failure
  Future<void> handleDeleteAccount(String? password) async {
    if (!mounted || isAccountOperationInProgress) {
      return;
    }

    setState(
      () => isDeletingAccount = true,
    );
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }

    final firebase = getIt.get<FirebaseService>();
    final isDeleted = await firebase.deleteUser(
      email: firebase.userEmail,
      password: password,
    );

    if (isDeleted) {
      await cleanUpAfterSignOut();
    } else if (mounted) {
      setState(() => isDeletingAccount = false);
      showSnackbar(
        context,
        text: 'accountDeleteFailure'.tr(),
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Resets navigation and unregisters user-specific controllers after sign-out
  Future<void> cleanUpAfterSignOut() async {
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
        excluding: isAccountOperationInProgress,
        child: AccountContent(
          onLogOut: handleLogOut,
          onDeleteAccount: handleDeleteAccount,
        ),
      ),

      ///
      /// ASYNC WORK OVERLAY
      ///
      if (isAccountOperationInProgress) ...[
        ClipRect(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: modalBackdropBlurSigma,
            ),
            duration: BokunSpizeDurations.animation,
            curve: Curves.ease,
            builder: (context, blurSigma, child) => BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: child,
            ),
            child: const ModalBarrier(
              color: Colors.transparent,
              dismissible: false,
            ),
          ),
        ),
        BlockSemantics(
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: context.colors.scaffoldBackground,
                borderRadius: BorderRadius.circular(listTileRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 64,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.all(listTileIconRadius / 3),
                          color: context.colors.carbs,
                          child: Animate(
                            onPlay: (controller) => controller.repeat(),
                            effects: const [
                              RotateEffect(
                                duration: BokunSpizeDurations.accountOverlayAnimation,
                              ),
                            ],
                            child: PhosphorIcon(
                              PhosphorIconsBold.hourglass,
                              color: context.colors.buttonText,
                              size: listTileIconRadius / 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        (isDeletingAccount ? 'accountDeleteProgressTitle' : 'accountLogoutProgressTitle').tr(),
                        style: context.textStyles.appBarTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (isDeletingAccount ? 'accountDeleteProgressSubtitle' : 'accountLogoutProgressSubtitle').tr(),
                        style: context.textStyles.listTileSubtitle,
                        textAlign: TextAlign.center,
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
