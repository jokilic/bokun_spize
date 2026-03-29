import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

import '../util/color.dart';
import 'food.dart';
import 'nutrition.dart';

@HiveType(typeId: 1)
class Meal {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? emoji;
  @HiveField(3)
  final Color? color;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final Nutrition? nutrition;
  @HiveField(6)
  final List<Food>? foods;
  @HiveField(7)
  final String originalText;
  @HiveField(8)
  final bool isLoading;
  @HiveField(9)
  final List<String>? errors;

  Meal({
    required this.id,
    required this.createdAt,
    required this.originalText,
    required this.isLoading,
    this.name,
    this.emoji,
    this.color,
    this.nutrition,
    this.foods,
    this.errors,
  });

  Meal copyWith({
    String? id,
    String? name,
    String? emoji,
    Color? color,
    DateTime? createdAt,
    Nutrition? nutrition,
    List<Food>? foods,
    String? originalText,
    bool? isLoading,
    List<String>? errors,
  }) => Meal(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
    nutrition: nutrition ?? this.nutrition,
    foods: foods ?? this.foods,
    originalText: originalText ?? this.originalText,
    isLoading: isLoading ?? this.isLoading,
    errors: errors ?? this.errors,
  );

  factory Meal.fromMap(
    Map<String, dynamic> map, {
    required String id,
    required DateTime createdAt,
    required String originalText,
    required bool isLoading,
    required List<String>? errors,
  }) => Meal(
    id: id,
    name: map['name'],
    emoji: map['emoji'],
    color: map['color'] != null ? colorFromHex(map['color']) : null,
    createdAt: createdAt,
    nutrition: map['nutrition'] != null ? Nutrition.fromMap(map['nutrition'] as Map<String, dynamic>) : null,
    foods: map['foods'] != null ? List<Food>.from(map['foods'].map((x) => Food.fromMap(x))) : null,
    originalText: originalText,
    isLoading: isLoading,
    errors: errors,
  );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'color': color != null ? colorToHex(color!) : null,
    'createdAt': createdAt.toIso8601String(),
    'nutrition': nutrition?.toMap(),
    'foods': foods?.map((food) => food.toMap()).toList(),
    'originalText': originalText,
    'isLoading': isLoading,
    'errors': errors,
  };

  @override
  String toString() =>
      'Meal(id: $id, name: $name, emoji: $emoji, createdAt: $createdAt, nutrition: $nutrition, foods: $foods, originalText: $originalText, isLoading: $isLoading, errors: $errors)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          emoji == other.emoji &&
          createdAt == other.createdAt &&
          nutrition == other.nutrition &&
          foods == other.foods &&
          originalText == other.originalText &&
          isLoading == other.isLoading &&
          errors == other.errors;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ emoji.hashCode ^ createdAt.hashCode ^ nutrition.hashCode ^ foods.hashCode ^ originalText.hashCode ^ isLoading.hashCode ^ errors.hashCode;
}
