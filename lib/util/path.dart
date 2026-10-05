import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Returns the app storage directory for supported platforms
Future<Directory?> getProperDirectory() async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
    final directory = await getLibraryDirectory();
    return directory;
  }

  return null;
}

/// Saves a `WebP` image into app storage so its path remains valid later
Future<File> persistImage({
  required String imagePath,
  Uint8List? webpBytes,
}) async {
  final appDirectory = await getProperDirectory() ?? await getTemporaryDirectory();

  if (webpBytes == null) {
    final decodedImage = img.decodeImage(await File(imagePath).readAsBytes());

    if (decodedImage == null) {
      throw const FormatException('Unable to decode meal image');
    }

    webpBytes = img.encodeWebP(
      img.bakeOrientation(decodedImage),
      lossless: false,
      quality: 50,
    );
  }

  final persistedImage = File(
    '${appDirectory.path}/${DateTime.now().microsecondsSinceEpoch}.webp',
  );

  return persistedImage.writeAsBytes(webpBytes);
}
