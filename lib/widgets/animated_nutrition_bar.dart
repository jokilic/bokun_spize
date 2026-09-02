import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';
import '../constants/durations.dart';

class AnimatedNutritionBar extends StatelessWidget {
  final double value;
  final double progress;
  final Color color;

  const AnimatedNutritionBar({
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value),
    duration: BokunSpizeDurations.animation,
    curve: Curves.easeIn,
    builder: (context, animatedValue, child) => Expanded(
      flex: animatedValue.round() > 0 ? animatedValue.round() : 1,
      child: child!,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: ColoredBox(
        color: BokunSpizeColors.white.withValues(alpha: 0.5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: BokunSpizeDurations.animation,
            curve: Curves.easeIn,
            builder: (context, animatedProgress, child) => FractionallySizedBox(
              widthFactor: animatedProgress,
              child: child,
            ),
            child: SizedBox(
              height: nutritionValuesHeight,
              child: Container(
                color: color,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
