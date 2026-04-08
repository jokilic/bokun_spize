DateTime toYmd(DateTime d) {
  final localDate = d.toLocal();
  return DateTime(localDate.year, localDate.month, localDate.day);
}

bool isSameYmd(DateTime a, DateTime b) {
  final left = a.toLocal();
  final right = b.toLocal();

  return left.year == right.year && left.month == right.month && left.day == right.day;
}

/// Returns proper [DateTime] from passed `mealDate` and `mealTime`
DateTime? getMealDateTime({
  required DateTime? mealDate,
  required DateTime? mealTime,
}) {
  final day = mealDate?.day;
  final month = mealDate?.month;
  final year = mealDate?.year;
  final hour = mealTime?.hour;
  final minute = mealTime?.minute;

  if (day != null && month != null && year != null && hour != null && minute != null) {
    return DateTime(year, month, day, hour, minute);
  }

  return null;
}
