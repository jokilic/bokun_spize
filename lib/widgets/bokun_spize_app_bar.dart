import 'package:flutter/material.dart';

import '../constants/icons.dart';
import '../theme/extensions.dart';

class BokunSpizeAppBar extends StatelessWidget {
  final Widget? leadingWidget;
  final List<Widget>? actionWidgets;
  final String smallTitle;
  final String bigTitle;
  final String bigSubtitle;

  const BokunSpizeAppBar({
    required this.smallTitle,
    required this.bigTitle,
    required this.bigSubtitle,
    this.leadingWidget,
    this.actionWidgets,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    centerTitle: false,
    title: Row(
      children: [
        Flexible(
          child: Text(
            smallTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.appBarTitleSmall,
          ),
        ),
        const SizedBox(width: 6),
        Image.asset(
          BokunSpizeIcons.logo,
          height: 26,
          width: 26,
          fit: BoxFit.cover,
        ),
      ],
    ),
    backgroundColor: context.colors.scaffoldBackground,
    titleSpacing: leadingWidget != null ? 4 : 16,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 160,
    leading: leadingWidget,
    actions: actionWidgets,
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
    final opacity = Curves.easeOut.transform(t);

    final dy = Tween<double>(begin: 8, end: 0).transform(t);

    final showSubtitle = t > 0.25;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    bigTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.appBarTitleBig,
                  ),
                ),
                const SizedBox(width: 6),
                Image.asset(
                  BokunSpizeIcons.logo,
                  height: 26,
                  width: 26,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            if (showSubtitle) ...[
              const SizedBox(height: 2),
              Text(
                bigSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.appBarSubtitleBig,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
