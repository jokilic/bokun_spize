class Nutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
  });

  Nutrition copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? sugar,
  }) => Nutrition(
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    sugar: sugar ?? this.sugar,
  );

  factory Nutrition.fromMap(Map<String, dynamic> map) => Nutrition(
    calories: (map['calories'] as num).toDouble(),
    protein: (map['protein'] as num).toDouble(),
    carbs: (map['carbs'] as num).toDouble(),
    fat: (map['fat'] as num).toDouble(),
    sugar: (map['sugar'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'sugar': sugar,
  };

  @override
  String toString() => 'Nutrition(calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, sugar: $sugar)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Nutrition &&
          runtimeType == other.runtimeType &&
          calories == other.calories &&
          protein == other.protein &&
          carbs == other.carbs &&
          fat == other.fat &&
          sugar == other.sugar;

  @override
  int get hashCode => calories.hashCode ^ protein.hashCode ^ carbs.hashCode ^ fat.hashCode ^ sugar.hashCode;
}
