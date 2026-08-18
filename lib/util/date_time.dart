import 'package:intl/intl.dart';

String getDateString({
  required DateTime date,
  required String dateFormat,
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

  return DateFormat(dateFormat, 'en').format(date);
}
