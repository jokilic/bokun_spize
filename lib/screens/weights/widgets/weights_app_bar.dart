import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/durations.dart';

class WeightsAppBar extends StatelessWidget {
  final String? title;
  final String dayString;
  final double? currentWeight;
  final double? weightChange;
  final int? weightChangeWithinDays;

  const WeightsAppBar({
    required this.title,
    required this.dayString,
    required this.currentWeight,
    required this.weightChange,
    required this.weightChangeWithinDays,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: BokunSpizeColors.grey,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 200,
    leadingWidth: double.infinity,
    leading: Padding(
      padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
      child: Row(
        children: [
          ///
          /// ICON
          ///
          IconButton(
            onPressed: null,
            icon: const PhosphorIcon(
              PhosphorIconsBold.personSimple,
              size: 24,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              foregroundColor: BokunSpizeColors.blue,
              disabledBackgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              disabledForegroundColor: BokunSpizeColors.blue,
            ),
          ),
          const SizedBox(width: 14),

          ///
          /// APP TITLE
          ///
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: const TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  height: 1.2,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w800,
                  color: BokunSpizeColors.blue,
                ),
              ),
            ),
        ],
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
      title: currentWeight != null
          ? FadingFlexibleTitle(
              dayString: dayString,
              currentWeight: currentWeight,
              weightChange: weightChange,
              weightChangeWithinDays: weightChangeWithinDays,
            )
          : null,
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final String dayString;
  final double? currentWeight;
  final double? weightChange;
  final int? weightChangeWithinDays;

  const FadingFlexibleTitle({
    required this.dayString,
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
            > 0 => BokunSpizeColors.red,
            < 0 => BokunSpizeColors.green,
            _ => BokunSpizeColors.black,
          }
        : BokunSpizeColors.black;

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
                  /// DAY
                  ///
                  Text(
                    dayString.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),

                  ///
                  /// WEIGHT
                  ///
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      ///
                      /// VALUE
                      ///
                      AnimatedDigitWidget(
                        value: currentWeight,
                        fractionDigits: 1,
                        loop: false,
                        curve: Curves.easeIn,
                        duration: BokunSpizeDurations.animation,
                        textStyle: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 1.5,
                          color: BokunSpizeColors.blue,
                        ),
                      ),

                      ///
                      /// UNIT
                      ///
                      Transform.translate(
                        offset: const Offset(0, 5),
                        child: Text(
                          'kg',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 1.5,
                            color: BokunSpizeColors.black.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
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
                        0 => 'vs today',
                        1 => 'vs yesterday',
                        final int days => 'vs last $days days',
                        null => '-',
                      },
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        color: BokunSpizeColors.black,
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
