import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../models/meal/food.dart';
import '../../../util/color.dart';
import '../../../util/format.dart';

class ManualAddMealFoodListTile extends StatelessWidget {
  final Function() onPressed;
  final Function() onDeletePressed;
  final Food food;
  final int index;

  const ManualAddMealFoodListTile({
    required this.onPressed,
    required this.onDeletePressed,
    required this.food,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = getCalorieValueColor(
      nutrition: food.nutrition,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(listTileRadius),
        child: SwipeActionCell(
          key: ValueKey('${food.name}-$index'),
          backgroundColor: BokunSpizeColors.grey,
          openAnimationDuration: 175,
          closeAnimationDuration: 175,
          deleteAnimationDuration: 175,
          openAnimationCurve: Curves.easeIn,
          closeAnimationCurve: Curves.easeIn,
          leadingActions: [
            SwipeAction(
              onTap: (handler) async {
                await handler(true);
                await onDeletePressed();
              },
              color: BokunSpizeColors.red,
              backgroundRadius: listTileRadius,
              icon: const PhosphorIcon(
                PhosphorIconsBold.trash,
                color: BokunSpizeColors.white,
                size: 26,
              ),
            ),
          ],
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(listTileRadius),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(listTileRadius),
              highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(listTileRadius),
                  color: BokunSpizeColors.white.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ///
                    /// ICON
                    ///
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.all(listTileIconRadius / 4),
                        color: BokunSpizeColors.grey,
                        child: PhosphorIcon(
                          PhosphorIconsBold.bowlFood,
                          color: primaryColor,
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
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: BokunSpizeColors.black,
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
                                color: BokunSpizeColors.black.withValues(alpha: 0.7),
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
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: BokunSpizeColors.green,
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
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: BokunSpizeColors.blue,
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
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: BokunSpizeColors.bordeaux,
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
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                              color: BokunSpizeColors.black.withValues(alpha: 0.5),
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
      ),
    );
  }
}
