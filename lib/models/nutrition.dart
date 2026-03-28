import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 2)
class Nutrition {
  @HiveField(0)
  final double calories;
  @HiveField(1)
  final double protein;
  @HiveField(2)
  final double carbs;
  @HiveField(3)
  final double fat;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory Nutrition.fromMap(Map<String, dynamic> map) => Nutrition(
    calories: map['calories'],
    protein: map['protein'],
    carbs: map['carbs'],
    fat: map['fat'],
  );

  Map<String, dynamic> toMap() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };
}
