import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'hive_service.dart';

class AIService extends ValueNotifier<({GenerativeModel? generativeModel, GenerativeModel? alternativeGenerativeModel})> {
  ///
  /// CONSTRUCTOR
  ///

  final HiveService hive;
  final FirebaseAI ai;

  AIService({
    required this.hive,
    required this.ai,
  }) : super((generativeModel: null, alternativeGenerativeModel: null));

  ///
  /// VARIABLES
  ///

  final systemInstruction = '''
You will receive a text describing what the user ate.
Estimate nutrition and extract foods.

Two values can be returned:
1. ONLY valid JSON for a single Meal object
2. ONLY null if the meal cannot be determined

For the name, use the same language as the received text (Croatian or English).

If quantity is unclear, make a reasonable estimate
If nutrition is unknown, estimate based on typical values

JSON structure to follow strictly:
{
  "name": "string",
  "emoji": "string",
  "color": "string",
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
    title: 'Meal',
    description: 'Meal JSON schema',
    nullable: true,
    propertyOrdering: [
      'name',
      'emoji',
      'color',
      'nutrition',
      'foods',
    ],
    properties: {
      'name': Schema.string(
        title: 'Meal name',
        description: 'name best describing meal from user input, use language which is used in user input (English or Croatian)',
        format: 'string',
        nullable: false,
      ),
      'emoji': Schema.string(
        title: 'Meal emoji',
        description: 'only one emoji best describing meal',
        format: 'string',
        nullable: false,
      ),
      'color': Schema.string(
        title: 'Meal color',
        description: 'color best describing meal in hex format (e.g. #FF0000)',
        format: 'string',
        nullable: false,
      ),
      'nutrition': Schema.object(
        title: 'Nutrition',
        description: 'Nutrition of the meal',
        nullable: false,
        propertyOrdering: [
          'calories',
          'protein',
          'carbs',
          'fat',
        ],
        properties: {
          'calories': Schema.number(
            title: 'Calories',
            description: 'calories in kcal',
            format: 'number',
            nullable: false,
          ),
          'protein': Schema.number(
            title: 'Protein',
            description: 'protein in g',
            format: 'number',
            nullable: false,
          ),
          'carbs': Schema.number(
            title: 'Carbs',
            description: 'carbs in g',
            format: 'number',
            nullable: false,
          ),
          'fat': Schema.number(
            title: 'Fat',
            description: 'fat in g',
            format: 'number',
            nullable: false,
          ),
        },
      ),
      'foods': Schema.array(
        title: 'Foods',
        description: 'Foods in the meal',
        nullable: false,
        items: Schema.object(
          propertyOrdering: [
            'name',
            'quantity',
            'unit',
          ],
          properties: {
            'name': Schema.string(
              title: 'Food name',
              description: 'name of food',
              format: 'string',
              nullable: false,
            ),
            'quantity': Schema.number(
              title: 'Food quantity',
              description: 'quantity of food',
              format: 'string',
              nullable: false,
            ),
            'unit': Schema.string(
              title: 'Food unit',
              description: 'unit of food (e.g. piece, g, ml, tbsp, tsp, slice...), use language which is used in user input (English or Croatian)',
              format: 'string',
              nullable: false,
            ),
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
      return;
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
  Future<({String? aiResult, List<String>? errors})> triggerAI({
    required String prompt,
  }) async {
    /// Create `errors` list
    final errors = <String>[];

    /// Generate `contents` to pass into `AI`
    final contents = [
      /// Prompt
      Content.text(prompt),
    ];

    /// Try `generativeModel` first
    if (value.generativeModel != null) {
      try {
        final response = await value.generativeModel!.generateContent(contents);
        return (aiResult: response.text, errors: null);
      } catch (e) {
        final error = e.toString().contains('quota') ? 'Kvota primarnog modela je prekoračena, pokušaj ponovno kasnije' : e.toString();
        errors.add(error);
      }
    } else {
      errors.add('Primarni model ne postoji');
    }

    /// Fallback to `alternativeGenerativeModel`
    if (value.alternativeGenerativeModel != null) {
      try {
        final response = await value.alternativeGenerativeModel!.generateContent(contents);
        return (aiResult: response.text, errors: null);
      } catch (e) {
        final error = e.toString().contains('quota') ? 'Kvota sekundarnog modela je prekoračena, pokušaj ponovno kasnije' : e.toString();
        errors.add(error);
      }
    } else {
      errors.add('Sekundarni model ne postoji');
    }

    return (aiResult: null, errors: errors);
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
