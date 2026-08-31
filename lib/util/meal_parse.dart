import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal/meal.dart';

/// Parses single `meal` document
Meal? parseMealDocument(QueryDocumentSnapshot<Map<String, dynamic>> document) {
  try {
    final data = document.data();
    final createdAt = data['createdAt'];

    return Meal.fromMap(
      data,
      id: document.id,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.parse(createdAt as String),
      originalText: data['originalText'] as String?,
      isLoading: data['isLoading'] as bool? ?? false,
      errors: (data['errors'] as List?)?.cast<String>(),
      imageStoragePath: data['imageStoragePath'] as String?,
    );
  } catch (error, stackTrace) {
    log(
      'Parsing meal ${document.id} failed',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}
