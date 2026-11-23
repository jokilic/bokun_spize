import 'dart:developer';
import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
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

/// Selects and prepares a meal image without logging file paths or image contents
Future<File?> pickMealImage({
  required ImagePicker imagePicker,
  required ImageSource source,
}) async {
  var stage = 'pick';
  int? byteCount;

  try {
    final image = await imagePicker.pickImage(
      source: source,
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    if (image == null) {
      return null;
    }

    stage = 'read';
    final imageBytes = await image.readAsBytes();
    byteCount = imageBytes.length;

    stage = 'decode';
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      log(
        'Decoding meal image failed',
        error: 'source=${source.name}, bytes=$byteCount, reason=unsupported_image',
      );
      return null;
    }

    stage = 'encode';
    var preparedImage = img.bakeOrientation(decodedImage);
    if (source == ImageSource.camera) {
      final squareSize = min(preparedImage.width, preparedImage.height);
      preparedImage = img.copyCrop(
        preparedImage,
        x: (preparedImage.width - squareSize) ~/ 2,
        y: (preparedImage.height - squareSize) ~/ 2,
        width: squareSize,
        height: squareSize,
      );
    }

    final webpBytes = img.encodeWebP(
      preparedImage,
      lossless: false,
      quality: 50,
    );

    stage = 'save';
    return await persistImage(webpBytes: webpBytes);
  } catch (error) {
    final reason = error is PlatformException ? error.code : error.runtimeType;
    final bytes = byteCount == null ? '' : ', bytes=$byteCount';
    log(
      'Preparing selected meal image failed',
      error: 'source=${source.name}, stage=$stage$bytes, reason=$reason',
    );
    return null;
  }
}

/// Saves a `WebP` image into app storage so its path remains valid later
Future<File> persistImage({
  required Uint8List webpBytes,
}) async {
  final appDirectory = await getProperDirectory() ?? await getTemporaryDirectory();
  final persistedImage = File(
    '${appDirectory.path}/${DateTime.now().microsecondsSinceEpoch}.webp',
  );

  return persistedImage.writeAsBytes(webpBytes);
}
