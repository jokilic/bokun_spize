import 'package:hive_ce/hive_ce.dart';

import 'food.dart';
import 'meal.dart';
import 'nutrition.dart';

@GenerateAdapters([
  AdapterSpec<Meal>(),
  AdapterSpec<Nutrition>(),
  AdapterSpec<Food>(),
])
part 'hive_adapters.g.dart';
