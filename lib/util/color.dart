// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

import '../models/meal/nutrition.dart';
import '../theme/colors.dart';
import '../theme/extensions.dart';

Color colorFromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 7) {
    buffer.write('ff');
  }

  buffer.write(hex.replaceFirst('#', ''));

  return Color(
    int.parse(
      buffer.toString(),
      radix: 16,
    ),
  );
}

String colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

Color getCalorieValueColor({
  required Nutrition? nutrition,
  required BuildContext context,
}) {
  if (nutrition == null || (nutrition.protein == 0 && nutrition.carbs == 0 && nutrition.fat == 0)) {
    return context.colors.text;
  }

  if (nutrition.protein >= nutrition.carbs && nutrition.protein >= nutrition.fat) {
    return context.colors.protein;
  }

  if (nutrition.carbs >= nutrition.fat) {
    return context.colors.carbs;
  }

  return context.colors.fat;
}

Color getRandomPrimaryColor() {
  const primaryColors = [
    BokunSpizeColors.green,
    BokunSpizeColors.blue,
    BokunSpizeColors.bordeaux,
    BokunSpizeColors.red,
  ];

  return primaryColors[Random().nextInt(primaryColors.length)];
}
