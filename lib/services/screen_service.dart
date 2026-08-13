import 'package:flutter/material.dart';

import '../screens/journal/journal_screen.dart';

enum NavigationBarItem {
  journal,
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
        NavigationBarItem.journal,
      );

  ///
  /// METHODS
  ///

  /// Returns proper [Widget], depending on [NavigationBarItem]
  Widget getProperWidget(NavigationBarItem item) {
    final newScreen = switch (item) {
      NavigationBarItem.journal => JournalScreen(),
      NavigationBarItem.insights => WeatherScreen(),
      NavigationBarItem.search => ListScreen(),
      NavigationBarItem.profile => SettingsScreen(),
    };

    return newScreen;
  }
}
