import 'dart:math';

import 'package:image/image.dart' as img;

const blurHashBase83Characters = r'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~';

typedef BlurHashColor = ({double red, double green, double blue});

/// Encodes an image into a BlurHash using the requested component counts
String encodeBlurHashImage(
  img.Image image, {
  int componentX = 4,
  int componentY = 3,
}) {
  if (componentX < 1 || componentX > 9 || componentY < 1 || componentY > 9) {
    throw ArgumentError('BlurHash component counts must be between 1 and 9');
  }

  final factors = <BlurHashColor>[];

  for (var componentYIndex = 0; componentYIndex < componentY; componentYIndex++) {
    for (var componentXIndex = 0; componentXIndex < componentX; componentXIndex++) {
      factors.add(
        calculateBlurHashColor(
          image,
          componentXIndex: componentXIndex,
          componentYIndex: componentYIndex,
        ),
      );
    }
  }

  final dc = factors.first;
  final ac = factors.skip(1).toList();
  final maximumValue = ac.fold<double>(
    0,
    (maximum, color) => max(
      maximum,
      max(
        color.red.abs(),
        max(color.green.abs(), color.blue.abs()),
      ),
    ),
  );
  final quantizedMaximumValue = ac.isEmpty ? 0 : (maximumValue * 166 - 0.5).floor().clamp(0, 82).toInt();
  final actualMaximumValue = (quantizedMaximumValue + 1) / 166;
  final sizeFlag = componentX - 1 + (componentY - 1) * 9;

  return '${encodeBlurHashBase83(sizeFlag, 1)}${encodeBlurHashBase83(quantizedMaximumValue, 1)}${encodeBlurHashBase83(encodeBlurHashDc(dc), 4)}${ac.map((color) => encodeBlurHashBase83(encodeBlurHashAc(color, actualMaximumValue), 2)).join()}';
}

/// Calculates one BlurHash color component from the image pixels
BlurHashColor calculateBlurHashColor(
  img.Image image, {
  required int componentXIndex,
  required int componentYIndex,
}) {
  var red = 0.0;
  var green = 0.0;
  var blue = 0.0;
  final normalization = componentXIndex == 0 && componentYIndex == 0 ? 1.0 : 2.0;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final basis = cos(pi * componentXIndex * x / image.width) * cos(pi * componentYIndex * y / image.height);
      final pixel = image.getPixel(x, y);

      red += basis * convertBlurHashSrgbToLinear(pixel.r.toInt());
      green += basis * convertBlurHashSrgbToLinear(pixel.g.toInt());
      blue += basis * convertBlurHashSrgbToLinear(pixel.b.toInt());
    }
  }

  final scale = normalization / (image.width * image.height);

  return (
    red: red * scale,
    green: green * scale,
    blue: blue * scale,
  );
}

/// Converts an sRGB color component into linear color space
double convertBlurHashSrgbToLinear(int value) {
  final normalizedValue = value / 255;

  return normalizedValue <= 0.04045 ? normalizedValue / 12.92 : pow((normalizedValue + 0.055) / 1.055, 2.4).toDouble();
}

/// Converts a linear color component into an sRGB byte
int convertBlurHashLinearToSrgb(double value) {
  final normalizedValue = value.clamp(0.0, 1.0);
  final convertedValue = normalizedValue <= 0.0031308 ? normalizedValue * 12.92 : 1.055 * pow(normalizedValue, 1 / 2.4) - 0.055;

  return (convertedValue * 255 + 0.5).floor().clamp(0, 255).toInt();
}

/// Encodes the average BlurHash color component
int encodeBlurHashDc(BlurHashColor color) {
  final red = convertBlurHashLinearToSrgb(color.red);
  final green = convertBlurHashLinearToSrgb(color.green);
  final blue = convertBlurHashLinearToSrgb(color.blue);

  return red << 16 | green << 8 | blue;
}

/// Encodes a non-average BlurHash color component
int encodeBlurHashAc(BlurHashColor color, double maximumValue) {
  final red = (applyBlurHashSignPower(color.red / maximumValue, 0.5) * 9 + 9.5).floor().clamp(0, 18).toInt();
  final green = (applyBlurHashSignPower(color.green / maximumValue, 0.5) * 9 + 9.5).floor().clamp(0, 18).toInt();
  final blue = (applyBlurHashSignPower(color.blue / maximumValue, 0.5) * 9 + 9.5).floor().clamp(0, 18).toInt();

  return red * 19 * 19 + green * 19 + blue;
}

/// Applies a power while preserving the original number sign
double applyBlurHashSignPower(double value, double exponent) => (value.sign * pow(value.abs(), exponent)).toDouble();

/// Encodes an integer using the BlurHash Base83 alphabet
String encodeBlurHashBase83(int value, int length) {
  final buffer = StringBuffer();

  for (var index = 1; index <= length; index++) {
    final divisor = pow(83, length - index).toInt();
    final characterIndex = value ~/ divisor % 83;
    buffer.write(blurHashBase83Characters[characterIndex]);
  }

  return buffer.toString();
}

/// Checks the BlurHash alphabet and component-derived length
bool isValidBlurHash(String blurHash) {
  if (blurHash.length < 6 || blurHash.split('').any((character) => !blurHashBase83Characters.contains(character))) {
    return false;
  }

  final sizeFlag = blurHashBase83Characters.indexOf(blurHash[0]);
  final componentX = sizeFlag % 9 + 1;
  final componentY = sizeFlag ~/ 9 + 1;

  return blurHash.length == 4 + 2 * componentX * componentY;
}
