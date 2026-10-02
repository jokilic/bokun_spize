enum ActivityLevel {
  sedentary,
  lightExercise,
  moderateExercise,
  heavyExercise,
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
