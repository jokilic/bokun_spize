import 'package:hive_ce/hive_ce.dart';

import 'nutrition.dart';

@HiveType(typeId: 3)
class Food {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double quantity;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final Nutrition nutrition;

  Food({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutrition,
  });

  Food copyWith({
    String? name,
    double? quantity,
    String? unit,
    Nutrition? nutrition,
  }) => Food(
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    nutrition: nutrition ?? this.nutrition,
  );

  factory Food.fromMap(Map<String, dynamic> map) => Food(
    name: map['name'],
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'],
    nutrition: Nutrition.fromMap(map['nutrition'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'nutrition': nutrition.toMap(),
  };

  @override
  String toString() => 'Food(name: $name, quantity: $quantity, unit: $unit, nutrition: $nutrition)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food && runtimeType == other.runtimeType && name == other.name && quantity == other.quantity && unit == other.unit && nutrition == other.nutrition;

  @override
  int get hashCode => name.hashCode ^ quantity.hashCode ^ unit.hashCode ^ nutrition.hashCode;
}
