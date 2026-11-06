import 'dart:developer';
import 'dart:io';

import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:flutter/painting.dart';

/// Returns a supported file extension for a meal image
String mealImageExtension(File imageFile) {
  final fileName = imageFile.path.split('/').last;
  final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'webp';

  return switch (ext) {
    'jpg' || 'jpeg' => 'jpg',
    'png' || 'webp' || 'heic' || 'heif' => ext,
    _ => 'webp',
  };
}

/// Returns the MIME type matching a meal image extension
String mealImageContentType(String ext) => switch (ext) {
  'jpg' || 'jpeg' => 'image/jpeg',
  'png' => 'image/png',
  'webp' => 'image/webp',
  'heic' => 'image/heic',
  'heif' => 'image/heif',
  _ => 'image/webp',
};

/// Generates a compact placeholder for a meal image
Future<String?> generateMealImageBlurHash(File imageFile) async {
  try {
    return await BlurhashFFI.encode(
      FileImage(imageFile),
    );
  } catch (error, stackTrace) {
    log(
      'Generating meal image BlurHash failed',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}
