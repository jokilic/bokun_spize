import 'package:flutter/material.dart';

import '../../util/color.dart';
import 'nutrition.dart';

class Food {
  final String name;
  final double quantity;
  final String unit;
  final Nutrition nutrition;
  final String? emoji;
  final Color? color;

  Food({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutrition,
    this.emoji,
    this.color,
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
  );

  factory Food.fromMap(Map<String, dynamic> map) => Food(
    name: map['name'],
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'],
    nutrition: Nutrition.fromMap(map['nutrition'] as Map<String, dynamic>),
    emoji: map['emoji'],
    color: map['color'] != null ? colorFromHex(map['color']) : null,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'nutrition': nutrition.toMap(),
    'emoji': emoji,
    'color': color != null ? colorToHex(color!) : null,
  };

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
