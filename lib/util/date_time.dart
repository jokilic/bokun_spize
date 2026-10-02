import 'package:easy_localization/easy_localization.dart';

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
  required String languageCode,
  bool useTodayYesterdayTomorrow = true,
}) {
  final now = DateTime.now();

  final today = DateTime.utc(now.year, now.month, now.day);
  final providedDate = DateTime.utc(date.year, date.month, date.day);

  final dayDifference = providedDate.difference(today).inDays;

  if (useTodayYesterdayTomorrow) {
    if (dayDifference == 0) {
      return 'today'.tr();
    }

    if (dayDifference == -1) {
      return 'yesterday'.tr();
    }

    if (dayDifference == 1) {
      return 'tomorrow'.tr();
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
