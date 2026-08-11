import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../models/meal/food.dart';
import '../../../../util/format.dart';

class HomeMealListTileFood extends StatelessWidget {
  final Food food;

  const HomeMealListTileFood({
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = formatNutritionValue(
      food.quantity,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///
        /// TITLE & QUANTITY
        ///
        Row(
          children: [
            ///
            /// TITLE
            ///
            Expanded(
              child: Text(
                capitalizeFirstLetter(
                      food.name,
                    ) ??
                    food.name,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.neutralDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            ///
            /// QUANTITY
            ///
            Text(
              '$quantity ${food.unit}',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: BokunSpizeColors.neutralDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 4),

        ///
        /// NUTRITION
        ///
        Row(
          spacing: 8,
          children: [
            Flexible(
              child: Text(
                '${formatNutritionValue(
                  food.nutrition.calories,
                )} kcal',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.neutralDark,
                ),
              ),
            ),
            Flexible(
              child: Text(
                '${formatNutritionValue(
                  food.nutrition.protein,
                )}g P',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.neutralDark,
                ),
              ),
            ),
            Flexible(
              child: Text(
                '${formatNutritionValue(
                  food.nutrition.carbs,
                )}g C',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.neutralDark,
                ),
              ),
            ),
            Flexible(
              child: Text(
                '${formatNutritionValue(
                  food.nutrition.fat,
                )}g F',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.neutralDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
