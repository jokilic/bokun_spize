import 'dart:math';

import 'package:easy_localization/easy_localization.dart';

/// Returns a randomly selected localized AI meal example
String getRandomAIMealExample() {
  final number = Random().nextInt(10) + 1;
  return 'foodAIExample$number'.tr();
}

/// Returns a randomly selected localized manual meal example
String getRandomManualMealExample() {
  final number = Random().nextInt(10) + 1;
  return 'foodManualExample$number'.tr();
}
