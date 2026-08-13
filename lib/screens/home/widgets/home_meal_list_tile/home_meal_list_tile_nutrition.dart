import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../models/meal/nutrition.dart';
import '../../../../util/format.dart';

class HomeMealListTileNutrition extends StatelessWidget {
  final Nutrition nutrition;

  const HomeMealListTileNutrition({
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    final calories = formatNutritionValue(
      nutrition.calories,
    );

    final protein = formatNutritionValue(
      nutrition.protein,
    );
    final carbs = formatNutritionValue(
      nutrition.carbs,
    );
    final fat = formatNutritionValue(
      nutrition.fat,
    );

    return Container(
      decoration: BoxDecoration(
        color: BokunSpizeColors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 16,
      ),
      child: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///
          /// CALORIES
          ///
          if (calories != null)
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Cals'.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      color: BokunSpizeColors.neutralDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    calories,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: BokunSpizeColors.neutralDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ///
          /// PROTEIN
          ///
          if (protein != null)
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Prot'.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      color: BokunSpizeColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${protein}g',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: BokunSpizeColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ///
          /// CARBS
          ///
          if (carbs != null)
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Carb'.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      color: BokunSpizeColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${carbs}g',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: BokunSpizeColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ///
          /// FATS
          ///
          if (fat != null)
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Fat'.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      color: BokunSpizeColors.tertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fat}g',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: BokunSpizeColors.tertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
