import 'package:intl/intl.dart';

String getDateString({required DateTime date}) {
  final now = DateTime.now();

  final today = DateTime.utc(now.year, now.month, now.day);
  final providedDate = DateTime.utc(date.year, date.month, date.day);

  final dayDifference = providedDate.difference(today).inDays;

  if (dayDifference == 0) {
    return 'Today';
  }

  if (dayDifference == -1) {
    return 'Yesterday';
  }

  if (dayDifference == 1) {
    return 'Tomorrow';
  }

  return DateFormat('EEEE, dd.MM.yyyy.', 'hr').format(date);
}
