import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIService {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseFunctions functions;
  final FirebaseAuth auth;

  AIService({
    required this.functions,
    required this.auth,
  });

  ///
  /// VARIABLES
  ///

  static const region = 'europe-west1';

  ///
  /// METHODS
  ///

  /// Submits a durable job and retries uncertain network outcomes with the same meal ID
  Future<void> createMeal({
    required String userId,
    required String mealId,
    required String? text,
    required String? imageStoragePath,
    required DateTime createdAt,
    required String languageCode,
  }) async {
    final data = {
      'mealId': mealId,
      'text': text,
      'imageStoragePath': imageStoragePath,
      'createdAt': createdAt.toLocal().toIso8601String(),
      'languageCode': languageCode,
    };

    for (var attempt = 0; attempt < 3; attempt++) {
      if (auth.currentUser?.uid != userId) {
        throw StateError('The signed-in account changed during meal submission');
      }

      try {
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
          await callViaHttp(
            data: data,
            userId: userId,
          );
        } else {
          await functions
              .httpsCallable(
                'createAIMeal',
                options: HttpsCallableOptions(),
              )
              .call<Map<String, dynamic>>(data);
        }
        return;
      } on FirebaseFunctionsException catch (error) {
        final canRetry = const ['unavailable', 'deadline-exceeded', 'internal', 'unknown'].contains(error.code);
        if (!canRetry || attempt == 2) {
          rethrow;
        }
        await Future<void>.delayed(
          Duration(seconds: attempt + 1),
        );
      }
    }
  }

  /// Uses Firebase's callable protocol on Windows where the Functions plugin is unavailable
  Future<void> callViaHttp({
    required Map<String, Object?> data,
    required String userId,
  }) async {
    final user = auth.currentUser;
    final token = await user?.getIdToken();
    if (user?.uid != userId || auth.currentUser?.uid != userId || token == null) {
      throw FirebaseFunctionsException(code: 'unauthenticated', message: 'Sign in to add a meal');
    }

    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.https('$region-${functions.app.options.projectId}.cloudfunctions.net', '/createAIMeal'),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
            body: jsonEncode({'data': data}),
          )
          .timeout(const Duration(seconds: 60));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error'];
      if (error is Map) {
        throw FirebaseFunctionsException(
          code: (error['status'] as String? ?? 'INTERNAL').toLowerCase().replaceAll('_', '-'),
          message: error['message'] as String,
        );
      }
      if (response.statusCode != 200 || body['result'] is! Map) {
        throw FirebaseFunctionsException(code: 'internal', message: 'Meal submission could not be confirmed');
      }
    } on TimeoutException {
      throw FirebaseFunctionsException(code: 'deadline-exceeded', message: 'Meal submission timed out');
    } on http.ClientException {
      throw FirebaseFunctionsException(code: 'unavailable', message: 'Meal submission is unavailable');
    } on FormatException {
      throw FirebaseFunctionsException(code: 'internal', message: 'Invalid meal submission response');
    } finally {
      client.close();
    }
  }
}
