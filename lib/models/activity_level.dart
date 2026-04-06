import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 5)
enum ActivityLevel {
  @HiveField(0)
  sedentary,

  @HiveField(1)
  lightExercise,

  @HiveField(2)
  moderateExercise,

  @HiveField(3)
  heavyExercise,

  @HiveField(4)
  athlete,
}

extension ActivityLevelX on ActivityLevel {
  double get multiplier => switch (this) {
    ActivityLevel.sedentary => 1.2,
    ActivityLevel.lightExercise => 1.375,
    ActivityLevel.moderateExercise => 1.55,
    ActivityLevel.heavyExercise => 1.725,
    ActivityLevel.athlete => 1.9,
  };
}
