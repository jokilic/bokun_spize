import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 3)
class Food {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double quantity;
  @HiveField(2)
  final String unit;

  Food({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Food copyWith({
    String? name,
    double? quantity,
    String? unit,
  }) => Food(
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
  );

  factory Food.fromMap(Map<String, dynamic> map) => Food(
    name: map['name'],
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'],
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
  };

  @override
  String toString() => 'Food(name: $name, quantity: $quantity, unit: $unit)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Food && runtimeType == other.runtimeType && name == other.name && quantity == other.quantity && unit == other.unit;

  @override
  int get hashCode => name.hashCode ^ quantity.hashCode ^ unit.hashCode;
}
