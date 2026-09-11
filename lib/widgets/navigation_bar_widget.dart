import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            NavigationBarItem.values[newIndex],
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
                  'Meals'.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.text,
                  ),
                ),
              ],
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.protein,
                shape: BoxShape.circle,
              ),
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
                  'Weights'.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.text,
                  ),
                ),
              ],
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.carbs,
                shape: BoxShape.circle,
              ),
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
                  'Walks'.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.text,
                  ),
                ),
              ],
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.fat,
                shape: BoxShape.circle,
              ),
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
                  'Account'.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.text,
                  ),
                ),
              ],
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.delete,
                shape: BoxShape.circle,
              ),
              child: userPhoto != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: userPhoto,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox.shrink(),
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
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
