DateTime toYmd(DateTime d) {
  final localDate = d.toLocal();
  return DateTime(localDate.year, localDate.month, localDate.day);
}

bool isSameYmd(DateTime a, DateTime b) {
  final left = a.toLocal();
  final right = b.toLocal();

  return left.year == right.year && left.month == right.month && left.day == right.day;
}

/// Returns proper [DateTime] from passed `transactionDate` and `transactionTime`
DateTime? getTransactionDateTime({
  required DateTime? transactionDate,
  required DateTime? transactionTime,
}) {
  final day = transactionDate?.day;
  final month = transactionDate?.month;
  final year = transactionDate?.year;
  final hour = transactionTime?.hour;
  final minute = transactionTime?.minute;

  if (day != null && month != null && year != null && hour != null && minute != null) {
    return DateTime(year, month, day, hour, minute);
  }

  return null;
}
