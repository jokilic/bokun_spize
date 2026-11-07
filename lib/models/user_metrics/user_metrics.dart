import 'package:cloud_firestore/cloud_firestore.dart';

import '../../util/typedefs.dart';

enum Gender {
  male,
  female,
}

class UserMetrics {
  final DateTime? registeredAt;
  final String? name;
  final int? age;
  final double? height;
  final double? weight;
  final Gender? gender;
  final double? dailyCalories;
  final double? dailyProtein;
  final double? dailyCarbs;
  final double? dailyFat;
  final bool? isAdmin;

  UserMetrics({
    this.registeredAt,
    this.name,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.dailyCalories,
    this.dailyProtein,
    this.dailyCarbs,
    this.dailyFat,
    this.isAdmin,
  });

  UserMetrics copyWith({
    DateTime? registeredAt,
    String? name,
    int? age,
    double? height,
    double? weight,
    Gender? gender,
    double? dailyCalories,
    double? dailyProtein,
    double? dailyCarbs,
    double? dailyFat,
    bool? isAdmin,
  }) => UserMetrics(
    registeredAt: registeredAt ?? this.registeredAt,
    name: name ?? this.name,
    age: age ?? this.age,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    gender: gender ?? this.gender,
    dailyCalories: dailyCalories ?? this.dailyCalories,
    dailyProtein: dailyProtein ?? this.dailyProtein,
    dailyCarbs: dailyCarbs ?? this.dailyCarbs,
    dailyFat: dailyFat ?? this.dailyFat,
    isAdmin: isAdmin ?? this.isAdmin,
  );

  factory UserMetrics.fromMap(Map<String, dynamic> map) {
    final registeredAt = map['registeredAt'];

    return UserMetrics(
      registeredAt: switch (registeredAt) {
        final Timestamp value => value.toDate(),
        final DateTime value => value,
        final String value => DateTime.tryParse(value),
        _ => null,
      },
      name: map['name'] as String?,
      age: (map['age'] as num?)?.toInt(),
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      gender: map['gender'] != null ? Gender.values.byName(map['gender'] as String) : null,
      dailyCalories: (map['dailyCalories'] as num?)?.toDouble(),
      dailyProtein: (map['dailyProtein'] as num?)?.toDouble(),
      dailyCarbs: (map['dailyCarbs'] as num?)?.toDouble(),
      dailyFat: (map['dailyFat'] as num?)?.toDouble(),
      isAdmin: map['isAdmin'] as bool?,
    );
  }

  Map<String, dynamic> toMap({bool includeMetrics = true}) => {
    if (registeredAt != null) 'registeredAt': registeredAt,
    if (name != null) 'name': name,
    if (includeMetrics) ...{
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender?.name,
      'dailyCalories': dailyCalories,
      'dailyProtein': dailyProtein,
      'dailyCarbs': dailyCarbs,
      'dailyFat': dailyFat,
    },
    if (isAdmin != null) 'isAdmin': isAdmin,
  };

  @override
  String toString() =>
      'UserMetrics(registeredAt: $registeredAt, name: $name, age: $age, height: $height, weight: $weight, gender: $gender, dailyCalories: $dailyCalories, dailyProtein: $dailyProtein, dailyCarbs: $dailyCarbs, dailyFat: $dailyFat, isAdmin: $isAdmin)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMetrics &&
          runtimeType == other.runtimeType &&
          registeredAt == other.registeredAt &&
          name == other.name &&
          age == other.age &&
          height == other.height &&
          weight == other.weight &&
          gender == other.gender &&
          dailyCalories == other.dailyCalories &&
          dailyProtein == other.dailyProtein &&
          dailyCarbs == other.dailyCarbs &&
          dailyFat == other.dailyFat &&
          isAdmin == other.isAdmin;

  @override
  int get hashCode =>
      registeredAt.hashCode ^
      name.hashCode ^
      age.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      gender.hashCode ^
      dailyCalories.hashCode ^
      dailyProtein.hashCode ^
      dailyCarbs.hashCode ^
      dailyFat.hashCode ^
      isAdmin.hashCode;

  double? get bmr {
    final currentWeight = weight;
    final currentHeight = height;
    final currentAge = age;

    if (currentWeight == null || currentHeight == null || currentAge == null || gender == null) {
      return null;
    }

    if (gender == Gender.male) {
      return (10 * currentWeight) + (6.25 * currentHeight) - (5 * currentAge) + 5;
    } else {
      return (10 * currentWeight) + (6.25 * currentHeight) - (5 * currentAge) - 161;
    }
  }

  double? get tdee {
    final basalMetabolicRate = bmr;

    if (basalMetabolicRate == null) {
      return null;
    }

    return basalMetabolicRate * 1.55;
  }

  DailyMacroValues? get dailyMacroValues => calculateDailyMacroValues(dailyCalories);

  DailyMacroValues? calculateDailyMacroValues(double? calories) {
    final currentWeight = weight;
    final currentCalories = calories ?? tdee?.roundToDouble();

    if (currentWeight == null || currentCalories == null) {
      return null;
    }

    final protein = (currentWeight * 1.6).roundToDouble();
    final fat = (currentWeight * 0.8).roundToDouble();
    final remainingCalories = currentCalories - (protein * 4) - (fat * 9);
    final carbs = remainingCalories > 0 ? (remainingCalories / 4).roundToDouble() : 0.0;

    return (
      calories: currentCalories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }
}
