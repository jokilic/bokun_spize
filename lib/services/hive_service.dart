import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/meal.dart';
import '../util/path.dart';
import 'logger_service.dart';

class HiveService extends ValueNotifier<List<Meal>> implements Disposable {
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

  /// Called to get `meals` from [Hive]
  List<Meal> getMeals() => meals.values.toList();

  /// Clears old list and stores a new `List<Meal>` in [Hive]
  Future<void> writeListMeals(List<Meal> newMeals) async {
    await meals.clear();
    await meals.addAll(newMeals);
  }

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

  /// Updates `state`
  void updateState({List<Meal>? newMeals}) => value = newMeals ?? getMeals();
}
