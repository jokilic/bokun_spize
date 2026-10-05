import 'dart:io';

import '../models/meal/food.dart';
import '../models/meal/nutrition.dart';
import '../screens/account/account_controller.dart';

typedef TriggerAIResult = ({String? aiResult, String? modelName, List<String>? errors});

typedef AIMealResult = ({String? words, DateTime? dateTime, File? imageFile});

typedef ManualMealResult = ({String name, DateTime? dateTime, Nutrition? nutrition, List<Food>? foods, File? imageFile, String? imageStoragePath});

typedef ReauthenticationResult = ({bool success, String? appleAuthorizationCode});

typedef CalendarDays = ({int weightsCalendarDays, int walksCalendarDays});

typedef SettingsValues = ({ThemeEnum theme});
