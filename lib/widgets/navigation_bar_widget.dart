import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../constants/durations.dart';
import '../services/firebase_service.dart';
import '../services/screen_service.dart';
import '../theme/extensions.dart';
import '../util/dependencies.dart';

class NavigationBarWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final screen = getIt.get<ScreenService>();

    /// User data from `Firebase`
    final userPhoto = getIt.get<FirebaseService>().userPhoto;

    /// Current navigation bar item
    final navigationBarItem = watchIt<ScreenService>().value;

    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: NavigationBar(
        height: 88,
        backgroundColor: context.colors.scaffoldBackground,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        animationDuration: BokunSpizeDurations.animation,
        selectedIndex: navigationBarItem.index,
        onDestinationSelected: (newIndex) {
          HapticFeedback.lightImpact();
          screen.changeNavigationBarItem(
            MainScreenItem.values[newIndex],
          );
        },
        destinations: [
          ///
          /// MEALS
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIconsBold.bowlFood,
                  color: context.colors.text,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'navigationBarMeals'.tr().toUpperCase(),
                  style: context.textStyles.navigationBarLabel,
                ),
              ],
            ),
            selectedIcon: NavigationBarSelectedIcon(
              color: context.colors.protein,
              child: PhosphorIcon(
                PhosphorIconsBold.bowlFood,
                color: context.colors.buttonText,
                size: 24,
              ),
            ),
            label: '',
          ),

          ///
          /// WEIGHTS
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIconsBold.personSimple,
                  color: context.colors.text,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'weights'.tr().toUpperCase(),
                  style: context.textStyles.navigationBarLabel,
                ),
              ],
            ),
            selectedIcon: NavigationBarSelectedIcon(
              color: context.colors.carbs,
              child: PhosphorIcon(
                PhosphorIconsBold.personSimple,
                color: context.colors.buttonText,
                size: 24,
              ),
            ),
            label: '',
          ),

          ///
          /// WALKS
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIconsBold.footprints,
                  color: context.colors.text,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'walks'.tr().toUpperCase(),
                  style: context.textStyles.navigationBarLabel,
                ),
              ],
            ),
            selectedIcon: NavigationBarSelectedIcon(
              color: context.colors.fat,
              child: PhosphorIcon(
                PhosphorIconsBold.footprints,
                color: context.colors.buttonText,
                size: 24,
              ),
            ),
            label: '',
          ),

          ///
          /// ACCOUNT
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (userPhoto != null)
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userPhoto,
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox.shrink(),
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  )
                else
                  PhosphorIcon(
                    PhosphorIconsBold.user,
                    color: context.colors.text,
                    size: 24,
                  ),
                const SizedBox(height: 8),
                Text(
                  'account'.tr().toUpperCase(),
                  style: context.textStyles.navigationBarLabel,
                ),
              ],
            ),
            selectedIcon: NavigationBarSelectedIcon(
              color: context.colors.account,
              child: userPhoto != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: userPhoto,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => PhosphorIcon(
                          PhosphorIconsBold.user,
                          color: context.colors.buttonText,
                          size: 24,
                        ),
                        errorBuilder: (context, error, stackTrace) => PhosphorIcon(
                          PhosphorIconsBold.user,
                          color: context.colors.buttonText,
                          size: 24,
                        ),
                      ),
                    )
                  : PhosphorIcon(
                      PhosphorIconsBold.user,
                      color: context.colors.buttonText,
                      size: 24,
                    ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

class NavigationBarSelectedIcon extends StatelessWidget {
  final Color color;
  final Widget child;

  const NavigationBarSelectedIcon({
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(
      begin: 0,
      end: 1,
    ),
    duration: BokunSpizeDurations.stateTransition,
    curve: Curves.easeOutCubic,
    builder: (context, scale, child) => SizedBox(
      height: 56,
      width: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(
                dimension: 56,
              ),
            ),
          ),
          if (child != null) child,
        ],
      ),
    ),
    child: child,
  );
}
