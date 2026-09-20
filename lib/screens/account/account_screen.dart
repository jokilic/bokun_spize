import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../services/firebase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/extensions.dart';
import '../../util/dependencies.dart';
import '../../widgets/navigation_bar_widget.dart';
import '../meals/meals_controller.dart';
import '../walks/walks_controller.dart';
import '../weights/weights_controller.dart';

class AccountScreen extends StatelessWidget {
  /// Cancels user-specific listeners before Firebase sign-out
  Future<void> handleLogOut() async {
    unRegisterIfNotDisposed<MealsController>();
    unRegisterIfNotDisposed<WeightsController>();
    unRegisterIfNotDisposed<WalksController>();

    await getIt.get<FirebaseService>().logOut();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.scaffoldBackground,
    bottomNavigationBar: NavigationBarWidget(),
    floatingActionButton: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          width: 48,
          child: FloatingActionButton(
            heroTag: const ValueKey('account-theme-fab'),
            elevation: 0,
            backgroundColor: context.colors.delete,
            foregroundColor: context.colors.listTileBackground,
            splashColor: context.colors.listTileBackground.withValues(alpha: 0.5),
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            shape: const CircleBorder(),
            onPressed: () {
              HapticFeedback.lightImpact();
              getIt.get<ThemeService>().toggleTheme();
            },
            child: PhosphorIcon(
              PhosphorIconsBold.palette,
              color: context.colors.buttonText,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 68,
          width: 68,
          child: FloatingActionButton(
            heroTag: const ValueKey('account-logout-fab'),
            elevation: 0,
            backgroundColor: context.colors.delete,
            foregroundColor: context.colors.listTileBackground,
            splashColor: context.colors.listTileBackground.withValues(alpha: 0.5),
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            shape: const CircleBorder(),
            onPressed: () {
              HapticFeedback.lightImpact();
              handleLogOut();
            },
            child: PhosphorIcon(
              PhosphorIconsBold.signOut,
              color: context.colors.buttonText,
              size: 32,
            ),
          ),
        ),
      ],
    ),
    body: Animate(
      effects: const [
        FadeEffect(
          duration: BokunSpizeDurations.stateTransition,
          curve: Curves.easeOut,
        ),
        MoveEffect(
          begin: Offset(0, 18),
          end: Offset.zero,
          duration: BokunSpizeDurations.stateTransition,
          curve: Curves.easeOutCubic,
        ),
        ScaleEffect(
          begin: Offset(0.985, 0.985),
          end: Offset(1, 1),
          alignment: Alignment.topCenter,
          duration: BokunSpizeDurations.stateTransition,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: marginHorizontal * 4,
                vertical: 12,
              ),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.stateTransition,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 24),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.stateTransition,
                      curve: Curves.easeOutCubic,
                    ),
                    ScaleEffect(
                      begin: Offset(0.96, 0.96),
                      end: Offset(1, 1),
                      alignment: Alignment.topCenter,
                      duration: BokunSpizeDurations.stateTransition,
                      curve: Curves.easeOutBack,
                    ),
                  ],
                  child: Column(
                    children: [
                      const SizedBox(height: 104),
                      PhosphorIcon(
                        PhosphorIconsBold.user,
                        color: context.colors.delete,
                        size: 88,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Account is not done',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: context.colors.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'It will be done soon...',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.6,
                          color: context.colors.text.withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
