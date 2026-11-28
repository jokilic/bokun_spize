import 'package:cloud_firestore/cloud_firestore.dart';

enum MealCreationMethod {
  ai,
  manual,
  copied,
  unknown,
}

/// Records meal provenance with AI generation duration in milliseconds when available
typedef MealMetadata = ({
  MealCreationMethod methodOfCreation,
  int? duration,
  String? model,
  int? attempt,
  String? copiedFromMealId,
  DateTime? lastEditedAt,
});

MealMetadata createMealMetadata(
  MealCreationMethod methodOfCreation, {
  String? copiedFromMealId,
}) => (
  methodOfCreation: methodOfCreation,
  duration: null,
  model: null,
  attempt: null,
  copiedFromMealId: copiedFromMealId,
  lastEditedAt: null,
);

MealMetadata parseMealMetadata(Map<String, dynamic> meal) {
  final metadata = meal['metadata'];

  if (metadata is! Map) {
    final legacyMethod = meal['methodOfCreation'];
    return (
      methodOfCreation: switch (legacyMethod) {
        'manual' => MealCreationMethod.manual,
        'ai' || String(isNotEmpty: true) => MealCreationMethod.ai,
        _ => MealCreationMethod.unknown,
      },
      duration: null,
      model: legacyMethod is String && legacyMethod.isNotEmpty && legacyMethod != 'ai' && legacyMethod != 'manual' ? legacyMethod : null,
      attempt: null,
      copiedFromMealId: null,
      lastEditedAt: null,
    );
  }

  final lastEditedAt = metadata['lastEditedAt'];

  return (
    methodOfCreation: switch (metadata['methodOfCreation']) {
      'ai' => MealCreationMethod.ai,
      'manual' => MealCreationMethod.manual,
      'copied' => MealCreationMethod.copied,
      _ => MealCreationMethod.unknown,
    },
    duration: metadata['duration'] as int?,
    model: metadata['model'] as String?,
    attempt: metadata['attempt'] as int?,
    copiedFromMealId: metadata['copiedFromMealId'] as String?,
    lastEditedAt: switch (lastEditedAt) {
      Timestamp timestamp => timestamp.toDate(),
      String timestamp => DateTime.tryParse(timestamp),
      _ => null,
    },
  );
}

extension MealMetadataSerialization on MealMetadata {
  Map<String, dynamic> toMap({bool forJson = false}) => {
    'methodOfCreation': methodOfCreation.name,
    if (duration != null) 'duration': duration,
    if (model != null) 'model': model,
    if (attempt != null) 'attempt': attempt,
    if (copiedFromMealId != null) 'copiedFromMealId': copiedFromMealId,
    if (lastEditedAt case final editedAt?) 'lastEditedAt': forJson ? editedAt.toIso8601String() : Timestamp.fromDate(editedAt),
  };
}
