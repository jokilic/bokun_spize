import 'dart:math';

import 'package:easy_localization/easy_localization.dart';

/// Returns a randomly selected localized AI meal example
String getRandomAIMealExample() {
  final number = Random().nextInt(10) + 1;
  return 'mealAIExample$number'.tr();
}

/// Returns a randomly selected localized manual meal example
String getRandomManualMealExample() {
  final number = Random().nextInt(10) + 1;
  return 'mealManualExample$number'.tr();
}

/// Returns a randomly selected localized food example
String getRandomFoodExample() {
  final number = Random().nextInt(10) + 1;
  return 'foodExample$number'.tr();
}
