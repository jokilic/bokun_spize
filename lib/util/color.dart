// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Color getWhiteOrBlackColor({
  required Color backgroundColor,
  required Color whiteColor,
  required Color blackColor,
}) => ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark ? whiteColor : blackColor;

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
