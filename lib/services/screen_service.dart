import 'package:flutter/material.dart';

import '../screens/insights/insights_screen.dart';
import '../screens/meals/meals_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_screen.dart';

enum NavigationBarItem {
  meals,
  insights,
  search,
  profile,
}

class ScreenService extends ValueNotifier<NavigationBarItem> {
  ///
  /// CONSTRUCTOR
  ///

  ScreenService()
    : super(
        NavigationBarItem.meals,
      );

  ///
  /// METHODS
  ///

  /// Triggered when the user presses navigation bar
  void changeNavigationBarItem(NavigationBarItem item) {
    /// User pressed same item
    if (value == item) {
      return;
    }

    /// Update `state`
    value = item;
  }

  /// Returns proper [Widget], depending on [NavigationBarItem]
  Widget getProperWidget(NavigationBarItem item) {
    final newScreen = switch (item) {
      NavigationBarItem.meals => MealsScreen(),
      NavigationBarItem.insights => InsightsScreen(),
      NavigationBarItem.search => SearchScreen(),
      NavigationBarItem.profile => ProfileScreen(),
    };

    return newScreen;
  }
}
