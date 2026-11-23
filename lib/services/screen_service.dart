import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../screens/account/account_screen.dart';
import '../screens/meals/meals_screen.dart';
import '../screens/walks/walks_screen.dart';
import '../screens/weights/weights_screen.dart';
import '../util/analytics.dart';
import 'analytics_service.dart';

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

  final AnalyticsService analytics;

  ScreenService({
    required this.analytics,
  }) : super(MainScreenItem.meals);

  ///
  /// METHODS
  ///

  /// Triggered when the user presses navigation bar
  void changeNavigationBarItem(
    MainScreenItem item, {
    bool trackView = true,
  }) {
    /// User pressed same item
    if (value == item) {
      return;
    }

    /// Update `state`
    value = item;

    if (trackView) {
      unawaited(
        analytics.record(
          AnalyticsEvent.primaryTabViewed,
          parameters: {
            'tab': item.name,
          },
        ),
      );
    }
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
