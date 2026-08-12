import 'package:intl/intl.dart';

String getDateString({required DateTime date}) {
  final now = DateTime.now();

  final today = DateTime.utc(now.year, now.month, now.day);
  final providedDate = DateTime.utc(date.year, date.month, date.day);

  final dayDifference = providedDate.difference(today).inDays;

  if (dayDifference == 0) {
    return 'Danas';
  }

  if (dayDifference == -1) {
    return 'Jučer';
  }

  if (dayDifference == 1) {
    return 'Sutra';
  }

  return DateFormat('EEEE, dd.MM.yyyy.', 'hr').format(date);
}
