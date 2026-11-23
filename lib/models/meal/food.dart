import 'package:material_ui/material_ui.dart';

import '../../util/color.dart';
import 'nutrition.dart';

class Food {
  final String name;
  final double quantity;
  final String unit;
  final Nutrition nutrition;
  final String? emoji;
  final Color? color;
  final ({String name, String unit, Map<String, dynamic> data})? localizedData;

  Food({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutrition,
    this.emoji,
    this.color,
    this.localizedData,
  });

  Food copyWith({
    String? name,
    double? quantity,
    String? unit,
    Nutrition? nutrition,
    String? emoji,
    Color? color,
  }) => Food(
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    nutrition: nutrition ?? this.nutrition,
    emoji: emoji ?? this.emoji,
    color: color ?? this.color,
    localizedData: localizedData,
  );

  factory Food.fromMap(
    Map<String, dynamic> map, {
    Map<String, dynamic>? localizedData,
  }) => Food(
    name: map['name'],
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'],
    nutrition: Nutrition.fromMap(map['nutrition'] as Map<String, dynamic>),
    emoji: map['emoji'],
    color: map['color'] != null ? colorFromHex(map['color']) : null,
    localizedData: localizedData == null ? null : (name: map['name'] as String, unit: map['unit'] as String, data: localizedData),
  );

  static Food? tryFromMap(Object? value, {Map<String, dynamic>? localizedData}) {
    try {
      return value is Map ? Food.fromMap(Map<String, dynamic>.from(value), localizedData: localizedData) : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'nutrition': nutrition.toMap(),
    'emoji': emoji,
    'color': color != null ? colorToHex(color!) : null,
  };

  bool get hasNameChanged {
    final original = localizedData;
    return original != null && name.trim() != original.name.trim();
  }

  Map<String, dynamic> toLocalizedMap() {
    final original = localizedData;

    if (original == null) {
      return toMap();
    }

    return {
      ...original.data,
      'name': hasNameChanged ? name : original.data['name'],
      'quantity': quantity,
      'unit': unit.trim() == original.unit.trim() ? original.data['unit'] : unit,
      'nutrition': nutrition.toMap(),
    };
  }

  @override
  String toString() => 'Food(name: $name, quantity: $quantity, unit: $unit, nutrition: $nutrition, emoji: $emoji, color: $color)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          quantity == other.quantity &&
          unit == other.unit &&
          nutrition == other.nutrition &&
          emoji == other.emoji &&
          color == other.color;

  @override
  int get hashCode => name.hashCode ^ quantity.hashCode ^ unit.hashCode ^ nutrition.hashCode ^ emoji.hashCode ^ color.hashCode;
}
