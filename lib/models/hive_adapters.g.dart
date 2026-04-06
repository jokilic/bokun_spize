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
      isLoading: fields[7] as bool,
      originalText: fields[5] as String?,
      name: fields[1] as String?,
      emoji: fields[9] as String?,
      color: fields[11] as Color?,
      nutrition: fields[3] as Nutrition?,
      foods: (fields[4] as List?)?.cast<Food>(),
      errors: (fields[10] as List?)?.cast<String>(),
      imageFilePath: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Meal obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.color)
      ..writeByte(12)
      ..write(obj.imageFilePath);
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

class ActivityLevelAdapter extends TypeAdapter<ActivityLevel> {
  @override
  final typeId = 4;

  @override
  ActivityLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityLevel.sedentary;
      case 1:
        return ActivityLevel.lightExercise;
      case 2:
        return ActivityLevel.moderateExercise;
      case 3:
        return ActivityLevel.heavyExercise;
      case 4:
        return ActivityLevel.athlete;
      default:
        return ActivityLevel.sedentary;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityLevel obj) {
    switch (obj) {
      case ActivityLevel.sedentary:
        writer.writeByte(0);
      case ActivityLevel.lightExercise:
        writer.writeByte(1);
      case ActivityLevel.moderateExercise:
        writer.writeByte(2);
      case ActivityLevel.heavyExercise:
        writer.writeByte(3);
      case ActivityLevel.athlete:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SexAdapter extends TypeAdapter<Sex> {
  @override
  final typeId = 5;

  @override
  Sex read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Sex.male;
      case 1:
        return Sex.female;
      default:
        return Sex.male;
    }
  }

  @override
  void write(BinaryWriter writer, Sex obj) {
    switch (obj) {
      case Sex.male:
        writer.writeByte(0);
      case Sex.female:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SexAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CalorieGoalAdapter extends TypeAdapter<CalorieGoal> {
  @override
  final typeId = 6;

  @override
  CalorieGoal read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CalorieGoal.heavyDeficit;
      case 1:
        return CalorieGoal.normalDeficit;
      case 2:
        return CalorieGoal.lightDeficit;
      case 3:
        return CalorieGoal.maintain;
      case 4:
        return CalorieGoal.lightSurplus;
      case 5:
        return CalorieGoal.normalSurplus;
      case 6:
        return CalorieGoal.heavySurplus;
      default:
        return CalorieGoal.heavyDeficit;
    }
  }

  @override
  void write(BinaryWriter writer, CalorieGoal obj) {
    switch (obj) {
      case CalorieGoal.heavyDeficit:
        writer.writeByte(0);
      case CalorieGoal.normalDeficit:
        writer.writeByte(1);
      case CalorieGoal.lightDeficit:
        writer.writeByte(2);
      case CalorieGoal.maintain:
        writer.writeByte(3);
      case CalorieGoal.lightSurplus:
        writer.writeByte(4);
      case CalorieGoal.normalSurplus:
        writer.writeByte(5);
      case CalorieGoal.heavySurplus:
        writer.writeByte(6);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalorieGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserMetricsAdapter extends TypeAdapter<UserMetrics> {
  @override
  final typeId = 7;

  @override
  UserMetrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserMetrics(
      age: (fields[0] as num).toInt(),
      height: (fields[1] as num).toDouble(),
      weight: (fields[2] as num).toDouble(),
      activity: fields[3] as ActivityLevel,
      sex: fields[4] as Sex,
      calorieGoal: fields[5] as CalorieGoal,
    );
  }

  @override
  void write(BinaryWriter writer, UserMetrics obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.age)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.activity)
      ..writeByte(4)
      ..write(obj.sex)
      ..writeByte(5)
      ..write(obj.calorieGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMetricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
