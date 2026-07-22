import 'activity_level.dart';
import 'sex.dart';

// TODO: Think about what values to remove from database and calculate in-app

class UserMetrics {
  final int age;
  final double height;
  final double weight;
  final ActivityLevel activity;
  final Sex sex;
  final double tdeeCalories;
  final double bmrCalories;
  final double dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;

  UserMetrics({
    required this.age,
    required this.height,
    required this.weight,
    required this.activity,
    required this.sex,
    required this.tdeeCalories,
    required this.bmrCalories,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
  });

  UserMetrics copyWith({
    int? age,
    double? height,
    double? weight,
    ActivityLevel? activity,
    Sex? sex,
    double? tdeeCalories,
    double? bmrCalories,
    double? dailyCalories,
    double? dailyProtein,
    double? dailyCarbs,
    double? dailyFat,
  }) => UserMetrics(
    age: age ?? this.age,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    activity: activity ?? this.activity,
    sex: sex ?? this.sex,
    tdeeCalories: tdeeCalories ?? this.tdeeCalories,
    bmrCalories: bmrCalories ?? this.bmrCalories,
    dailyCalories: dailyCalories ?? this.dailyCalories,
    dailyProtein: dailyProtein ?? this.dailyProtein,
    dailyCarbs: dailyCarbs ?? this.dailyCarbs,
    dailyFat: dailyFat ?? this.dailyFat,
  );

  factory UserMetrics.fromMap(Map<String, dynamic> map) => UserMetrics(
    age: (map['age'] as num).toInt(),
    height: (map['height'] as num).toDouble(),
    weight: (map['weight'] as num).toDouble(),
    activity: ActivityLevel.values[map['activity'] as int],
    sex: Sex.values[map['sex'] as int],
    tdeeCalories: (map['tdeeCalories'] as num).toDouble(),
    bmrCalories: (map['bmrCalories'] as num).toDouble(),
    dailyCalories: (map['dailyCalories'] as num).toDouble(),
    dailyProtein: (map['dailyProtein'] as num).toDouble(),
    dailyCarbs: (map['dailyCarbs'] as num).toDouble(),
    dailyFat: (map['dailyFat'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'age': age,
    'height': height,
    'weight': weight,
    'activity': activity.index,
    'sex': sex.index,
    'tdeeCalories': tdeeCalories,
    'bmrCalories': bmrCalories,
    'dailyCalories': dailyCalories,
    'dailyProtein': dailyProtein,
    'dailyCarbs': dailyCarbs,
    'dailyFat': dailyFat,
  };

  @override
  String toString() =>
      'UserMetrics(age: $age, height: $height, weight: $weight, activity: $activity, sex: $sex, tdeeCalories: $tdeeCalories, bmrCalories: $bmrCalories, dailyCalories: $dailyCalories, dailyProtein: $dailyProtein, dailyCarbs: $dailyCarbs, dailyFat: $dailyFat)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMetrics &&
          runtimeType == other.runtimeType &&
          age == other.age &&
          height == other.height &&
          weight == other.weight &&
          activity == other.activity &&
          sex == other.sex &&
          tdeeCalories == other.tdeeCalories &&
          bmrCalories == other.bmrCalories &&
          dailyCalories == other.dailyCalories &&
          dailyProtein == other.dailyProtein &&
          dailyCarbs == other.dailyCarbs &&
          dailyFat == other.dailyFat;

  @override
  int get hashCode =>
      age.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      activity.hashCode ^
      sex.hashCode ^
      tdeeCalories.hashCode ^
      bmrCalories.hashCode ^
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
