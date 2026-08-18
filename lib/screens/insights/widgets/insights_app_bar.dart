import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';

class InsightsAppBar extends StatelessWidget {
  final String? title;
  final String? imagePath;
  final String timeString;
  final double? currentWeight;
  final double? weightChange;
  final int? weightChangeWithinDays;

  const InsightsAppBar({
    required this.title,
    required this.imagePath,
    required this.timeString,
    required this.currentWeight,
    required this.weightChange,
    required this.weightChangeWithinDays,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: BokunSpizeColors.neutralLight,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 200,
    leadingWidth: double.infinity,
    leading: Padding(
      padding: const EdgeInsets.only(left: 20, right: 8),
      child: Row(
        children: [
          ///
          /// AVATAR
          ///
          if (imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                imagePath!,
                fit: BoxFit.cover,
                height: 48,
                width: 48,
              ),
            ),
            const SizedBox(width: 14),
          ],

          ///
          /// APP TITLE
          ///
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 24,
                height: 1.2,
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
                color: BokunSpizeColors.primary,
              ),
            ),
        ],
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: currentWeight != null
          ? FadingFlexibleTitle(
              timeString: timeString,
              currentWeight: currentWeight,
              weightChange: weightChange,
              weightChangeWithinDays: weightChangeWithinDays,
            )
          : null,
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final String timeString;
  final double? currentWeight;
  final double? weightChange;
  final int? weightChangeWithinDays;

  const FadingFlexibleTitle({
    required this.timeString,
    required this.currentWeight,
    required this.weightChange,
    required this.weightChangeWithinDays,
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

    final changeColor = weightChange != null
        ? switch (weightChange!) {
            > 0 => BokunSpizeColors.tertiary,
            < 0 => BokunSpizeColors.primary,
            _ => BokunSpizeColors.neutralDark,
          }
        : BokunSpizeColors.neutralDark;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// CURRENT WEIGHT
            ///
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  /// TITLE
                  ///
                  Text(
                    timeString.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.neutralDark.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),

                  ///
                  /// WEIGHT
                  ///
                  Text.rich(
                    TextSpan(
                      text: currentWeight?.toStringAsFixed(1) ?? '--.-',
                      style: const TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 1.5,
                        color: BokunSpizeColors.primary,
                      ),
                      children: [
                        const WidgetSpan(
                          child: SizedBox(width: 4),
                        ),
                        TextSpan(
                          text: 'kg',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 1.5,
                            color: BokunSpizeColors.neutralDark.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            ///
            /// CHANGE WITHIN LAST X DAYS
            ///
            if (weightChange != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PhosphorIcon(
                        weightChange! > 0 ? PhosphorIconsBold.trendUp : PhosphorIconsBold.trendDown,
                        color: changeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${weightChange! > 0 ? '+' : ''}${weightChange!.toStringAsFixed(1)}kg',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: changeColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (weightChangeWithinDays != null)
                    Text(
                      switch (weightChangeWithinDays) {
                        0 => 'today',
                        1 => 'yesterday',
                        final int days => 'last $days days',
                        null => '-',
                      },
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        color: BokunSpizeColors.neutralDark,
                      ),
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
