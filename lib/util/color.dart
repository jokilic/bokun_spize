// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/meal/nutrition.dart';

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

Color getCalorieValueColor({required Nutrition? nutrition}) {
  if (nutrition == null) {
    return BokunSpizeColors.black;
  }

  if (nutrition.protein >= nutrition.carbs && nutrition.protein >= nutrition.fat) {
    return BokunSpizeColors.green;
  }

  if (nutrition.carbs >= nutrition.fat) {
    return BokunSpizeColors.blue;
  }

  return BokunSpizeColors.bordeaux;
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
