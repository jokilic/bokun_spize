import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/hive_registrar.g.dart';
import '../models/meal.dart';
import '../util/group_meals.dart';
import '../util/path.dart';
import 'logger_service.dart';

class HiveService extends ValueNotifier<List<Object>> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final LoggerService logger;

  HiveService({
    required this.logger,
  }) : super([]);

  ///
  /// VARIABLES
  ///

  late final Box<Meal> meals;

  ///
  /// INIT
  ///

  Future<void> init() async {
    final directory = await getHiveDirectory();

    Hive
      ..init(directory?.path)
      ..registerAdapters();

    meals = await Hive.openBox<Meal>('mealsBox');

    await deleteLoadingMeals();

    updateState();
  }

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    await meals.close();
    await Hive.close();
  }

  ///
  /// METHODS
  ///

  /// Deletes all `meals` with `isLoading` in [Hive]
  Future<void> deleteLoadingMeals() async {
    final staleLoadingMealKeys = meals.keys
        .where(
          (key) => meals.get(key)?.isLoading ?? false,
        )
        .toList();

    if (staleLoadingMealKeys.isNotEmpty) {
      await meals.deleteAll(staleLoadingMealKeys);
    }
  }

  /// Called to get `meals` from [Hive]
  List<Meal> getMeals() => meals.values.toList();

  /// Stores a new `meal` in [Hive]
  Future<void> writeMeal({required Meal newMeal}) async {
    await meals.add(newMeal);
    updateState();
  }

  /// Deletes a `meal` in [Hive]
  Future<void> deleteMeal({required Meal meal}) async {
    final i = getMeals().indexWhere((m) => m.id == meal.id);

    if (i == -1) {
      return;
    }

    final key = meals.keyAt(i);
    await meals.delete(key);
    updateState();
  }

  /// Updates a `meal` in [Hive]
  Future<void> updateMeal({required Meal newMeal}) async {
    final i = getMeals().indexWhere((m) => m.id == newMeal.id);

    if (i == -1) {
      return;
    }

    final key = meals.keyAt(i);
    await meals.put(key, newMeal);
    updateState();
  }

  /// Updates grouped `state`
  void updateState({List<Meal>? newMeals}) => value = getGroupedMealsByDate(
    newMeals ?? getMeals(),
  );
}

String getDayHeaderLabel(
  DateTime day, {
  required DateTime today,
  required DateTime yesterday,
  required String locale,
  required DateFormat dayFormatter,
  required DateFormat dayFormatterYear,
}) {
  if (day == today) {
    return locale == 'hr' ? 'Danas' : 'Today';
  }

  if (day == yesterday) {
    return locale == 'hr' ? 'Jučer' : 'Yesterday';
  }

  return day.year == today.year ? dayFormatter.format(day) : dayFormatterYear.format(day);
}
