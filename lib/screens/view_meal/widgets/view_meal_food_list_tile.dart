import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
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
                                style: context.textStyles.listTileEmoji,
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
                          style: context.textStyles.listTileTitle,
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
                            style: context.textStyles.listTileNutritionValue.copyWith(
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
                                    )}${'gramUnit'.tr()}'
                                  : null,
                              style: context.textStyles.listTileNutritionValue.copyWith(
                                color: context.colors.protein,
                              ),
                              children: [
                                if (food.nutrition.protein > 0 && (food.nutrition.carbs > 0 || food.nutrition.fat > 0))
                                  WidgetSpan(
                                    child: PhosphorIcon(
                                      PhosphorIconsBold.dotOutline,
                                      size: 14,
                                      color: context.colors.text.withValues(alpha: 0.7),
                                    ),
                                  ),
                                TextSpan(
                                  text: food.nutrition.carbs > 0
                                      ? '${formatNutritionValue(
                                          food.nutrition.carbs,
                                        )}${'gramUnit'.tr()}'
                                      : null,
                                  style: context.textStyles.listTileNutritionValue.copyWith(
                                    color: context.colors.carbs,
                                  ),
                                ),
                                if (food.nutrition.carbs > 0 && food.nutrition.fat > 0)
                                  WidgetSpan(
                                    child: PhosphorIcon(
                                      PhosphorIconsBold.dotOutline,
                                      size: 14,
                                      color: context.colors.text.withValues(alpha: 0.7),
                                    ),
                                  ),
                                TextSpan(
                                  text: food.nutrition.fat > 0
                                      ? '${formatNutritionValue(
                                          food.nutrition.fat,
                                        )}${'gramUnit'.tr()}'
                                      : null,
                                  style: context.textStyles.listTileNutritionValue.copyWith(
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
                          style: context.textStyles.listTileCaloriesValue.copyWith(
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
                          'caloriesUnit'.tr().toUpperCase(),
                          style: context.textStyles.listTileCaloriesUnit,
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
