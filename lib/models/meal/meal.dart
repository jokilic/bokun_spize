import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../util/color.dart';
import 'food.dart';
import 'nutrition.dart';

class Meal {
  final String id;
  final String? name;
  final String? emoji;
  final Color? color;
  final DateTime createdAt;
  final Nutrition? nutrition;
  final List<Food>? foods;
  final String? originalText;
  final bool isLoading;
  final List<String>? errors;
  final String? imageStoragePath;
  final String? imageBlurHash;
  final String? methodOfCreation;

  Meal({
    required this.id,
    required this.createdAt,
    required this.isLoading,
    this.originalText,
    this.name,
    this.emoji,
    this.color,
    this.nutrition,
    this.foods,
    this.errors,
    this.imageStoragePath,
    this.imageBlurHash,
    this.methodOfCreation,
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
    String? imageStoragePath,
    String? imageBlurHash,
    String? methodOfCreation,
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
    imageStoragePath: imageStoragePath ?? this.imageStoragePath,
    imageBlurHash: imageBlurHash ?? this.imageBlurHash,
    methodOfCreation: methodOfCreation ?? this.methodOfCreation,
  );

  factory Meal.fromMap(
    Map<String, dynamic> map, {
    required String id,
    required DateTime createdAt,
    required String? originalText,
    required bool isLoading,
    required List<String>? errors,
    required String? imageStoragePath,
    required String? imageBlurHash,
  }) => Meal(
    id: id,
    name: map['name'],
    emoji: map['emoji'],
    color: map['color'] != null ? colorFromHex(map['color']) : null,
    createdAt: createdAt,
    nutrition: map['nutrition'] != null ? Nutrition.fromMap(map['nutrition'] as Map<String, dynamic>) : null,
    foods: (map['foods'] as List?)?.map(Food.tryFromMap).whereType<Food>().toList(),
    originalText: originalText,
    isLoading: isLoading,
    errors: errors,
    imageStoragePath: imageStoragePath,
    imageBlurHash: imageBlurHash,
    methodOfCreation: map['methodOfCreation'] as String?,
  );

  String toJson() => json.encode({
    ...toMap(),
    'createdAt': createdAt.toIso8601String(),
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'color': color != null ? colorToHex(color!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
    'nutrition': nutrition?.toMap(),
    'foods': foods?.map((food) => food.toMap()).toList(),
    'originalText': originalText,
    'isLoading': isLoading,
    'errors': errors,
    'imageStoragePath': imageStoragePath,
    'imageBlurHash': imageBlurHash,
    'methodOfCreation': methodOfCreation,
  };

  @override
  String toString() =>
      'Meal(id: $id, name: $name, emoji: $emoji, createdAt: $createdAt, nutrition: $nutrition, foods: $foods, originalText: $originalText, isLoading: $isLoading, errors: $errors, imageStoragePath: $imageStoragePath, imageBlurHash: $imageBlurHash, methodOfCreation: $methodOfCreation)';

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
          errors == other.errors &&
          imageStoragePath == other.imageStoragePath &&
          imageBlurHash == other.imageBlurHash &&
          methodOfCreation == other.methodOfCreation;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      emoji.hashCode ^
      createdAt.hashCode ^
      nutrition.hashCode ^
      foods.hashCode ^
      originalText.hashCode ^
      isLoading.hashCode ^
      errors.hashCode ^
      imageStoragePath.hashCode ^
      imageBlurHash.hashCode ^
      methodOfCreation.hashCode;
}
