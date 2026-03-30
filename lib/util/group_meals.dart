import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import '../models/day_header.dart';
import '../models/meal.dart';
import 'date_time.dart';

/// [DayHeader, Meal, Meal, DayHeader, ...]
List<Object> getGroupedMealsByDate(List<Meal> meals) {
  final today = toYmd(
    DateTime.now(),
  );

  final yesterday = DateTime(
    today.year,
    today.month,
    today.day - 1,
  );

  final dayFormatter = DateFormat(
    'dd. MMMM',
    'hr',
  );
  final dayFormatterYear = DateFormat(
    'dd. MMMM yyyy',
    'hr',
  );

  String labelFor(DateTime d) {
    if (isSameYmd(d, today)) {
      return 'Danas';
    }

    if (isSameYmd(d, yesterday)) {
      return 'Jučer';
    }

    return d.year == today.year ? dayFormatter.format(d) : dayFormatterYear.format(d);
  }

  final grouped = groupBy<Meal, DateTime>(
    meals,
    (t) => toYmd(t.createdAt),
  );

  final days = grouped.keys.toList()
    ..sort(
      (a, b) => b.compareTo(a),
    );

  final items = <Object>[];

  for (final day in days) {
    final dayMeals = [...grouped[day]!]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final amountCalories = dayMeals.fold<double>(
      0,
      (sum, meal) => sum + (meal.nutrition?.calories ?? 0),
    );

    items
      ..add(
        DayHeader(
          label: labelFor(
            toYmd(day),
          ),
          amountCalories: amountCalories,
          day: day,
        ),
      )
      ..addAll(dayMeals);
  }

  return items;
}
