import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/weight_track/weight_track.dart';

/// Parses single `weightTrack` document
WeightTrack? parseWeightTrackDocument(QueryDocumentSnapshot<Map<String, dynamic>> document) {
  try {
    return WeightTrack.fromMap(
      document.data(),
      id: document.id,
    );
  } catch (error, stackTrace) {
    log(
      'Parsing weight track ${document.id} failed',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}
