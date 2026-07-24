class Nutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Nutrition copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) => Nutrition(
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
  );

  factory Nutrition.fromMap(Map<String, dynamic> map) => Nutrition(
    calories: (map['calories'] as num).toDouble(),
    protein: (map['protein'] as num).toDouble(),
    carbs: (map['carbs'] as num).toDouble(),
    fat: (map['fat'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };

  @override
  String toString() => 'Nutrition(calories: $calories, protein: $protein, carbs: $carbs, fat: $fat)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Nutrition && runtimeType == other.runtimeType && calories == other.calories && protein == other.protein && carbs == other.carbs && fat == other.fat;

  @override
  int get hashCode => calories.hashCode ^ protein.hashCode ^ carbs.hashCode ^ fat.hashCode;
}
