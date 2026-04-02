import 'dart:io';

import 'package:flutter/foundation.dart';
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

  final persistedImage = File(
    '${appDirectory.path}/${DateTime.now().microsecondsSinceEpoch}.jpg',
  );

  return File(imagePath).copy(persistedImage.path);
}
