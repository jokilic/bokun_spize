import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../models/meal/meal.dart';
import '../../../../util/date_time.dart';
import '../../../../util/format.dart';
import 'meals_list_tile_food.dart';
import 'meals_list_tile_nutrition.dart';

class MealsListTile extends StatefulWidget {
  final Future<void> Function() onDeletePressed;
  final Future<void> Function() onCopyPressed;
  final Meal meal;

  const MealsListTile({
    required this.onDeletePressed,
    required this.onCopyPressed,
    required this.meal,
  });

  @override
  State<MealsListTile> createState() => _MealsListTileState();
}

class _MealsListTileState extends State<MealsListTile> {
  var expanded = false;

  void toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(
      () => expanded = !expanded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.meal.isLoading;
    final hasError = widget.meal.errors?.isNotEmpty ?? false;

    final titleText = isLoading ? widget.meal.originalText ?? '📷' : widget.meal.name ?? 'Greška';

    final subtitleText =
        capitalizeFirstLetter(
          widget.meal.foods?.map((food) => food.name.toLowerCase()).join(', '),
        ) ??
        widget.meal.errors?.map((error) => error).join(', ');

    final imageBackgroundColor = isLoading
        ? BokunSpizeColors.grey
        : hasError
        ? BokunSpizeColors.tertiary
        : widget.meal.color ?? BokunSpizeColors.grey;

    final borderColor = hasError
        ? BokunSpizeColors.tertiary
        : expanded
        ? widget.meal.color ?? BokunSpizeColors.primary
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(listTileRadius),
        child: SwipeActionCell(
          key: ValueKey(widget.meal.id),
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
                await widget.onDeletePressed();
              },
              color: BokunSpizeColors.tertiary,
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
                await widget.onCopyPressed();
              },
              color: BokunSpizeColors.secondary,
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
              onTap: isLoading || hasError ? null : toggleExpanded,
              borderRadius: BorderRadius.circular(listTileRadius),
              highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(listTileRadius),
                  border: Border.all(
                    color: borderColor,
                    width: 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ///
                    /// TOP SECTION
                    ///
                    AnimatedSize(
                      alignment: Alignment.topLeft,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeIn,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              borderRadius: BorderRadius.circular(24),
                              child: widget.meal.imageStoragePath != null
                                  ? Image.network(
                                      widget.meal.imageStoragePath!,
                                      height: 92,
                                      width: 92,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 92,
                                      width: 92,
                                      color: imageBackgroundColor,
                                      child: hasError
                                          ? const PhosphorIcon(
                                              PhosphorIconsBold.warningOctagon,
                                              color: BokunSpizeColors.white,
                                              size: 40,
                                            )
                                          : FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                widget.meal.emoji ?? '',
                                                style: const TextStyle(
                                                  fontFamily: 'PlusJakartaSans',
                                                  fontSize: 40,
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
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///
                                    /// TITLE
                                    ///
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 48),
                                        child: Animate(
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
                                          child: AnimatedCrossFade(
                                            alignment: Alignment.centerLeft,
                                            duration: BokunSpizeDurations.animation,
                                            firstCurve: Curves.easeIn,
                                            secondCurve: Curves.easeIn,
                                            sizeCurve: Curves.easeIn,
                                            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                            firstChild: Text(
                                              capitalizeFirstLetter(
                                                    titleText,
                                                  ) ??
                                                  '',
                                              style: const TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                height: 1.4,
                                                color: BokunSpizeColors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            secondChild: Text(
                                              capitalizeFirstLetter(titleText) ?? '',
                                              style: const TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                height: 1.4,
                                                color: BokunSpizeColors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    ///
                                    /// SUBTITLE
                                    ///
                                    SizedBox(
                                      height: isLoading ? 8 : 4,
                                    ),
                                    if (subtitleText != null)
                                      AnimatedCrossFade(
                                        alignment: Alignment.centerLeft,
                                        duration: BokunSpizeDurations.animation,
                                        firstCurve: Curves.easeIn,
                                        secondCurve: Curves.easeIn,
                                        sizeCurve: Curves.easeIn,
                                        crossFadeState: expanded || hasError ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                        firstChild: Text(
                                          subtitleText,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            height: 1.4,
                                            letterSpacing: 1.4,
                                            color: BokunSpizeColors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        secondChild: Text(
                                          subtitleText,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            height: 1.4,
                                            letterSpacing: 1.4,
                                            color: BokunSpizeColors.black,
                                          ),
                                        ),
                                      )
                                    else if (isLoading)
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
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: BokunSpizeColors.white,
                                          ),
                                          height: 20,
                                          width: 160,
                                        ),
                                      ),

                                    ///
                                    /// CALORIES
                                    ///
                                    if (!hasError) ...[
                                      const SizedBox(height: 10),
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
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(100),
                                            color: isLoading ? BokunSpizeColors.white : BokunSpizeColors.tertiary.withValues(alpha: 0.25),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 48,
                                                  height: 12,
                                                )
                                              : Text(
                                                  '${formatNutritionValue(
                                                    widget.meal.nutrition?.calories,
                                                  )} kcal',
                                                  style: const TextStyle(
                                                    fontFamily: 'PlusJakartaSans',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.4,
                                                    color: BokunSpizeColors.tertiary,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                ///
                                /// TIME
                                ///
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    getDateString(
                                      date: widget.meal.createdAt,
                                      dateFormat: 'HH:mm',
                                      useTodayYesterdayTomorrow: false,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                      letterSpacing: 1,
                                      color: BokunSpizeColors.black.withValues(alpha: 0.75),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    ///
                    /// BOTTOM SECTION
                    ///
                    AnimatedSwitcher(
                      duration: BokunSpizeDurations.animation,
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: AnimatedCrossFade(
                        alignment: Alignment.centerLeft,
                        duration: BokunSpizeDurations.animation,
                        firstCurve: Curves.easeIn,
                        secondCurve: Curves.easeIn,
                        sizeCurve: Curves.easeIn,
                        crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),

                            ///
                            /// NUTRITION
                            ///
                            if (widget.meal.nutrition != null) ...[
                              MealsListTileNutrition(
                                nutrition: widget.meal.nutrition!,
                              ),
                              const SizedBox(height: 24),
                            ],

                            ///
                            /// FOODS
                            ///
                            if (widget.meal.foods?.isNotEmpty ?? false) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  'Namirnice'.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: BokunSpizeColors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: widget.meal.foods!.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (_, index) {
                                  final food = widget.meal.foods![index];

                                  return MealsListTileFood(
                                    food: food,
                                  );
                                },
                                separatorBuilder: (_, __) => Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 1,
                                      color: BokunSpizeColors.grey,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
