import 'package:intl/intl.dart';

/// Rounds a date and time up to the next five-minute interval
DateTime roundUpToFiveMinuteInterval(DateTime dateTime) {
  final minutesToAdd = (5 - dateTime.minute % 5) % 5;

  return DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute + minutesToAdd,
  );
}

String getDateString({
  required DateTime date,
  required String dateFormat,
  // TODO: Replace hardcoded 'en' with `context.locale.languageCode`
  String languageCode = 'en',
  bool useTodayYesterdayTomorrow = true,
}) {
  final now = DateTime.now();

  final today = DateTime.utc(now.year, now.month, now.day);
  final providedDate = DateTime.utc(date.year, date.month, date.day);

  final dayDifference = providedDate.difference(today).inDays;

  if (useTodayYesterdayTomorrow) {
    if (dayDifference == 0) {
      return 'Today';
    }

    if (dayDifference == -1) {
      return 'Yesterday';
    }

    if (dayDifference == 1) {
      return 'Tomorrow';
    }
  }

  return DateFormat(dateFormat, languageCode).format(date);
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
