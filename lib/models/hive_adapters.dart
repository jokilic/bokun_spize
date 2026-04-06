import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

import 'activity_level.dart';
import 'calorie_goal.dart';
import 'food.dart';
import 'meal.dart';
import 'nutrition.dart';
import 'sex.dart';
import 'user_metrics.dart';

@GenerateAdapters([
  AdapterSpec<Color>(),
  AdapterSpec<Meal>(),
  AdapterSpec<Nutrition>(),
  AdapterSpec<Food>(),
  AdapterSpec<ActivityLevel>(),
  AdapterSpec<Sex>(),
  AdapterSpec<CalorieGoal>(),
  AdapterSpec<UserMetrics>(),
])
part 'hive_adapters.g.dart';
