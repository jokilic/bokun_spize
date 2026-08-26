import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MealController extends ValueNotifier<bool> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  MealController() : super(false);

  ///
  /// INIT
  ///

  void init() {}

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    super.dispose();
  }
}
