import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/durations.dart';
import '../../../models/meal/meal.dart';
import 'meals_list_tile.dart';

class MealsSuccess extends StatelessWidget {
  final List<Meal> meals;
  final Function() onPressed;
  final Function(Meal meal) onDeletePressed;
  final Function(Meal meal) onCopyPressed;

  const MealsSuccess({
    required this.meals,
    required this.onPressed,
    required this.onDeletePressed,
    required this.onCopyPressed,
  });

  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: meals.length,
    itemBuilder: (context, index) {
      final meal = meals[index];

      return Animate(
        key: ValueKey(meal.id),
        delay: BokunSpizeDurations.stateTransitionStagger * index.clamp(0, 6),
        effects: const [
          FadeEffect(
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOut,
          ),
          MoveEffect(
            begin: Offset(0, 18),
            end: Offset.zero,
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOutCubic,
          ),
          ScaleEffect(
            begin: Offset(0.98, 0.98),
            end: Offset(1, 1),
            alignment: Alignment.topCenter,
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOutCubic,
          ),
        ],
        child: MealsListTile(
          onPressed: onPressed,
          onDeletePressed: () => onDeletePressed(meal),
          onCopyPressed: () => onCopyPressed(meal),
          meal: meal,
        ),
      );
    },
  );
}
