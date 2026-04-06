import 'package:hive_ce/hive_ce.dart';

import 'activity_level.dart';
import 'calorie_goal.dart';
import 'sex.dart';

@HiveType(typeId: 4)
class UserMetrics {
  @HiveField(0)
  final int age;

  @HiveField(1)
  final double height;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final ActivityLevel activity;

  @HiveField(4)
  final Sex sex;

  @HiveField(5)
  final CalorieGoal calorieGoal;

  UserMetrics({
    required this.age,
    required this.height,
    required this.weight,
    required this.activity,
    required this.sex,
    required this.calorieGoal,
  });

  UserMetrics copyWith({
    int? age,
    double? height,
    double? weight,
    ActivityLevel? activity,
    Sex? sex,
    CalorieGoal? calorieGoal,
  }) => UserMetrics(
    age: age ?? this.age,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    activity: activity ?? this.activity,
    sex: sex ?? this.sex,
    calorieGoal: calorieGoal ?? this.calorieGoal,
  );

  double get bmr {
    if (sex == Sex.male) {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double get tdee => bmr * activity.multiplier;

  double get dailyCalorieGoal => tdee * calorieGoal.multiplier;
}
