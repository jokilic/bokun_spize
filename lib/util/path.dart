import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory?> getHiveDirectory() async {
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

/// Copies image into app storage so it's paths remain valid later
Future<File> persistImage({
  required String imagePath,
}) async {
  final appDirectory = await getHiveDirectory();

  if (appDirectory == null) {
    return File(imagePath);
  }

  final imagesDirectory = Directory('${appDirectory.path}/meal_images');

  if (!await imagesDirectory.exists()) {
    await imagesDirectory.create(
      recursive: true,
    );
  }

  final pathSegments = imagePath.split('.');
  final extension = pathSegments.length > 1 ? pathSegments.last : 'jpg';
  final persistedImage = File('${imagesDirectory.path}/${DateTime.now().microsecondsSinceEpoch}.$extension');

  return File(imagePath).copy(persistedImage.path);
}
