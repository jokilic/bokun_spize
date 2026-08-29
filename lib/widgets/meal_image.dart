import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/durations.dart';
import '../services/firebase_service.dart';
import '../util/dependencies.dart';

class MealImage extends StatefulWidget {
  final String imageStoragePath;
  final BoxFit fit;
  final double height;
  final double width;
  final Widget placeholderWidget;
  final Widget errorWidget;

  const MealImage({
    required this.imageStoragePath,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    this.placeholderWidget = const Center(
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
        return widget.placeholderWidget;
      }

      final imageUrl = snapshot.data;

      if (imageUrl == null) {
        return widget.errorWidget;
      }

      return CachedNetworkImage(
        key: ValueKey(widget.imageStoragePath),
        imageUrl: imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        placeholder: (context, url) => widget.placeholderWidget,
        errorBuilder: (context, error, stackTrace) => widget.errorWidget,
        fadeOutCurve: Curves.easeIn,
        fadeInDuration: BokunSpizeDurations.animation,
        fadeOutDuration: BokunSpizeDurations.animation,
        placeholderFadeInDuration: BokunSpizeDurations.animation,
      );
    },
  );
}
