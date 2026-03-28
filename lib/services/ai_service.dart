import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/food.dart';
import '../models/meal.dart';
import '../models/nutrition.dart';
import 'hive_service.dart';
import 'logger_service.dart';

class AIService extends ValueNotifier<({GenerativeModel? generativeModel, GenerativeModel? alternativeGenerativeModel, bool isGenerating})> {
  ///
  /// CONSTRUCTOR
  ///

  final LoggerService logger;
  final HiveService hive;
  final FirebaseAI ai;

  AIService({
    required this.logger,
    required this.hive,
    required this.ai,
  }) : super((generativeModel: null, alternativeGenerativeModel: null, isGenerating: false));

  ///
  /// VARIABLES
  ///

  final systemInstruction = '''
Only thing you should generate is a `Meal` in `JSON` format using `Dart` language.

```dart
class Meal {
  final String name;
  final Nutrition nutrition;
  final List<Food> foods;
}
```

```dart
class Nutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}
```

```dart
class Food {
  final String name;
  final double quantity;
  final String unit;
}
```

You will get text which should be about a meal user has eaten.

It's up to you to understand what the user meant and try to fill out as much as possible data for `Meal`.
If you don't manage to fill out data, return a `Meal` with a `title: No data found` and default values.

Text can be in English or Croatian.
Generate fields using the language user spoke.

Example of user's text:
"I ate 4 boiled eggs with a banana and some honey on top"

Example of your response:
```dart
  {
    name: 'Eggs with banana & honey',
    nutrition: {
      calories: 100,
      protein: 20,
      carbs: 15,
      fat: 5,
    },
    foods: [
      {
        name: 'Eggs',
        quantity: 4,
        unit: 'piece',
      },
      {
        name: 'Banana',
        quantity: 1,
        unit: 'piece',
      },
      {
        name: 'Honey',
        quantity: 1,
        unit: 'tbsp',
      },
    ],
  }
```
''';

  final exampleMeal = Meal(
    id: const Uuid().v1(),
    name: 'name of meal',
    nutrition: Nutrition(
      calories: 100,
      protein: 20,
      carbs: 15,
      fat: 5,
    ),
    foods: [
      Food(
        name: 'some food',
        quantity: 1,
        unit: 'piece',
      ),
    ],
    originalText: 'I ate some meal now',
    postedAt: DateTime.now(),
  );

  ///
  /// INIT
  ///

  void init() {
    initializeGemini();
  }

  ///
  /// METHODS
  ///

  /// Initialize `Gemini` backend service
  void initializeGemini() {
    try {
      final model = initializeGenerativeModel(
        model: 'gemini-2.5-flash',
      );
      final alternativeModel = initializeGenerativeModel(
        model: 'gemini-2.5-flash-lite',
      );

      updateState(
        generativeModel: model,
        alternativeGenerativeModel: alternativeModel,
      );
    } catch (e) {
      logger.e('AIService -> initializeGemini() -> $e');
    }
  }

  /// Initializes `generativeModel` with passed `model` name
  GenerativeModel initializeGenerativeModel({required String model}) => ai.generativeModel(
    model: model,
    systemInstruction: Content.system(systemInstruction),
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseJsonSchema: exampleMeal.toMap(),
    ),
  );

  /// Triggers `AI` with `prompt` and all necessary data
  Future<({String? aiResult, String? error})> triggerAI({required String prompt}) async {
    /// Create `errors` list
    final errors = <String>[
      'AIService -> triggerAI()',
    ];

    updateState(
      isGenerating: true,
    );

    /// Generate `contents` to pass into `AI`
    final contents = [
      /// Prompt
      Content.text(prompt),
    ];

    /// Try `generativeModel` first
    if (value.generativeModel != null) {
      try {
        final response = await value.generativeModel!.generateContent(contents);

        logger.f('generativeModel -> ${response.text}');

        updateState(
          isGenerating: false,
        );

        return (aiResult: response.text, error: null);
      } catch (e) {
        final error = 'generativeModel -> ${e.toString().contains('quota') ? 'quota exceeded, try again later' : e.toString()}';
        logger.e(error);
        errors.add(error);
      }
    } else {
      errors.add('generativeModel == null');
    }

    /// Fallback to `alternativeGenerativeModel`
    if (value.alternativeGenerativeModel != null) {
      try {
        final response = await value.alternativeGenerativeModel!.generateContent(contents);

        logger.f('alternativeGenerativeModel -> ${response.text}');

        updateState(
          isGenerating: false,
        );

        return (aiResult: response.text, error: null);
      } catch (e) {
        final error = 'alternativeGenerativeModel -> ${e.toString().contains('quota') ? 'quota exceeded, try again later' : e.toString()}';
        logger.e(error);
        errors.add(error);
      }
    } else {
      errors.add('alternativeGenerativeModel == null');
    }

    updateState(
      isGenerating: false,
    );

    return (
      aiResult: null,
      error: errors.toString(),
    );
  }

  /// Updates state
  void updateState({
    GenerativeModel? generativeModel,
    GenerativeModel? alternativeGenerativeModel,
    bool? isGenerating,
  }) => value = (
    generativeModel: generativeModel ?? value.generativeModel,
    alternativeGenerativeModel: alternativeGenerativeModel ?? value.alternativeGenerativeModel,
    isGenerating: isGenerating ?? value.isGenerating,
  );
}
