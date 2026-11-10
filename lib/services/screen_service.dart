import 'package:flutter/material.dart';

import '../screens/account/account_screen.dart';
import '../screens/meals/meals_screen.dart';
import '../screens/walks/walks_screen.dart';
import '../screens/weights/weights_screen.dart';

enum MainScreenItem {
  meals,
  weights,
  walks,
  account,
}

class ScreenService extends ValueNotifier<MainScreenItem> {
  ///
  /// CONSTRUCTOR
  ///

  ScreenService()
    : super(
        MainScreenItem.meals,
      );

  ///
  /// METHODS
  ///

  /// Triggered when the user presses navigation bar
  void changeNavigationBarItem(MainScreenItem item) {
    /// User pressed same item
    if (value == item) {
      return;
    }

    /// Update `state`
    value = item;
  }

  /// Returns proper [Widget], depending on [MainScreenItem]
  Widget getProperWidget(MainScreenItem item) {
    final newScreen = switch (item) {
      MainScreenItem.meals => MealsScreen(),
      MainScreenItem.weights => WeightsScreen(),
      MainScreenItem.walks => WalksScreen(),
      MainScreenItem.account => AccountScreen(),
    };

    return newScreen;
  }
}
