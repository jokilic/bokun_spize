import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/hive_registrar.g.dart';
import '../models/meal.dart';
import '../models/user_metrics.dart';
import '../util/group_meals.dart';
import '../util/path.dart';

class HiveService extends ValueNotifier<({List<Object> items, UserMetrics? userMetrics})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  HiveService() : super((items: [], userMetrics: null));

  ///
  /// VARIABLES
  ///

  late final Box<Meal> meals;
  late final Box<UserMetrics> userMetrics;

  ///
  /// INIT
  ///

  Future<void> init() async {
    final directory = await getHiveDirectory();

    Hive
      ..init(directory?.path)
      ..registerAdapters();

    meals = await Hive.openBox<Meal>('mealsBox');
    userMetrics = await Hive.openBox<UserMetrics>('userMetricsBox');

    await deleteLoadingMeals();

    updateState();
  }

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    await meals.close();
    await userMetrics.close();

    await Hive.close();
  }

  ///
  /// METHODS
  ///

  /// Updates grouped `state`
  void updateState({
    List<Meal>? newMeals,
    UserMetrics? newUserMetrics,
  }) => value = (
    items: getGroupedMealsByDate(
      newMeals ?? getMeals(),
    ),
    userMetrics: newUserMetrics ?? getUserMetrics(),
  );

  ///
  /// MEALS
  ///

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

  ///
  /// USER METRICS
  ///

  /// Called to get `userMetrics` from [Hive]
  UserMetrics? getUserMetrics() => userMetrics.get(0);

  /// Stores a new `userMetrics` in [Hive]
  Future<void> writeUserMetrics({required UserMetrics newUserMetrics}) async {
    await userMetrics.put(0, newUserMetrics);
    updateState();
  }

  /// Deletes `userMetrics` from [Hive]
  Future<void> deleteUserMetrics() async {
    await userMetrics.clear();
    updateState();
  }
}
