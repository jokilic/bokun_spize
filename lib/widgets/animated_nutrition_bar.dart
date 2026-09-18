import 'package:flutter/material.dart';

import '../constants/durations.dart';

class AnimatedNutritionBar extends StatelessWidget {
  final double height;
  final double width;
  final double progress;
  final Color color;
  final Color backgroundColor;

  const AnimatedNutritionBar({
    required this.height,
    required this.width,
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: width),
    duration: BokunSpizeDurations.animation,
    curve: Curves.easeIn,
    builder: (context, animatedWidth, child) => SizedBox(
      width: animatedWidth,
      child: child,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: ColoredBox(
        color: backgroundColor,
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
              height: height,
              child: ColoredBox(
                color: color,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
