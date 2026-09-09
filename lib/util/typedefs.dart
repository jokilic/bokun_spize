import 'dart:io';

import '../models/meal/food.dart';
import '../models/meal/nutrition.dart';

typedef AIMealResult = ({String? words, DateTime? dateTime, File? imageFile});

typedef ManualMealResult = ({String name, DateTime? dateTime, Nutrition? nutrition, List<Food>? foods, File? imageFile, String? imageStoragePath});

typedef ReauthenticationResult = ({bool success, String? appleAuthorizationCode});
