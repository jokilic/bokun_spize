import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/meal/meal.dart';
import '../../../util/format.dart';
import '../../../widgets/meal_image.dart';

class MealsListTile extends StatelessWidget {
  final Function() onPressed;
  final Function() onDeletePressed;
  final Function() onCopyPressed;
  final Meal meal;

  const MealsListTile({
    required this.onPressed,
    required this.onDeletePressed,
    required this.onCopyPressed,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = meal.isLoading;
    final hasError = meal.errors?.isNotEmpty ?? false;

    final titleText = isLoading ? meal.originalText ?? '📷' : capitalizeFirstLetter(meal.name) ?? 'Erroro has happendo';

    final subtitleText =
        capitalizeFirstLetter(
          meal.foods?.map((food) => food.name.toLowerCase()).join(', '),
        ) ??
        meal.errors?.map((error) => error).join(', ') ??
        '';

    final imageBackgroundColor = isLoading
        ? BokunSpizeColors.grey
        : hasError
        ? BokunSpizeColors.red
        : meal.color ?? BokunSpizeColors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(listTileRadius),
        child: SwipeActionCell(
          key: ValueKey(meal.id),
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
          trailingActions: [
            SwipeAction(
              onTap: (handler) async {
                await handler(false);
                await onCopyPressed();
              },
              color: BokunSpizeColors.green,
              backgroundRadius: listTileRadius,
              icon: const PhosphorIcon(
                PhosphorIconsBold.copy,
                color: BokunSpizeColors.white,
                size: 26,
              ),
            ),
          ],
          child: Material(
            color: BokunSpizeColors.white,
            borderRadius: BorderRadius.circular(listTileRadius),
            child: InkWell(
              onTap: isLoading || hasError ? null : onPressed,
              borderRadius: BorderRadius.circular(listTileRadius),
              highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(listTileRadius),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ///
                    /// IMAGE OR EMOJI
                    ///
                    Animate(
                      onPlay: (controller) {
                        if (isLoading) {
                          controller.loop(
                            reverse: true,
                            min: 0.6,
                          );
                        }
                      },
                      effects: [
                        if (isLoading)
                          const FadeEffect(
                            duration: BokunSpizeDurations.shimmer,
                            curve: Curves.easeIn,
                          ),
                      ],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: meal.imageStoragePath != null
                            ? MealImage(
                                imageStoragePath: meal.imageStoragePath!,
                                height: listTileIconRadius,
                                width: listTileIconRadius,
                                errorWidget: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  height: listTileIconRadius,
                                  width: listTileIconRadius,
                                  child: const PhosphorIcon(
                                    PhosphorIconsBold.warningOctagon,
                                    color: BokunSpizeColors.white,
                                    size: 24,
                                  ),
                                ),
                              )
                            : Container(
                                height: listTileIconRadius,
                                width: listTileIconRadius,
                                color: imageBackgroundColor,
                                child: hasError
                                    ? const PhosphorIcon(
                                        PhosphorIconsBold.warningOctagon,
                                        color: BokunSpizeColors.white,
                                        size: 24,
                                      )
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          meal.emoji ?? '',
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 24,
                                          ),
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
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
                            titleText,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: BokunSpizeColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          ///
                          /// SUBTITLE
                          ///
                          Text(
                            subtitleText,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: BokunSpizeColors.black.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    ///
                    /// CALORIES
                    ///
                    Column(
                      children: [
                        Text(
                          formatNutritionValue(
                                meal.nutrition?.calories,
                              ) ??
                              '',
                          style: const TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: BokunSpizeColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
