import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../util/dependencies.dart';

class MealImage extends StatelessWidget {
  final String imageStoragePath;
  final BoxFit fit;
  final Widget loadingWidget;
  final Widget errorWidget;
  final double height;
  final double width;

  const MealImage({
    required this.imageStoragePath,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    this.loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    this.errorWidget = const SizedBox.shrink(),
    super.key,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: getIt.get<FirebaseService>().getMealImageDownloadUrl(
      imageStoragePath: imageStoragePath,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return loadingWidget;
      }

      final imageUrl = snapshot.data;
      if (imageUrl == null) {
        return errorWidget;
      }

      return Image.network(
        imageUrl,
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    },
  );
}
