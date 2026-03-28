import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'hive_service.dart';
import 'logger_service.dart';

class AIService extends ValueNotifier<({GenerativeModel? generativeModel, GenerativeModel? alternativeGenerativeModel})> {
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
  }) : super((generativeModel: null, alternativeGenerativeModel: null));

  ///
  /// VARIABLES
  ///

  final systemInstruction = '''
Return ONLY valid JSON for a single Meal object.
If the meal cannot be determined, return ONLY null.

Do NOT include markdown, code fences, or explanations.
Do NOT return JSON as a string.
Nested fields must be proper JSON objects/arrays.

You will receive a sentence describing what the user ate.
Extract foods and estimate nutrition.

Language:
Use the same language as the user (English or Croatian).

Rules:
- nutrition must contain numeric values: calories, protein, carbs, fat
- foods must be an array of objects: name, quantity, unit
- quantity must be a number
- All nutrition values must be numbers, not strings
- Units examples: piece, g, ml, tbsp, tsp, slice
- If quantity is unclear, make a reasonable estimate
- If nutrition is unknown, estimate based on typical values

Meal JSON structure:
{
  "name": "string",
  "emoji": "string",
  "nutrition": {
    "calories": number,
    "protein": number,
    "carbs": number,
    "fat": number
  },
  "foods": [
    {
      "name": "string",
      "quantity": number,
      "unit": "string"
    }
  ]
}
''';

  /// `JSON` schema which the AI should return
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
  Future<String?> triggerAI({required String prompt}) async {
    /// Generate `contents` to pass into `AI`
    final contents = [
      /// Prompt
      Content.text(prompt),
    ];

    /// Try `generativeModel` first
    if (value.generativeModel != null) {
      try {
        final response = await value.generativeModel!.generateContent(contents);

        logger.f('Result -> ${response.text}');

        return response.text;
      } catch (e) {
        final error = 'generativeModel -> ${e.toString().contains('quota') ? 'quota exceeded, try again later' : e.toString()}';
        logger.e(error);
      }
    }

    /// Fallback to `alternativeGenerativeModel`
    if (value.alternativeGenerativeModel != null) {
      try {
        final response = await value.alternativeGenerativeModel!.generateContent(contents);

        logger.f('Result2 -> ${response.text}');

        return response.text;
      } catch (e) {
        final error = 'alternativeGenerativeModel -> ${e.toString().contains('quota') ? 'quota exceeded, try again later' : e.toString()}';
        logger.e(error);
      }
    }

    return null;
  }

  /// Updates state
  void updateState({
    GenerativeModel? generativeModel,
    GenerativeModel? alternativeGenerativeModel,
  }) => value = (
    generativeModel: generativeModel ?? value.generativeModel,
    alternativeGenerativeModel: alternativeGenerativeModel ?? value.alternativeGenerativeModel,
  );
}
