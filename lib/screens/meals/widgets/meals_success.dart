import 'package:flutter/material.dart';

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

      return MealsListTile(
        onPressed: onPressed,
        onDeletePressed: () => onDeletePressed(meal),
        onCopyPressed: () => onCopyPressed(meal),
        meal: meal,
      );
    },
  );
}
