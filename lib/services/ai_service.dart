import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

import '../util/meal_image.dart';
import '../util/typedefs.dart';
import 'firebase_service.dart';

class AIService extends ValueNotifier<List<GenerativeModel>> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseAI ai;
  final FirebaseService firebase;

  AIService({
    required this.ai,
    required this.firebase,
  }) : super([]);

  ///
  /// INIT
  ///

  /// Loads remote AI configuration before initializing models for the requested language
  Future<void> init({required String languageCode}) async {
    await (configurationLoading ??= loadConfiguration());

    if (initialized && initializedLanguageCode == languageCode) {
      return;
    }

    initializeGemini(
      languageCode: languageCode,
    );

    initialized = value.isNotEmpty;
    initializedLanguageCode = initialized ? languageCode : null;
  }

  ///
  /// VARIABLES
  ///

  var initialized = false;

  String? initializedLanguageCode;

  Future<void>? configurationLoading;

  String? systemInstructionTemplate;

  final modelNames = [
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-3.8-flash',
    'gemini-3.7-flash',
    'gemini-3.6-flash',
    'gemini-3.5-flash',
  ];

  ///
  /// GETTERS
  ///

  /// Builds meal extraction instructions for the requested language
  String getSystemInstruction({required String languageCode}) =>
      systemInstructionTemplate?.replaceAll('{languageCode}', languageCode) ??
      '''
You will receive text and / or image describing what the user ate.
Estimate nutrition and extract foods.
Use the language identified by language code "$languageCode" for meal names, food names, and unit names.
Keep JSON property names unchanged and preserve standard unit symbols such as g and ml.

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
      "emoji": "string",
      "color": "string",
      "quantity": number,
      "unit": "string",
      "nutrition": {
        "calories": number,
        "protein": number,
        "carbs": number,
        "fat": number
      }
    }
  ]
}
''';

  /// Build `JSON` response schema for requested `languageCode`
  // TODO: Check how to remotely get this value (from my root Firestore or similar) (keep in mind this is a Schema so perhaps we should save it as JSON and then decode it back to Schema)
  Schema getResponseSchema({required String languageCode}) => Schema.object(
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
        description: 'name best describing meal from user input, use the language identified by language code "$languageCode"',
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
            'emoji',
            'color',
            'quantity',
            'unit',
            'nutrition',
          ],
          properties: {
            'name': Schema.string(
              title: 'Food name',
              description: 'name of food, use the language identified by language code "$languageCode"',
              format: 'string',
              nullable: false,
            ),
            'emoji': Schema.string(
              title: 'Food emoji',
              description: 'only one emoji best describing food',
              format: 'string',
              nullable: false,
            ),
            'color': Schema.string(
              title: 'Food color',
              description: 'color best describing food in hex format (e.g. #FF0000)',
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
              description: 'unit of food (e.g. piece, g, ml, tbsp, tsp, slice...), use the language identified by language code "$languageCode" and preserve standard unit symbols',
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
  /// METHODS
  ///

  /// Loads remote AI configuration, retaining defaults for unavailable values
  Future<void> loadConfiguration() async {
    final configuration = await firebase.getAIConfiguration();
    final names = configuration?.modelNames;

    if (names != null && names.isNotEmpty) {
      modelNames
        ..clear()
        ..addAll(names);
    }

    systemInstructionTemplate = configuration?.systemInstruction;
  }

  /// Initializes `Gemini` models for requested `languageCode`, skipping models that fail
  void initializeGemini({required String languageCode}) {
    final generativeModels = <GenerativeModel>[];

    for (final model in modelNames) {
      try {
        generativeModels.add(
          initializeGenerativeModel(
            model: model,
            languageCode: languageCode,
          ),
        );
      } catch (e) {
        debugPrint('Failed to initialize AI model "$model": $e');
      }
    }

    updateState(
      generativeModels: generativeModels,
    );
  }

  /// Initializes `generativeModel` with passed model name and `languageCode`
  GenerativeModel initializeGenerativeModel({
    required String model,
    required String languageCode,
  }) => ai.generativeModel(
    model: model,
    systemInstruction: Content.system(
      getSystemInstruction(
        languageCode: languageCode,
      ),
    ),
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: getResponseSchema(
        languageCode: languageCode,
      ),
    ),
  );

  /// Trigger `AI` with text and image prompts in requested `languageCode`, return its result, model name, and errors
  Future<TriggerAIResult> triggerAI({
    required String? textPrompt,
    required File? imageFile,
    required String languageCode,
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
      final ext = mealImageExtension(imageFile);
      imagePart = InlineDataPart(
        mealImageContentType(ext),
        image,
      );
    }

    /// Text and image don't exist, return
    if (textPart == null && imagePart == null) {
      errors.add('aiErrorNoTextImage'.tr());
      return (
        aiResult: null,
        modelName: null,
        errors: errors,
      );
    }

    /// Models are created on first valid AI request and refreshed when `languageCode` changes
    await init(
      languageCode: languageCode,
    );

    /// Generate `contents` to pass into `AI`
    final contents = [
      Content.multi(
        [
          if (textPart != null) textPart,
          if (imagePart != null) imagePart,
        ],
      ),
    ];

    if (value.isEmpty) {
      errors.add('aiErrorNoModels'.tr());

      return (
        aiResult: null,
        modelName: null,
        errors: errors,
      );
    }

    String? aiResult;
    String? modelName;
    for (final model in value) {
      try {
        final response = await model.generateContent(contents);
        final result = response.text;

        if (result == null) {
          errors.add(
            'aiErrorModelNoResult'.tr(
              args: [model.model.name],
            ),
          );
          continue;
        }

        aiResult = result;
        modelName = model.model.name;
        break;
      } catch (e) {
        final error = e.toString().contains('quota')
            ? 'aiErrorModelQuota'.tr(
                args: [model.model.name],
              )
            : 'aiErrorModelError'.tr(
                args: [model.model.name, '$e'],
              );
        errors.add(error);
      }
    }

    return (
      aiResult: aiResult,
      modelName: modelName,
      errors: errors,
    );
  }

  /// Updates state
  void updateState({
    List<GenerativeModel>? generativeModels,
  }) => value = List.from(
    generativeModels ?? [],
  );
}
