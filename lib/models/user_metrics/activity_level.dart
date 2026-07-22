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

  String get name => switch (this) {
    ActivityLevel.sedentary => 'Sjedilački',
    ActivityLevel.lightExercise => 'Lagana aktivnost',
    ActivityLevel.moderateExercise => 'Umjerena aktivnost',
    ActivityLevel.heavyExercise => 'Intenzivna aktivnost',
    ActivityLevel.athlete => 'Sportaš',
  };

  String get description => switch (this) {
    ActivityLevel.sedentary => 'Nikakva ili minimalna tjelovježba.',
    ActivityLevel.lightExercise => 'Lagana tjelovježba 1-2 dana u tjednu.',
    ActivityLevel.moderateExercise => 'Umjerena tjelovježba 3-5 dana u tjednu.',
    ActivityLevel.heavyExercise => 'Intenzivna tjelovježba 6-7 dana u tjednu.',
    ActivityLevel.athlete => 'Intenzivna tjelovježba dvaput dnevno.',
  };
}
