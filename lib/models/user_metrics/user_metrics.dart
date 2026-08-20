import 'activity_level.dart';
import 'sex.dart';

class UserMetrics {
  final String? name;
  final int age;
  final double height;
  final double weight;
  final ActivityLevel activity;
  final Sex sex;
  final double dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;

  UserMetrics({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.activity,
    required this.sex,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
  });

  UserMetrics copyWith({
    String? name,
    int? age,
    double? height,
    double? weight,
    ActivityLevel? activity,
    Sex? sex,
    double? dailyCalories,
    double? dailyProtein,
    double? dailyCarbs,
    double? dailyFat,
  }) => UserMetrics(
    name: name ?? this.name,
    age: age ?? this.age,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    activity: activity ?? this.activity,
    sex: sex ?? this.sex,
    dailyCalories: dailyCalories ?? this.dailyCalories,
    dailyProtein: dailyProtein ?? this.dailyProtein,
    dailyCarbs: dailyCarbs ?? this.dailyCarbs,
    dailyFat: dailyFat ?? this.dailyFat,
  );

  factory UserMetrics.fromMap(Map<String, dynamic> map) => UserMetrics(
    name: map['name'] as String?,
    age: (map['age'] as num).toInt(),
    height: (map['height'] as num).toDouble(),
    weight: (map['weight'] as num).toDouble(),
    activity: ActivityLevel.values[map['activity'] as int],
    sex: Sex.values[map['sex'] as int],
    dailyCalories: (map['dailyCalories'] as num).toDouble(),
    dailyProtein: (map['dailyProtein'] as num).toDouble(),
    dailyCarbs: (map['dailyCarbs'] as num).toDouble(),
    dailyFat: (map['dailyFat'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    if (name != null) 'name': name,
    'age': age,
    'height': height,
    'weight': weight,
    'activity': activity.index,
    'sex': sex.index,
    'dailyCalories': dailyCalories,
    'dailyProtein': dailyProtein,
    'dailyCarbs': dailyCarbs,
    'dailyFat': dailyFat,
  };

  @override
  String toString() =>
      'UserMetrics(name: $name, age: $age, height: $height, weight: $weight, activity: $activity, sex: $sex, dailyCalories: $dailyCalories, dailyProtein: $dailyProtein, dailyCarbs: $dailyCarbs, dailyFat: $dailyFat)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMetrics &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age &&
          height == other.height &&
          weight == other.weight &&
          activity == other.activity &&
          sex == other.sex &&
          dailyCalories == other.dailyCalories &&
          dailyProtein == other.dailyProtein &&
          dailyCarbs == other.dailyCarbs &&
          dailyFat == other.dailyFat;

  @override
  int get hashCode =>
      name.hashCode ^
      age.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      activity.hashCode ^
      sex.hashCode ^
      dailyCalories.hashCode ^
      dailyProtein.hashCode ^
      dailyCarbs.hashCode ^
      dailyFat.hashCode;

  double get bmr {
    if (sex == Sex.male) {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double get tdee => bmr * activity.multiplier;
}
