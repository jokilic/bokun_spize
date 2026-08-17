import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../constants/colors.dart';
import '../constants/durations.dart';
import '../services/screen_service.dart';
import '../util/dependencies.dart';

class NavigationBarWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final screen = getIt.get<ScreenService>();

    final navigationBarItem = watchIt<ScreenService>().value;

    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: NavigationBar(
        height: 88,
        backgroundColor: BokunSpizeColors.neutralLight,
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
          /// JOURNAL
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.notebook,
                  color: BokunSpizeColors.neutralDark,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Journal'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BokunSpizeColors.neutralDark,
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
                PhosphorIconsBold.notebook,
                color: BokunSpizeColors.white,
                size: 24,
              ),
            ),
            label: '',
          ),

          ///
          /// INSIGHTS
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.chartLine,
                  color: BokunSpizeColors.neutralDark,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Insights'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BokunSpizeColors.neutralDark,
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
                PhosphorIconsBold.chartLine,
                color: BokunSpizeColors.white,
                size: 24,
              ),
            ),
            label: '',
          ),

          ///
          /// SEARCH
          ///
          NavigationDestination(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.magnifyingGlass,
                  color: BokunSpizeColors.neutralDark,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Search'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BokunSpizeColors.neutralDark,
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
                PhosphorIconsBold.magnifyingGlass,
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
                const PhosphorIcon(
                  PhosphorIconsBold.user,
                  color: BokunSpizeColors.neutralDark,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Account'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BokunSpizeColors.neutralDark,
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
