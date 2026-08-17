import 'package:flutter/material.dart';
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
                const Icon(
                  Icons.book_rounded,
                  size: 24,
                  color: BokunSpizeColors.neutralDark,
                ),
                const SizedBox(height: 4),
                Text(
                  'Journal'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
              child: const Icon(
                Icons.book_rounded,
                size: 24,
                color: BokunSpizeColors.white,
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
                const Icon(
                  Icons.grade_rounded,
                  size: 24,
                  color: BokunSpizeColors.neutralDark,
                ),
                const SizedBox(height: 4),
                Text(
                  'Insights'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
              child: const Icon(
                Icons.grade_rounded,
                size: 24,
                color: BokunSpizeColors.white,
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
                const Icon(
                  Icons.search_rounded,
                  size: 24,
                  color: BokunSpizeColors.neutralDark,
                ),
                const SizedBox(height: 4),
                Text(
                  'Search'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
              child: const Icon(
                Icons.search_rounded,
                size: 24,
                color: BokunSpizeColors.white,
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
                const Icon(
                  Icons.account_circle_rounded,
                  size: 24,
                  color: BokunSpizeColors.neutralDark,
                ),
                const SizedBox(height: 4),
                Text(
                  'Account'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
              child: const Icon(
                Icons.account_circle_rounded,
                size: 24,
                color: BokunSpizeColors.white,
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
