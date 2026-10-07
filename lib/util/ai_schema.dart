import 'dart:convert';
import 'dart:developer';

import 'package:firebase_ai/firebase_ai.dart';

/// Accepts a schema map or JSON string without discarding other configuration on decode errors
Map<String, dynamic>? decodeAIResponseSchema(Object? value) {
  try {
    final decoded = value is String ? jsonDecode(value) : value;
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (error) {
    log(
      'Decoding remote AI response schema failed',
      error: error,
    );
    return null;
  }
}

/// Converts a Firestore schema map into a Firebase AI schema with localized descriptions
Schema parseAISchema(Map<String, dynamic> data, {required String languageCode}) {
  const supportedKeys = {
    'type',
    'title',
    'description',
    'nullable',
    'format',
    'enum',
    'properties',
    'required',
    'optionalProperties',
    'propertyOrdering',
    'items',
    'minItems',
    'maxItems',
    'minimum',
    'maximum',
  };

  if (data.keys.any((key) => !supportedKeys.contains(key))) {
    throw const FormatException(
      'Unsupported schema field',
    );
  }

  final type = switch ((data['type'] as String).toLowerCase()) {
    'object' => SchemaType.object,
    'array' => SchemaType.array,
    'string' => SchemaType.string,
    'number' => SchemaType.number,
    'integer' => SchemaType.integer,
    'boolean' => SchemaType.boolean,
    _ => throw const FormatException('Unsupported schema type'),
  };

  final properties = data['properties'] as Map?;
  final items = data['items'] as Map?;

  if ((type == SchemaType.object && (properties == null || properties.isEmpty)) ||
      (type != SchemaType.object && properties != null) ||
      (type == SchemaType.array && items == null) ||
      (type != SchemaType.array && items != null)) {
    throw const FormatException('Invalid schema properties or items');
  }

  final required = (data['required'] as List?)?.cast<String>().toList();

  var optional = (data['optionalProperties'] as List?)?.cast<String>().toList();
  final ordering = (data['propertyOrdering'] as List?)?.cast<String>().toList();

  for (final keys in [required, optional, ordering]) {
    if (keys != null && (properties == null || keys.any((key) => !properties.containsKey(key)) || keys.toSet().length != keys.length)) {
      throw const FormatException('Invalid schema property references');
    }
  }
  if (required != null) {
    if (optional != null) {
      throw const FormatException('Use required or optionalProperties, not both');
    }

    optional = properties!.keys
        .cast<String>()
        .where(
          (key) => !required.contains(key),
        )
        .toList();
  }

  final enumValues = (data['enum'] as List?)?.cast<String>().toList();
  if (enumValues != null && (type != SchemaType.string || enumValues.isEmpty)) {
    throw const FormatException('Invalid string enum');
  }

  final minItems = data['minItems'] as int?;
  final maxItems = data['maxItems'] as int?;
  final minimum = (data['minimum'] as num?)?.toDouble();
  final maximum = (data['maximum'] as num?)?.toDouble();

  if ((minItems != null && minItems < 0) ||
      (maxItems != null && maxItems < 0) ||
      (minItems != null && maxItems != null && minItems > maxItems) ||
      (minimum != null && maximum != null && minimum > maximum) ||
      ((minItems != null || maxItems != null) && type != SchemaType.array) ||
      ((minimum != null || maximum != null) && type != SchemaType.number && type != SchemaType.integer)) {
    throw const FormatException('Invalid schema bounds');
  }

  return Schema(
    type,
    title: (data['title'] as String?)?.replaceAll(
      '{languageCode}',
      languageCode,
    ),
    description: (data['description'] as String?)?.replaceAll(
      '{languageCode}',
      languageCode,
    ),
    nullable: data['nullable'] as bool?,
    format: enumValues != null ? 'enum' : data['format'] as String?,
    enumValues: enumValues,
    properties: properties?.map(
      (key, value) => MapEntry(
        key as String,
        parseAISchema(
          Map<String, dynamic>.from(value as Map),
          languageCode: languageCode,
        ),
      ),
    ),
    optionalProperties: optional,
    propertyOrdering: ordering,
    items: items == null
        ? null
        : parseAISchema(
            Map<String, dynamic>.from(items),
            languageCode: languageCode,
          ),
    minItems: minItems,
    maxItems: maxItems,
    minimum: minimum,
    maximum: maximum,
  );
}

/// Ensures remote schemas preserve the fields and value types expected by the meal parser
void validateAISchemaCompatibility(Schema schema, Schema expected) {
  if ((schema.type != expected.type && !(expected.type == SchemaType.number && schema.type == SchemaType.integer)) || (schema.nullable == true && expected.nullable != true)) {
    throw const FormatException('Schema is incompatible with the meal parser');
  }

  for (final entry in expected.properties?.entries ?? <MapEntry<String, Schema>>[]) {
    final property = schema.properties?[entry.key];

    if (property == null || (schema.optionalProperties?.contains(entry.key) ?? false)) {
      throw FormatException('Missing required meal property: ${entry.key}');
    }

    validateAISchemaCompatibility(
      property,
      entry.value,
    );
  }

  final expectedItems = expected.items;
  if (expectedItems != null) {
    final items = schema.items;

    if (items == null) {
      throw const FormatException('Missing array item schema');
    }

    validateAISchemaCompatibility(
      items,
      expectedItems,
    );
  }
}
