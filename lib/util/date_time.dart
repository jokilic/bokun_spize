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
      return 'Danas';
    }

    if (dayDifference == -1) {
      return 'Jučer';
    }

    if (dayDifference == 1) {
      return 'Sutra';
    }
  }

  return DateFormat(dateFormat, 'hr').format(date);
}
