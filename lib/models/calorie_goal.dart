import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 7)
enum CalorieGoal {
  @HiveField(0)
  heavyDeficit,

  @HiveField(1)
  normalDeficit,

  @HiveField(2)
  lightDeficit,

  @HiveField(3)
  maintain,

  @HiveField(4)
  lightSurplus,

  @HiveField(5)
  normalSurplus,

  @HiveField(6)
  heavySurplus,
}

extension CalorieGoalX on CalorieGoal {
  double get multiplier => switch (this) {
    CalorieGoal.heavyDeficit => 0.75,
    CalorieGoal.normalDeficit => 0.85,
    CalorieGoal.lightDeficit => 0.95,
    CalorieGoal.maintain => 1.0,
    CalorieGoal.lightSurplus => 1.05,
    CalorieGoal.normalSurplus => 1.15,
    CalorieGoal.heavySurplus => 1.25,
  };
}
