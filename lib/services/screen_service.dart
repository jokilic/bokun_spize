import 'package:flutter/material.dart';

import '../screens/meals/meals_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/walks/walks_screen.dart';
import '../screens/weights/weights_screen.dart';

enum NavigationBarItem {
  meals,
  weights,
  walks,
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
      NavigationBarItem.weights => WeightsScreen(),
      NavigationBarItem.walks => WalksScreen(),
      NavigationBarItem.profile => ProfileScreen(),
    };

    return newScreen;
  }
}
