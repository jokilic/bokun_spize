import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../util/dependencies.dart';

class MealImage extends StatefulWidget {
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
  State<MealImage> createState() => MealImageState();
}

class MealImageState extends State<MealImage> {
  late Future<String?> imageUrlFuture;

  @override
  void initState() {
    super.initState();

    imageUrlFuture = getIt.get<FirebaseService>().getMealImageDownloadUrl(
      imageStoragePath: widget.imageStoragePath,
    );
  }

  @override
  void didUpdateWidget(covariant MealImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageStoragePath != widget.imageStoragePath) {
      imageUrlFuture = getIt.get<FirebaseService>().getMealImageDownloadUrl(
        imageStoragePath: widget.imageStoragePath,
      );
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: imageUrlFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return widget.loadingWidget;
      }

      final imageUrl = snapshot.data;
      if (imageUrl == null) {
        return widget.errorWidget;
      }

      return Image.network(
        imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        errorBuilder: (context, error, stackTrace) => widget.errorWidget,
      );
    },
  );
}
