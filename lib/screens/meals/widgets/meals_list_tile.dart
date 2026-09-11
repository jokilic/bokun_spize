import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/meal/meal.dart';
import '../../../theme/extensions.dart';
import '../../../util/color.dart';
import '../../../util/date_time.dart';
import '../../../util/format.dart';
import '../../../widgets/meal_image.dart';

class MealsListTile extends StatelessWidget {
  final Function() onPressed;
  final Function() onLongPressed;
  final Function() onDeletePressed;
  final Function() onCopyPressed;
  final Meal meal;
  final int index;

  const MealsListTile({
    required this.onPressed,
    required this.onLongPressed,
    required this.onDeletePressed,
    required this.onCopyPressed,
    required this.meal,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = meal.isLoading;
    final hasError = meal.errors?.isNotEmpty ?? false;

    final titleText = isLoading ? meal.originalText ?? '📷' : capitalizeFirstLetter(meal.name) ?? '📷';

    final subtitleText = getDateString(
      date: meal.createdAt,
      dateFormat: 'HH:mm',
      useTodayYesterdayTomorrow: false,
    );

    final primaryColor = getCalorieValueColor(
      nutrition: meal.nutrition,
      context: context,
    );

    final imageBackgroundColor = isLoading
        ? context.colors.scaffoldBackground
        : hasError
        ? context.colors.delete
        : meal.color ?? primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(listTileRadius),
        child: SwipeActionCell(
          index: index,
          key: ValueKey(meal.id),
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
          trailingActions: [
            SwipeAction(
              onTap: (handler) async {
                await handler(false);
                await onCopyPressed();
              },
              color: context.colors.protein,
              backgroundRadius: listTileRadius,
              icon: PhosphorIcon(
                PhosphorIconsBold.copy,
                color: context.colors.listTileBackground,
                size: 26,
              ),
            ),
          ],
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(listTileRadius),
            child: InkWell(
              onTap: isLoading || hasError ? null : onPressed,
              onLongPress: isLoading || hasError ? null : onLongPressed,
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
                    /// LOADING IMAGE
                    ///
                    if (isLoading)
                      Animate(
                        onPlay: (controller) => controller.loop(
                          reverse: true,
                          min: 0.6,
                        ),
                        effects: const [
                          FadeEffect(
                            duration: BokunSpizeDurations.shimmer,
                            curve: Curves.easeIn,
                          ),
                        ],
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: getRandomPrimaryColor().withValues(alpha: 0.5),
                          ),
                          height: listTileIconRadius,
                          width: listTileIconRadius,
                        ),
                      )
                    ///
                    /// IMAGE OR EMOJI
                    ///
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: meal.imageStoragePath != null
                            ? MealImage(
                                imageStoragePath: meal.imageStoragePath!,
                                height: listTileIconRadius,
                                width: listTileIconRadius,
                                placeholderWidget: Animate(
                                  onPlay: (controller) => controller.loop(
                                    reverse: true,
                                    min: 0.6,
                                  ),
                                  effects: const [
                                    FadeEffect(
                                      duration: BokunSpizeDurations.shimmer,
                                      curve: Curves.easeIn,
                                    ),
                                  ],
                                  child: Container(
                                    color: getRandomPrimaryColor().withValues(alpha: 0.5),
                                    height: listTileIconRadius,
                                    width: listTileIconRadius,
                                  ),
                                ),
                                errorWidget: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: context.colors.delete,
                                  ),
                                  height: listTileIconRadius,
                                  width: listTileIconRadius,
                                  child: PhosphorIcon(
                                    PhosphorIconsBold.warningOctagon,
                                    color: context.colors.listTileBackground,
                                    size: 24,
                                  ),
                                ),
                              )
                            : Container(
                                height: listTileIconRadius,
                                width: listTileIconRadius,
                                color: imageBackgroundColor,
                                child: hasError
                                    ? PhosphorIcon(
                                        PhosphorIconsBold.warningOctagon,
                                        color: context.colors.listTileBackground,
                                        size: 24,
                                      )
                                    : meal.emoji != null
                                    ? FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          meal.emoji!,
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
                                        color: context.colors.listTileBackground,
                                        size: 24,
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
                          /// LOADING TITLE
                          ///
                          if (isLoading)
                            Animate(
                              onPlay: (controller) => controller.loop(
                                reverse: true,
                                min: 0.6,
                              ),
                              effects: const [
                                FadeEffect(
                                  duration: BokunSpizeDurations.shimmer,
                                  curve: Curves.easeIn,
                                ),
                              ],
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                                ),
                                height: 20,
                                width: 112,
                              ),
                            )
                          ///
                          /// TITLE
                          ///
                          else
                            Text(
                              titleText,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: context.colors.text,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 2),

                          ///
                          /// LOADING SUBTITLE
                          ///
                          if (isLoading) ...[
                            const SizedBox(height: 8),
                            Animate(
                              onPlay: (controller) => controller.loop(
                                reverse: true,
                                min: 0.6,
                              ),
                              effects: const [
                                FadeEffect(
                                  duration: BokunSpizeDurations.shimmer,
                                  curve: Curves.easeIn,
                                ),
                              ],
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                                ),
                                height: 12,
                                width: 56,
                              ),
                            ),
                          ]
                          ///
                          /// SUBTITLE
                          ///
                          else
                            Text(
                              subtitleText,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.colors.text.withValues(alpha: 0.7),
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
                        ///
                        /// CALORIES VALUE
                        ///
                        if (isLoading)
                          Animate(
                            onPlay: (controller) => controller.loop(
                              reverse: true,
                              min: 0.6,
                            ),
                            effects: const [
                              FadeEffect(
                                duration: BokunSpizeDurations.shimmer,
                                curve: Curves.easeIn,
                              ),
                            ],
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                              ),
                              height: 28,
                              width: 48,
                            ),
                          )
                        else
                          Text(
                            formatNutritionValue(
                                  meal.nutrition?.calories,
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
                        if (isLoading) ...[
                          const SizedBox(height: 8),
                          Animate(
                            onPlay: (controller) => controller.loop(
                              reverse: true,
                              min: 0.6,
                            ),
                            effects: const [
                              FadeEffect(
                                duration: BokunSpizeDurations.shimmer,
                                curve: Curves.easeIn,
                              ),
                            ],
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                              ),
                              height: 12,
                              width: 32,
                            ),
                          ),
                        ] else
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
