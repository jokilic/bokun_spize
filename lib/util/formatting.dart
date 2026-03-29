String? formatNutritionValue(num? value) {
  if (value == null) {
    return null;
  }

  /// Keep labels like `3` or `0.2` while avoiding 3.0
  final formattedValue = value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  return formattedValue;
}

String? capitalizeFirstLetter(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final firstCharacter = value[0].toUpperCase();

  if (value.length == 1) {
    return firstCharacter;
  }

  return '$firstCharacter${value.substring(1)}';
}
