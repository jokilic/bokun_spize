double parseNumberForFood(String passedValue) {
  final value = double.tryParse(passedValue);
  return value != null && value.isFinite ? value : 0;
}
