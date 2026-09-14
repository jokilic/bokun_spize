import 'package:flutter/widgets.dart';

import '../../models/meal/meal.dart';

class ViewMealScreen extends StatefulWidget {
  final Meal passedMeal;

  const ViewMealScreen({
    required this.passedMeal,
  });

  @override
  State<ViewMealScreen> createState() => _ViewMealScreenState();
}

class _ViewMealScreenState extends State<ViewMealScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
