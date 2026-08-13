import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../constants/colors.dart';
import '../constants/durations.dart';
import '../constants/icons.dart';
import '../services/screen_service.dart';
import '../util/dependencies.dart';

class BokunSpizeNavigationBar extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final screen = getIt.get<ScreenService>();

    final navigationBarItem = watchIt<ScreenService>().value;

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: NavigationBar(
        height: navigationBarHeight,
        backgroundColor: Colors.amber,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        animationDuration: BokunSpizeDurations.animation,
        selectedIndex: navigationBarItem.index,
        onDestinationSelected: (newIndex) => screen.getProperWidget(
          NavigationBarItem.values[newIndex],
        ),
        destinations: [
          ///
          /// JOURNAL
          ///
          NavigationDestination(
            icon: Icon(
              Icons.book_rounded,
              size: 22,
              color: BokunSpizeColors.white.withValues(alpha: 0.15),
            ),
            selectedIcon: const Icon(
              Icons.book_rounded,
              size: 22,
              color: BokunSpizeColors.white,
            ),
            label: '',
          ),

          ///
          /// INSIGHTS
          ///
          NavigationDestination(
            icon: Icon(
              Icons.graphic_eq_rounded,
              size: 22,
              color: BokunSpizeColors.white.withValues(alpha: 0.15),
            ),
            selectedIcon: const Icon(
              Icons.graphic_eq_rounded,
              size: 22,
              color: BokunSpizeColors.white,
            ),
            label: '',
          ),

          ///
          /// SEARCH
          ///
          NavigationDestination(
            icon: Icon(
              Icons.search_rounded,
              size: 22,
              color: BokunSpizeColors.white.withValues(alpha: 0.15),
            ),
            selectedIcon: const Icon(
              Icons.search_rounded,
              size: 22,
              color: BokunSpizeColors.white,
            ),
            label: '',
          ),

          ///
          /// PROFILE
          ///
          NavigationDestination(
            icon: Icon(
              Icons.account_box_rounded,
              size: 22,
              color: BokunSpizeColors.white.withValues(alpha: 0.15),
            ),
            selectedIcon: const Icon(
              Icons.account_box_rounded,
              size: 22,
              color: BokunSpizeColors.white,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
