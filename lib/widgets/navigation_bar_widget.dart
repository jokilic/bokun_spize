import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../constants/colors.dart';
import '../constants/durations.dart';
import '../services/firebase_service.dart';
import '../services/screen_service.dart';
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
        backgroundColor: BokunSpizeColors.grey,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        animationDuration: BokunSpizeDurations.animation,
        selectedIndex: navigationBarItem.index,
        onDestinationSelected: (newIndex) => screen.changeNavigationBarItem(
          NavigationBarItem.values[newIndex],
        ),
        destinations: [
          ///
          /// MEALS
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.bowlFood,
                  color: BokunSpizeColors.black,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Meals'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BokunSpizeColors.black,
                  ),
                ),
              ],
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: BokunSpizeColors.primary,
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(
                PhosphorIconsBold.bowlFood,
                color: BokunSpizeColors.white,
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
                const PhosphorIcon(
                  PhosphorIconsBold.personSimple,
                  color: BokunSpizeColors.black,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Weights'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BokunSpizeColors.black,
                  ),
                ),
              ],
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: BokunSpizeColors.primary,
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(
                PhosphorIconsBold.personSimple,
                color: BokunSpizeColors.white,
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
                const PhosphorIcon(
                  PhosphorIconsBold.footprints,
                  color: BokunSpizeColors.black,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Walks'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BokunSpizeColors.black,
                  ),
                ),
              ],
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: BokunSpizeColors.primary,
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(
                PhosphorIconsBold.footprints,
                color: BokunSpizeColors.white,
                size: 24,
              ),
            ),
            label: '',
          ),

          ///
          /// PROFILE
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (userPhoto != null)
                  ClipOval(
                    child: Image.network(
                      userPhoto,
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const PhosphorIcon(
                    PhosphorIconsBold.user,
                    color: BokunSpizeColors.black,
                    size: 24,
                  ),
                const SizedBox(height: 8),
                Text(
                  'Account'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BokunSpizeColors.black,
                  ),
                ),
              ],
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: BokunSpizeColors.primary,
                shape: BoxShape.circle,
              ),
              child: userPhoto != null
                  ? ClipOval(
                      child: Image.network(
                        userPhoto,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const PhosphorIcon(
                      PhosphorIconsBold.user,
                      color: BokunSpizeColors.white,
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
