import 'package:hive_ce/hive_ce.dart';

import 'food.dart';
import 'nutrition.dart';

@HiveType(typeId: 1)
class Meal {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final DateTime createdAt;
  @HiveField(3)
  final Nutrition? nutrition;
  @HiveField(4)
  final List<Food>? foods;
  @HiveField(5)
  final String originalText;
  @HiveField(6)
  final bool isLoading;
  @HiveField(6)
  final String? error;

  Meal({
    required this.id,
    required this.createdAt,
    required this.originalText,
    required this.isLoading,
    this.name,
    this.nutrition,
    this.foods,
    this.error,
  });

  Meal copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Nutrition? nutrition,
    List<Food>? foods,
    String? originalText,
    bool? isLoading,
    String? error,
  }) => Meal(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    nutrition: nutrition ?? this.nutrition,
    foods: foods ?? this.foods,
    originalText: originalText ?? this.originalText,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  factory Meal.fromMap(
    Map<String, dynamic> map, {
    required String id,
    required DateTime createdAt,
    required String originalText,
    required bool isLoading,
    required String? error,
  }) => Meal(
    id: id,
    name: map['name'],
    createdAt: createdAt,
    nutrition: map['nutrition'] != null ? Nutrition.fromMap(map['nutrition'] as Map<String, dynamic>) : null,
    foods: map['foods'] != null ? List<Food>.from(map['foods'].map((x) => Food.fromMap(x))) : null,
    originalText: originalText,
    isLoading: isLoading,
    error: error,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'nutrition': nutrition?.toMap(),
    'foods': foods?.map((food) => food.toMap()).toList(),
    'originalText': originalText,
    'isLoading': isLoading,
    'error': error,
  };

  @override
  String toString() => 'Meal(id: $id, name: $name, createdAt: $createdAt, nutrition: $nutrition, foods: $foods, originalText: $originalText, isLoading: $isLoading, error: $error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdAt == other.createdAt &&
          nutrition == other.nutrition &&
          foods == other.foods &&
          originalText == other.originalText &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ createdAt.hashCode ^ nutrition.hashCode ^ foods.hashCode ^ originalText.hashCode ^ isLoading.hashCode ^ error.hashCode;
}
