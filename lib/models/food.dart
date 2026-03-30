import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 3)
class Food {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double quantity;
  @HiveField(2)
  final String unit;
  @HiveField(3)
  final double calories;

  Food({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
  });

  Food copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? calories,
  }) => Food(
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    calories: calories ?? this.calories,
  );

  factory Food.fromMap(Map<String, dynamic> map) => Food(
    name: map['name'],
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'],
    calories: (map['calories'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'calories': calories,
  };

  @override
  String toString() => 'Food(name: $name, quantity: $quantity, unit: $unit, calories: $calories)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food && runtimeType == other.runtimeType && name == other.name && quantity == other.quantity && unit == other.unit && calories == other.calories;

  @override
  int get hashCode => name.hashCode ^ quantity.hashCode ^ unit.hashCode ^ calories.hashCode;
}
