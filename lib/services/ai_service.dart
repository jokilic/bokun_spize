import 'dart:async';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'hive_service.dart';

class AIService extends ValueNotifier<({List<GenerativeModel> generativeModels})> {
  ///
  /// CONSTRUCTOR
  ///

  final HiveService hive;
  final FirebaseAI ai;

  AIService({
    required this.hive,
    required this.ai,
  }) : super((generativeModels: []));

  ///
  /// VARIABLES
  ///

  final modelNames = [
    'gemini-3.1-flash-lite-preview',
    'gemini-2.5-flash-lite',
    'gemini-3-flash-preview',
    'gemini-2.5-flash',
    'gemini-2.5-pro',
  ];

  final systemInstruction = '''
You will receive a text in Croatian and / or image describing what the user ate.
Estimate nutrition and extract foods.

Two values can be returned:
1. ONLY valid JSON for a single Meal object
2. ONLY null if the meal cannot be determined

If quantity is unclear, make a reasonable estimate.
If nutrition is unknown, estimate based on typical values.

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
      "unit": "string",
      "calories": number,
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
        description: 'name best describing meal from user input, use Croatian language',
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
            'nutrition',
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
              description: 'unit of food (e.g. piece, g, ml, tbsp, tsp, slice...), use Croatian language',
              format: 'string',
              nullable: false,
            ),
            'nutrition': Schema.object(
              title: 'Food nutrition',
              description: 'nutrition for a specific food with passed quantity and unit',
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
                  description: 'calories in kcal for a specific food with passed quantity and unit',
                  format: 'number',
                  nullable: false,
                ),
                'protein': Schema.number(
                  title: 'Protein',
                  description: 'protein in g for a specific food with passed quantity and unit',
                  format: 'number',
                  nullable: false,
                ),
                'carbs': Schema.number(
                  title: 'Carbs',
                  description: 'carbs in g for a specific food with passed quantity and unit',
                  format: 'number',
                  nullable: false,
                ),
                'fat': Schema.number(
                  title: 'Fat',
                  description: 'fat in g for a specific food with passed quantity and unit',
                  format: 'number',
                  nullable: false,
                ),
              },
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
      final generativeModels = <GenerativeModel>[];

      for (final model in modelNames) {
        generativeModels.add(
          initializeGenerativeModel(
            model: model,
          ),
        );
      }

      updateState(
        generativeModels: generativeModels,
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
    required String? textPrompt,
    required File? imageFile,
  }) async {
    /// Create `errors` list
    final errors = <String>[];

    /// Generate a `textPrompt`
    TextPart? textPart;
    if (textPrompt != null) {
      textPart = TextPart(textPrompt);
    }

    /// Generate an `imagePrompt`
    InlineDataPart? imagePart;
    if (imageFile != null) {
      final image = await imageFile.readAsBytes();
      imagePart = InlineDataPart('image/jpeg', image);
    }

    /// Text and image don't exist, return
    if (textPart == null && imagePart == null) {
      errors.add('Nema teksta ni slike');
      return (aiResult: null, errors: errors);
    }

    /// Generate `contents` to pass into `AI`
    final contents = [
      Content.multi(
        [
          if (textPart != null) textPart,
          if (imagePart != null) imagePart,
        ],
      ),
    ];

    if (value.generativeModels.isEmpty) {
      errors.add('Nema dostupnih modela');
      return (aiResult: null, errors: errors);
    }

    for (final model in value.generativeModels) {
      try {
        final response = await model.generateContent(contents);
        final result = response.text;

        if (result == null) {
          errors.add('Model ${model.model.name} nije našao rezultat');
        }

        return (aiResult: result, errors: errors);
      } catch (e) {
        final error = e.toString().contains('quota') ? 'Kvota modela ${model.model.name} je prekoračena, pokušaj ponovno kasnije' : 'Greška kod modela ${model.model.name}: $e';
        errors.add(error);
      }
    }

    return (aiResult: null, errors: errors);
  }

  /// Updates state
  void updateState({
    List<GenerativeModel>? generativeModels,
  }) => value = (
    generativeModels: generativeModels ?? value.generativeModels,
  );
}
