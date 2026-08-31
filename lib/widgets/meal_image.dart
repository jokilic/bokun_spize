import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/durations.dart';
import '../services/cache_service.dart';
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
  String? cachedImageUrl;

  @override
  void initState() {
    super.initState();
    getDownloadUrl();
  }

  @override
  void didUpdateWidget(covariant MealImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageStoragePath != widget.imageStoragePath) {
      getDownloadUrl();
    }
  }

  void getDownloadUrl() {
    final cacheService = getIt.get<CacheService>();

    cachedImageUrl = cacheService.getCachedMealImageDownloadUrl(
      imageStoragePath: widget.imageStoragePath,
    );
    imageUrlFuture = cacheService.getMealImageDownloadUrl(
      imageStoragePath: widget.imageStoragePath,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: imageUrlFuture,
    initialData: cachedImageUrl,
    builder: (context, snapshot) {
      final imageUrl = snapshot.data;

      if (imageUrl != null) {
        return CachedNetworkImage(
          key: ValueKey(widget.imageStoragePath),
          imageUrl: imageUrl,
          cacheKey: widget.imageStoragePath,
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
      }

      return snapshot.connectionState == ConnectionState.done ? widget.errorWidget : widget.placeholderWidget;
    },
  );
}
