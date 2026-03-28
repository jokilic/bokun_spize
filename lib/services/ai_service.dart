import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
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
Return only valid JSON for a single `Meal` object.
Do not wrap the response in markdown, code fences, or explanations.
Nested fields must stay as JSON objects and arrays, not JSON-encoded strings.

You will get text which should be about a meal user has eaten.

It's up to you to understand what the user meant and try to fill out as much as possible data for `Meal`.
If you don't manage to fill out data, return a `Meal` with `name: "No data found"` and numeric values set to `0`.

Text can be in English or Croatian.
Generate fields using the language user spoke.

Rules:
- `nutrition` must be an object with numeric fields: `calories`, `protein`, `carbs`, `fat`
- `foods` must be an array of objects with fields: `name`, `quantity`, `unit`
- `quantity` and all nutrition values must be numbers, not strings

Example of user's text:
"I ate 4 boiled eggs with a banana and some honey on top"

Example of your response:
```json
  {
    "name": "Eggs with banana & honey",
    "nutrition": {
      "calories": 100,
      "protein": 20,
      "carbs": 15,
      "fat": 5
    },
    "foods": [
      {
        "name": "Eggs",
        "quantity": 4,
        "unit": "piece"
      },
      {
        "name": "Banana",
        "quantity": 1,
        "unit": "piece"
      },
      {
        "name": "Honey",
        "quantity": 1,
        "unit": "tbsp"
      }
    ]
  }
```
''';

  // Keep the schema explicit so AI returns nested `JSON`
  final responseSchema = Schema.object(
    propertyOrdering: [
      'name',
      'nutrition',
      'foods',
    ],
    properties: {
      'name': Schema.string(),
      'nutrition': Schema.object(
        propertyOrdering: [
          'calories',
          'protein',
          'carbs',
          'fat',
        ],
        properties: {
          'calories': Schema.number(),
          'protein': Schema.number(),
          'carbs': Schema.number(),
          'fat': Schema.number(),
        },
      ),
      'foods': Schema.array(
        items: Schema.object(
          propertyOrdering: [
            'name',
            'quantity',
            'unit',
          ],
          properties: {
            'name': Schema.string(),
            'quantity': Schema.number(),
            'unit': Schema.string(),
          },
        ),
      ),
    },
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
      responseSchema: responseSchema,
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
