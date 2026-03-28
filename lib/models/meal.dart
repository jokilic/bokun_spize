import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../util/parsing.dart';
import 'food.dart';
import 'nutrition.dart';

@HiveType(typeId: 1)
class Meal {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final DateTime postedAt;
  @HiveField(3)
  final Nutrition nutrition;
  @HiveField(4)
  final List<Food> foods;
  @HiveField(5)
  final String originalText;

  // final MealType? mealType;
  // final String? note;

  Meal({
    required this.id,
    required this.name,
    required this.postedAt,
    required this.nutrition,
    required this.foods,
    required this.originalText,
  });

  factory Meal.fromMap(
    Map<String, dynamic> map, {
    required String id,
    required DateTime postedAt,
    required String originalText,
  }) => Meal(
    id: id,
    name: map['name'],
    postedAt: postedAt,
    nutrition: Nutrition.fromMap(decodeMap(map['nutrition'])),
    foods: decodeList(map['foods']).map<Food>((food) => Food.fromMap(decodeMap(food))).toList(),
    originalText: originalText,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'postedAt': postedAt.toIso8601String(),
    'nutrition': nutrition.toMap(),
    'foods': foods.map((food) => food.toMap()).toList(),
    'originalText': originalText,
  };
}
