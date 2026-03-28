import 'package:hive_ce/hive_ce.dart';

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
}
