import 'dart:io';

/// Returns a supported file extension for a meal image
String mealImageExtension(File imageFile) {
  final fileName = imageFile.path.split('/').last;
  final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'webp';

  return switch (ext) {
    'jpeg' => 'jpg',
    'png' || 'webp' || 'heic' || 'heif' => ext,
    _ => 'webp',
  };
}

/// Returns the MIME type matching a meal image extension
String mealImageContentType(String ext) => switch (ext) {
  'png' => 'image/png',
  'webp' => 'image/webp',
  'heic' => 'image/heic',
  'heif' => 'image/heif',
  'jpg' || 'jpeg' => 'image/jpeg',
  _ => 'image/webp',
};
