import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import '../constants/constants.dart';
import '../constants/durations.dart';
import '../services/cache_service.dart';
import '../theme/extensions.dart';
import '../util/blur_hash.dart';
import '../util/dependencies.dart';

class MealImage extends StatefulWidget {
  final String imageStoragePath;
  final String? imageBlurHash;
  final BoxFit fit;
  final double height;
  final double width;
  final Widget? placeholderWidget;
  final Widget errorWidget;

  const MealImage({
    required this.imageStoragePath,
    required this.height,
    required this.width,
    this.imageBlurHash,
    this.fit = BoxFit.cover,
    this.placeholderWidget,
    this.errorWidget = const SizedBox.shrink(),
    super.key,
  });

  @override
  State<MealImage> createState() => MealImageState();
}

class MealImageState extends State<MealImage> {
  late Future<String?> imageUrlFuture;
  String? cachedImageUrl;

  /// Starts resolving the image download URL
  @override
  void initState() {
    super.initState();
    getDownloadUrl();
  }

  /// Resolves a new download URL when the storage path changes
  @override
  void didUpdateWidget(covariant MealImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageStoragePath != widget.imageStoragePath) {
      getDownloadUrl();
    }
  }

  /// Gets the cached URL and starts resolving a missing download URL
  void getDownloadUrl() {
    final cacheService = getIt.get<CacheService>();

    cachedImageUrl = cacheService.getCachedMealImageDownloadUrl(
      imageStoragePath: widget.imageStoragePath,
    );
    imageUrlFuture = cacheService.getMealImageDownloadUrl(
      imageStoragePath: widget.imageStoragePath,
    );
  }

  /// Builds the animated fallback used when no `BlurHash` is available
  Widget getAnimatedPlaceholderWidget() => Animate(
    onPlay: (controller) => controller.loop(
      reverse: true,
      min: 0.6,
    ),
    effects: const [
      FadeEffect(
        duration: BokunSpizeDurations.shimmer,
        curve: Curves.easeIn,
      ),
    ],
    child: Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(listTileRadius),
        color: context.colors.listTileBackground.withValues(alpha: 0.5),
      ),
    ),
  );

  /// Returns the caller placeholder before falling back to the default animation
  Widget getFallbackPlaceholderWidget() => widget.placeholderWidget ?? getAnimatedPlaceholderWidget();

  /// Builds the `BlurHash` placeholder or the existing animated fallback
  Widget getPlaceholderWidget() {
    final imageBlurHash = widget.imageBlurHash;

    if (imageBlurHash == null || !isValidBlurHash(imageBlurHash)) {
      return getFallbackPlaceholderWidget();
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: BlurHash(
        hash: imageBlurHash,
        imageFit: widget.fit,
        duration: BokunSpizeDurations.animation,
        curve: Curves.easeIn,
        optimizationMode: BlurHashOptimizationMode.standard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.height,
    width: widget.width,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ///
        /// PLACEHOLDER
        ///
        getPlaceholderWidget(),

        ///
        /// PROPER IMAGE
        ///
        FutureBuilder<String?>(
          future: imageUrlFuture,
          initialData: cachedImageUrl,
          builder: (context, snapshot) {
            final cacheManager = getIt.get<CacheService>().imageCacheManager;
            final imageUrl = snapshot.data;

            if (imageUrl != null) {
              return CachedNetworkImage(
                key: ValueKey(widget.imageStoragePath),
                imageUrl: imageUrl,
                cacheKey: widget.imageStoragePath,
                cacheManager: cacheManager,
                fit: widget.fit,
                height: widget.height,
                width: widget.width,
                placeholder: (context, url) => const SizedBox.shrink(),
                errorBuilder: (context, error, stackTrace) => widget.errorWidget,
                fadeInDuration: BokunSpizeDurations.animation,
                fadeOutDuration: Duration.zero,
                placeholderFadeInDuration: Duration.zero,
              );
            }

            ///
            /// ERROR
            ///
            return snapshot.connectionState == ConnectionState.done ? widget.errorWidget : const SizedBox.shrink();
          },
        ),
      ],
    ),
  );
}
