import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../models/meal/food.dart';
import '../../../theme/extensions.dart';
import '../../../util/color.dart';
import '../../../util/format.dart';

class ViewMealFoodListTile extends StatelessWidget {
  final Food food;

  const ViewMealFoodListTile({
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        food.color ??
        getCalorieValueColor(
          nutrition: food.nutrition,
          context: context,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(listTileRadius),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(listTileRadius),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(listTileRadius),
            highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(listTileRadius),
                color: context.colors.listTileBackground.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ///
                  /// ICON
                  ///
                  ClipOval(
                    child: Container(
                      width: listTileIconRadius,
                      height: listTileIconRadius,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(listTileIconRadius / 4),
                      color: primaryColor,
                      child: food.emoji != null
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                food.emoji!,
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 24,
                                ),
                                maxLines: 1,
                                softWrap: false,
                              ),
                            )
                          : PhosphorIcon(
                              PhosphorIconsBold.bowlFood,
                              color: context.colors.buttonText,
                              size: listTileIconRadius / 2,
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  ///
                  /// TEXT
                  ///
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///
                        /// TITLE
                        ///
                        Text(
                          food.name,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: context.colors.text,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        ///
                        /// SUBTITLE
                        ///
                        if (food.quantity > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${formatNutritionValue(
                              food.quantity,
                            )} ${food.unit}',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.colors.text.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        ///
                        /// NUTRITION
                        ///
                        if (food.nutrition.protein > 0 || food.nutrition.carbs > 0 || food.nutrition.fat > 0) ...[
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              text: food.nutrition.protein > 0
                                  ? '${formatNutritionValue(
                                      food.nutrition.protein,
                                    )}g'
                                  : null,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.protein,
                              ),
                              children: [
                                if (food.nutrition.protein > 0)
                                  const WidgetSpan(
                                    child: SizedBox(width: 8),
                                  ),
                                TextSpan(
                                  text: food.nutrition.carbs > 0
                                      ? '${formatNutritionValue(
                                          food.nutrition.carbs,
                                        )}g'
                                      : null,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.carbs,
                                  ),
                                ),
                                if (food.nutrition.carbs > 0)
                                  const WidgetSpan(
                                    child: SizedBox(width: 8),
                                  ),
                                TextSpan(
                                  text: food.nutrition.fat > 0
                                      ? '${formatNutritionValue(
                                          food.nutrition.fat,
                                        )}g'
                                      : null,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.fat,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  ///
                  /// CALORIES
                  ///
                  if (food.nutrition.calories > 0)
                    Column(
                      children: [
                        ///
                        /// CALORIES VALUE
                        ///
                        Text(
                          formatNutritionValue(
                                food.nutrition.calories,
                              ) ??
                              '',
                          style: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),

                        ///
                        /// CALORIES UNIT
                        ///
                        Text(
                          'kcal'.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.colors.text.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
