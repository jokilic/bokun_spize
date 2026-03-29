class DayHeader {
  final String label;
  final double amountCalories;
  final DateTime day;

  const DayHeader({
    required this.label,
    required this.amountCalories,
    required this.day,
  });

  @override
  String toString() => 'DayHeader(label: $label, amountCalories: $amountCalories, day: $day)';

  @override
  bool operator ==(covariant DayHeader other) {
    if (identical(this, other)) {
      return true;
    }

    return other.label == label && other.amountCalories == amountCalories && other.day == day;
  }

  @override
  int get hashCode => label.hashCode ^ amountCalories.hashCode ^ day.hashCode;
}
