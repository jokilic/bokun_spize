import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../models/meal/food.dart';
import '../../../theme/extensions.dart';
import '../../../util/color.dart';
import '../../../util/format.dart';

class ManualAddMealFoodListTile extends StatelessWidget {
  final Function() onPressed;
  final Function() onDeletePressed;
  final Food food;
  final int index;
  final bool enabled;

  const ManualAddMealFoodListTile({
    required this.onPressed,
    required this.onDeletePressed,
    required this.food,
    required this.index,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = getCalorieValueColor(
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
        child: SwipeActionCell(
          index: index,
          isDraggable: enabled,
          key: ObjectKey(food),
          backgroundColor: context.colors.scaffoldBackground,
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
              color: context.colors.delete,
              backgroundRadius: listTileRadius,
              icon: PhosphorIcon(
                PhosphorIconsBold.trash,
                color: context.colors.listTileBackground,
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
              highlightColor: context.colors.listTileBackground.withValues(
                alpha: enabled ? 0.5 : 0.25,
              ),
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(listTileRadius),
                  color: context.colors.listTileBackground.withValues(
                    alpha: enabled ? 0.5 : 0.25,
                  ),
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
                        color: context.colors.scaffoldBackground,
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
      ),
    );
  }
}
