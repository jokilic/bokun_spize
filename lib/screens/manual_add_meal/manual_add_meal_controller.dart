import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/meal/food.dart';
import '../../models/meal/meal.dart';
import '../../services/speech_to_text_service.dart';

class ManualAddMealController
    extends
        ValueNotifier<
          ({
            bool validation,
            String? speechToTextWords,
            List<Food>? foods,
            DateTime mealDate,
            DateTime mealTime,
            File? imageFile,
          })
        >
    implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final SpeechToTextService speechToText;
  final Meal? passedMeal;

  ManualAddMealController({
    required this.speechToText,
    required this.passedMeal,
  }) : super(
         (
           validation: false,
           speechToTextWords: null,
           foods: null,
           mealDate: DateTime.now(),
           mealTime: DateTime.now(),
           imageFile: null,
         ),
       );

  ///
  /// INIT
  ///

  void init() {}

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {}

  ///
  /// VARIABLES
  ///

  late final textEditingController = TextEditingController();

  ///
  /// METHODS
  ///
}
