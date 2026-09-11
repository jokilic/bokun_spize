import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';

class WalksAppBar extends StatelessWidget {
  final bool isLoading;
  final String? title;
  final String dayString;
  final int? currentSteps;
  final double? stepsChange;
  final int? stepsChangeWithinDays;

  const WalksAppBar({
    required this.isLoading,
    required this.title,
    required this.dayString,
    required this.currentSteps,
    required this.stepsChange,
    required this.stepsChangeWithinDays,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: context.colors.scaffoldBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 200,
    leadingWidth: double.infinity,
    leading: Padding(
      padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
      child: Row(
        children: [
          ///
          /// AVATAR
          ///
          IconButton(
            onPressed: null,
            icon: const PhosphorIcon(
              PhosphorIconsBold.footprints,
              size: 24,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
              foregroundColor: context.colors.fat,
              disabledBackgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
              disabledForegroundColor: context.colors.fat,
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
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  height: 1.2,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w800,
                  color: context.colors.fat,
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
        isLoading: isLoading,
        dayString: dayString,
        currentSteps: currentSteps,
        stepsChange: stepsChange,
        stepsChangeWithinDays: stepsChangeWithinDays,
      ),
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final bool isLoading;
  final String dayString;
  final int? currentSteps;
  final double? stepsChange;
  final int? stepsChangeWithinDays;

  const FadingFlexibleTitle({
    required this.isLoading,
    required this.dayString,
    required this.currentSteps,
    required this.stepsChange,
    required this.stepsChangeWithinDays,
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

    final changeColor = stepsChange != null
        ? switch (stepsChange!) {
            > 0 => context.colors.protein,
            < 0 => context.colors.delete,
            _ => context.colors.text,
          }
        : context.colors.text;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// CURRENT STEPS
            ///
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  /// DAY LOADING
                  ///
                  if (isLoading)
                    Animate(
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: context.colors.listTileBackground.withValues(alpha: 0.5),
                        ),
                        height: 10,
                        width: 64,
                      ),
                    )
                  ///
                  /// DAY
                  ///
                  else
                    Text(
                      dayString.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: context.colors.text,
                      ),
                    ),
                  SizedBox(height: isLoading ? 10 : 2),

                  ///
                  /// STEPS
                  ///
                  Wrap(
                    crossAxisAlignment: isLoading ? WrapCrossAlignment.end : WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      ///
                      /// VALUE LOADING
                      ///
                      if (isLoading)
                        Animate(
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: context.colors.fat.withValues(alpha: 0.5),
                            ),
                            height: 34,
                            width: 28,
                          ),
                        )
                      ///
                      /// VALUE
                      ///
                      else
                        AnimatedDigitWidget(
                          value: currentSteps ?? 0,
                          loop: false,
                          curve: Curves.easeIn,
                          duration: BokunSpizeDurations.animation,
                          textStyle: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: 1.5,
                            color: context.colors.fat,
                          ),
                        ),

                      ///
                      /// UNIT LOADING
                      ///
                      if (isLoading)
                        Animate(
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
                          child: Transform.translate(
                            offset: const Offset(0, -2),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: context.colors.listTileBackground.withValues(alpha: 0.5),
                              ),
                              height: 10,
                              width: 32,
                            ),
                          ),
                        )
                      ///
                      /// UNIT
                      ///
                      else
                        Transform.translate(
                          offset: const Offset(0, 5),
                          child: Text(
                            'steps',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              letterSpacing: 1.5,
                              color: context.colors.text,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isLoading ? 14 : 4),
                ],
              ),
            ),

            ///
            /// CHANGE WITHIN LAST X DAYS
            ///
            if (stepsChange != null && !isLoading)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PhosphorIcon(
                        stepsChange! > 0 ? PhosphorIconsBold.trendUp : PhosphorIconsBold.trendDown,
                        color: changeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${stepsChange! > 0 ? '+' : ''}${stepsChange!.round().toStringAsFixed(0)}',
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
                  if (stepsChangeWithinDays != null)
                    Text(
                      switch (stepsChangeWithinDays) {
                        0 => 'vs today',
                        1 => 'vs yesterday',
                        final int days => 'vs last $days days',
                        null => '-',
                      },
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        color: context.colors.text,
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
