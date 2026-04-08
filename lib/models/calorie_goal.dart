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

  String get name => switch (this) {
    CalorieGoal.heavyDeficit => 'Intenzivni deficit',
    CalorieGoal.normalDeficit => 'Normalni deficit',
    CalorieGoal.lightDeficit => 'Lagani deficit',
    CalorieGoal.maintain => 'Održavanje',
    CalorieGoal.lightSurplus => 'Lagani suficit',
    CalorieGoal.normalSurplus => 'Normalni suficit',
    CalorieGoal.heavySurplus => 'Intenzivni suficit',
  };

  String get description => switch (this) {
    CalorieGoal.heavyDeficit => 'Brzi gubitak težine.',
    CalorieGoal.normalDeficit => 'Uravnotežen gubitak težine.',
    CalorieGoal.lightDeficit => 'Lagani gubitak težine.',
    CalorieGoal.maintain => 'Održavanje težine.',
    CalorieGoal.lightSurplus => 'Lagani dobitak težine.',
    CalorieGoal.normalSurplus => 'Uravnotežen dobitak težine.',
    CalorieGoal.heavySurplus => 'Brzi dobitak težine.',
  };
}
