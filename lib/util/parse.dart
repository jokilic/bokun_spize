import 'typedefs.dart';

double parseNumberForFood(String passedValue) {
  final value = double.tryParse(passedValue);
  return value != null && value.isFinite ? value : 0;
}

/// Requires a date and either nonblank text or an image
bool isValidAIMealResult(AIMealResult result) {
  final hasWords = result.words?.trim().isNotEmpty ?? false;
  final hasImage = result.imageFile != null;

  return result.dateTime != null && (hasWords || hasImage);
}
