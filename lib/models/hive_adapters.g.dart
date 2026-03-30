// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class MealAdapter extends TypeAdapter<Meal> {
  @override
  final typeId = 0;

  @override
  Meal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meal(
      id: fields[0] as String,
      createdAt: fields[6] as DateTime,
      originalText: fields[5] as String,
      isLoading: fields[7] as bool,
      name: fields[1] as String?,
      emoji: fields[9] as String?,
      color: fields[11] as Color?,
      nutrition: fields[3] as Nutrition?,
      foods: (fields[4] as List?)?.cast<Food>(),
      errors: (fields[10] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Meal obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.nutrition)
      ..writeByte(4)
      ..write(obj.foods)
      ..writeByte(5)
      ..write(obj.originalText)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isLoading)
      ..writeByte(9)
      ..write(obj.emoji)
      ..writeByte(10)
      ..write(obj.errors)
      ..writeByte(11)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionAdapter extends TypeAdapter<Nutrition> {
  @override
  final typeId = 1;

  @override
  Nutrition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nutrition(
      calories: (fields[0] as num).toDouble(),
      protein: (fields[1] as num).toDouble(),
      carbs: (fields[2] as num).toDouble(),
      fat: (fields[3] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Nutrition obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.calories)
      ..writeByte(1)
      ..write(obj.protein)
      ..writeByte(2)
      ..write(obj.carbs)
      ..writeByte(3)
      ..write(obj.fat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodAdapter extends TypeAdapter<Food> {
  @override
  final typeId = 2;

  @override
  Food read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Food(
      name: fields[0] as String,
      quantity: (fields[1] as num).toDouble(),
      unit: fields[2] as String,
      nutrition: fields[4] as Nutrition,
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.nutrition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final typeId = 3;

  @override
  Color read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Color((fields[0] as num).toInt());
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
