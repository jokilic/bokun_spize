import 'format.dart';
import 'typedefs.dart';

/// Parses a serving or nutrition input and keeps the original precision if the field is unchanged
double parseNumberForFood(String passedValue, {double? originalValue}) {
  if (originalValue != null && passedValue == formatNutritionValue(originalValue)) {
    return originalValue;
  }

  final value = double.tryParse(passedValue);
  return value != null && value.isFinite ? value : 0;
}

/// Requires a date and either nonblank text or an image
bool isValidAIMealResult(AIMealResult result) {
  final hasWords = result.words?.trim().isNotEmpty ?? false;
  final hasImage = result.imageFile != null;

  return result.dateTime != null && (hasWords || hasImage);
}
