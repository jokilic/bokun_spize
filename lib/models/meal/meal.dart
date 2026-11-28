import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';

import '../../util/color.dart';
import 'food.dart';
import 'meal_metadata.dart';
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
  final MealMetadata metadata;
  final Map<String, dynamic>? localizedData;

  Meal({
    required this.id,
    required this.createdAt,
    required this.isLoading,
    required this.metadata,
    this.originalText,
    this.name,
    this.emoji,
    this.color,
    this.nutrition,
    this.foods,
    this.errors,
    this.imageStoragePath,
    this.imageBlurHash,
    this.localizedData,
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
    MealMetadata? metadata,
    Map<String, dynamic>? localizedData,
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
    metadata: metadata ?? this.metadata,
    localizedData: localizedData ?? this.localizedData,
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
    Map<String, dynamic>? localizedData,
    Food? Function(Object?) parseFood = Food.tryFromMap,
  }) => Meal(
    id: id,
    name: map['name'],
    emoji: map['emoji'],
    color: map['color'] != null ? colorFromHex(map['color']) : null,
    createdAt: createdAt,
    nutrition: map['nutrition'] != null
        ? Nutrition.fromMap(
            map['nutrition'] as Map<String, dynamic>,
          )
        : null,
    foods: (map['foods'] as List?)?.map(parseFood).whereType<Food>().toList(),
    originalText: originalText,
    isLoading: isLoading,
    errors: errors,
    imageStoragePath: imageStoragePath,
    imageBlurHash: imageBlurHash,
    metadata: parseMealMetadata(map),
    localizedData: localizedData,
  );

  String toJson() {
    final data = localizedData == null ? toMap() : toLocalizedMap();

    return json.encode({
      ...data,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata.toMap(forJson: true),
    });
  }

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
    'metadata': metadata.toMap(),
  };

  Map<String, dynamic> toLocalizedMap() {
    final compactLocalizedData = localizedData;

    if (compactLocalizedData == null) {
      return toMap();
    }

    final data = toMap()
      ..remove('name')
      ..remove('emoji')
      ..remove('color')
      ..remove('nutrition')
      ..remove('foods');

    return {
      ...data,
      ...compactLocalizedData,
    };
  }

  Map<String, dynamic>? getEditedLocalizedData({
    required String editedName,
    required Nutrition? editedNutrition,
    required List<Food>? editedFoods,
  }) {
    final original = localizedData;

    if (original == null || editedName.trim() != (name?.trim() ?? '') || (editedFoods?.any((food) => food.hasNameChanged) ?? false)) {
      return null;
    }

    return {
      ...original,
      'nutrition': editedNutrition?.toMap(),
      'foods': editedFoods?.map((food) => food.toLocalizedMap()).toList(),
    };
  }

  @override
  String toString() =>
      'Meal(id: $id, name: $name, emoji: $emoji, createdAt: $createdAt, nutrition: $nutrition, foods: $foods, originalText: $originalText, isLoading: $isLoading, errors: $errors, imageStoragePath: $imageStoragePath, imageBlurHash: $imageBlurHash, metadata: $metadata, localizedData: $localizedData)';

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
          metadata == other.metadata &&
          localizedData == other.localizedData;

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
      metadata.hashCode ^
      localizedData.hashCode;
}
