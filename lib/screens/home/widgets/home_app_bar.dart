import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class HomeAppBar extends StatelessWidget {
  final Widget? leadingWidget;
  final String smallTitle;
  final String bigTitle;
  final String bigSubtitle;

  const HomeAppBar({
    required this.smallTitle,
    required this.bigTitle,
    required this.bigSubtitle,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    centerTitle: false,
    title: const Text.rich(
      TextSpan(
        text: '1,600',
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 40,
          fontWeight: FontWeight.w900,
          height: 1.2,
          letterSpacing: 1,
          color: BokunSpizeColors.primary,
        ),
        children: [
          TextSpan(
            text: ' / 2,200 kcal',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.2,
              letterSpacing: 1,
              color: BokunSpizeColors.neutralDark,
            ),
          ),
        ],
      ),
    ),
    backgroundColor: BokunSpizeColors.neutralLight,
    titleSpacing: leadingWidget != null ? 4 : 16,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 160,
    leading: leadingWidget,
    actions: [
      IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.calendar_month_rounded,
          size: 24,
        ),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.all(14),
          backgroundColor: BokunSpizeColors.neutralLight,
          foregroundColor: BokunSpizeColors.neutralDark,
          disabledBackgroundColor: BokunSpizeColors.neutralLight,
          disabledForegroundColor: BokunSpizeColors.neutralDark,
        ),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: const EdgeInsets.all(16),
      title: FadingFlexibleTitle(
        bigTitle: bigTitle,
        bigSubtitle: bigSubtitle,
      ),
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final String bigTitle;
  final String bigSubtitle;

  const FadingFlexibleTitle({
    required this.bigTitle,
    required this.bigSubtitle,
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

    final showSubtitle = t > 0.25;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yoyoo',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                height: 1.2,
                letterSpacing: 1,
                color: BokunSpizeColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
