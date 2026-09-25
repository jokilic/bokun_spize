import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../theme/extensions.dart';

class AccountAppBar extends StatelessWidget {
  final String? email;
  final String? name;
  final String? userPhoto;

  const AccountAppBar({
    required this.email,
    required this.name,
    required this.userPhoto,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: context.colors.scaffoldBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 192,
    leadingWidth: double.infinity,
    leading: Padding(
      padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///
          /// ICON
          ///
          IconButton(
            onPressed: () {},
            icon: const PhosphorIcon(
              PhosphorIconsBold.user,
              size: 24,
            ),
            style: IconButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
              foregroundColor: context.colors.account,
              disabledBackgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
              disabledForegroundColor: context.colors.account,
            ),
          ),
          const SizedBox(width: 14),

          ///
          /// TITLE
          ///
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: context.colors.account.withValues(alpha: 0.05),
              ),
              child: IconButton(
                onPressed: () {},
                icon: Text(
                  'Account',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    height: 1.2,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w900,
                    color: context.colors.account,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                style: IconButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: context.colors.account,
                  disabledBackgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                  disabledForegroundColor: context.colors.account,
                ),
              ),
            ),
          ),

          ///
          /// PLACEHOLDER ICON
          ///
          const SizedBox(width: 14),
          Opacity(
            opacity: 0,
            child: IgnorePointer(
              child: IconButton(
                onPressed: null,
                icon: const PhosphorIcon(
                  PhosphorIconsBold.magnifyingGlass,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                  foregroundColor: context.colors.account,
                  disabledBackgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                  disabledForegroundColor: context.colors.account,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
      title: FadingFlexibleTitle(
        email: email,
        name: name,
        userPhoto: userPhoto,
      ),
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final String? email;
  final String? name;
  final String? userPhoto;

  const FadingFlexibleTitle({
    required this.email,
    required this.name,
    required this.userPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    if (settings == null) {
      return const SizedBox.shrink();
    }

    final delta = settings.maxExtent - settings.minExtent;
    final t = ((settings.currentExtent - settings.minExtent) / delta).clamp(0.0, 1.0);
    final opacity = Curves.easeIn.transform(t);

    final dy = Tween<double>(begin: 8, end: 0).transform(t);

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// EMAIL & NAME
            ///
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  /// EMAIL
                  ///
                  Text(
                    email?.toUpperCase() ?? '--',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: context.colors.text,
                    ),
                  ),
                  const SizedBox(height: 2),

                  ///
                  /// NAME
                  ///
                  Text(
                    name ?? '--',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: 1.2,
                      color: context.colors.account,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            ///
            /// USER PHOTO
            ///
            if (userPhoto != null)
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userPhoto!,
                  height: 42,
                  width: 42,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox.shrink(),
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
