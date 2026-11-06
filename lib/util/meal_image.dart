import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

import 'blur_hash.dart';

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
    final imagePath = imageFile.path;

    return await Isolate.run(
      () => encodeMealImageBlurHashFile(imagePath),
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

/// Reads, resizes, and encodes a meal image into a BlurHash
String encodeMealImageBlurHashFile(String imagePath) {
  final decodedImage = img.decodeImage(File(imagePath).readAsBytesSync());

  if (decodedImage == null) {
    throw const FormatException('Unable to decode meal image for BlurHash');
  }

  final orientedImage = img.bakeOrientation(decodedImage);
  final scale = math.min<double>(
    1,
    64 / math.max(orientedImage.width, orientedImage.height),
  );
  final resizedImage = scale < 1
      ? img.copyResize(
          orientedImage,
          width: math.max(1, (orientedImage.width * scale).round()),
          height: math.max(1, (orientedImage.height * scale).round()),
          interpolation: img.Interpolation.average,
        )
      : orientedImage;

  return encodeBlurHashImage(resizedImage);
}
