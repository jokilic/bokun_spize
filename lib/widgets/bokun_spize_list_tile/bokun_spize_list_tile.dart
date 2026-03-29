import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../constants/durations.dart';
import '../../models/meal.dart';
import '../../theme/colors.dart';
import '../../theme/extensions.dart';
import '../../util/color.dart';
import '../../util/formatting.dart';
import 'bokun_spize_list_tile_nutritional_value.dart';

class BokunSpizeListTile extends StatefulWidget {
  final Function() onLongPressed;
  final Future<void> Function() onDeletePressed;
  final Meal meal;

  const BokunSpizeListTile({
    required this.onLongPressed,
    required this.onDeletePressed,
    required this.meal,
    required super.key,
  });

  @override
  State<BokunSpizeListTile> createState() => _BokunSpizeListTileState();
}

class _BokunSpizeListTileState extends State<BokunSpizeListTile> {
  var expanded = false;

  void toggleExpanded() => setState(
    () => expanded = !expanded,
  );

  Widget getLeadingWidget({
    required bool isLoading,
    required bool hasError,
    required String? emoji,
  }) {
    if (isLoading) {
      return Animate(
        onPlay: (controller) => controller.loop(),
        effects: const [
          RotateEffect(
            duration: BokunSpizeDurations.loading,
            curve: Curves.linear,
          ),
        ],
        child: PhosphorIcon(
          PhosphorIcons.spinner(
            PhosphorIconsStyle.duotone,
          ),
          color: context.colors.text,
          duotoneSecondaryColor: context.colors.text,
          size: 20,
        ),
      );
    }

    if (hasError) {
      return PhosphorIcon(
        PhosphorIcons.exclamationMark(
          PhosphorIconsStyle.duotone,
        ),
        color: getWhiteOrBlackColor(
          backgroundColor: context.colors.delete,
          whiteColor: BokunSpizeColors.whiteBackground,
          blackColor: BokunSpizeColors.black,
        ),
        duotoneSecondaryColor: context.colors.delete,
        size: 20,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          widget.meal.emoji ?? '--',
          style: context.textStyles.homeMealTitle,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.meal.isLoading;
    final hasError = widget.meal.error != null;

    final titleText = isLoading ? widget.meal.originalText : widget.meal.name ?? 'Dogodila se greška';

    final leadingColor = isLoading
        ? Colors.transparent
        : !hasError
        ? context.colors.buttonPrimary
        : context.colors.delete;

    final leadingBorderColor = isLoading
        ? context.colors.text
        : !hasError
        ? context.colors.buttonPrimary
        : context.colors.delete;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SwipeActionCell(
          key: ValueKey(widget.meal.id),
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
                await widget.onDeletePressed();
              },
              color: context.colors.delete,
              backgroundRadius: 16,
              icon: PhosphorIcon(
                PhosphorIcons.trash(
                  PhosphorIconsStyle.duotone,
                ),
                color: context.colors.listTileBackground,
                duotoneSecondaryColor: context.colors.buttonPrimary,
                size: 28,
              ),
            ),
          ],
          child: Material(
            color: context.colors.listTileBackground,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: toggleExpanded,
              onLongPress: widget.onLongPressed,
              highlightColor: context.colors.buttonBackground,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///
                    /// LEADING
                    ///
                    AnimatedContainer(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeIn,
                      height: 32,
                      width: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: leadingColor,
                        border: Border.all(
                          color: leadingBorderColor,
                          width: 1.5,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: BokunSpizeDurations.animation,
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: SizedBox.expand(
                          key: ValueKey(
                            'leading-${widget.meal.isLoading}-${widget.meal.error}-${widget.meal.emoji}',
                          ),
                          child: getLeadingWidget(
                            isLoading: isLoading,
                            hasError: hasError,
                            emoji: widget.meal.emoji,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    ///
                    /// TITLE & SUBTITLE
                    ///
                    Expanded(
                      child: AnimatedSize(
                        alignment: Alignment.topLeft,
                        duration: BokunSpizeDurations.animation,
                        curve: Curves.easeIn,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),

                              ///
                              /// TITLE
                              ///
                              AnimatedSwitcher(
                                duration: BokunSpizeDurations.animation,
                                switchInCurve: Curves.easeIn,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                                child: Text(
                                  titleText,
                                  key: ValueKey(
                                    'title-$expanded-${widget.meal.isLoading}-${widget.meal.name}-${widget.meal.originalText}-${widget.meal.error}',
                                  ),
                                  style: context.textStyles.homeMealTitle,
                                  maxLines: expanded || isLoading ? null : 1,
                                  overflow: expanded || isLoading ? TextOverflow.visible : TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),

                              ///
                              /// TIME
                              ///
                              AnimatedSwitcher(
                                duration: BokunSpizeDurations.animation,
                                switchInCurve: Curves.easeIn,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                                child: Text(
                                  DateFormat(
                                    'HH:mm',
                                    'hr',
                                  ).format(
                                    widget.meal.createdAt,
                                  ),
                                  key: ValueKey(
                                    'time-$expanded-${widget.meal.createdAt.toIso8601String()}',
                                  ),
                                  style: context.textStyles.homeMealTime,
                                  maxLines: expanded ? null : 1,
                                  overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                ),
                              ),

                              if (!isLoading) ...[
                                ///
                                /// ADDITIONAL INFO
                                ///
                                AnimatedCrossFade(
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
                                      const SizedBox(height: 6),

                                      ///
                                      /// ERROR
                                      ///
                                      if (hasError) ...[
                                        Text(
                                          'Greška',
                                          style: context.textStyles.homeTitleBold,
                                        ),
                                        const SizedBox(height: 4),

                                        Text(
                                          widget.meal.error ?? '--',
                                          style: context.textStyles.homeMealNote,
                                        ),
                                        const SizedBox(height: 12),
                                      ],

                                      if (!hasError) ...[
                                        ///
                                        /// NUTRITION TITLE
                                        ///
                                        Text(
                                          'Hranjive vrijednosti',
                                          style: context.textStyles.homeTitleBold,
                                        ),
                                        const SizedBox(height: 10),

                                        ///
                                        /// NUTRITION
                                        ///
                                        Row(
                                          spacing: 20,
                                          children: [
                                            ///
                                            /// PROTEIN
                                            ///
                                            Expanded(
                                              child: BokunSpizeListTileNutritionalValue(
                                                valueText: formatNutritionValue(
                                                  widget.meal.nutrition?.protein,
                                                ),
                                                bottomText: 'bje.',
                                                backgroundColor: context.colors.protein,
                                                isLoading: isLoading,
                                              ),
                                            ),

                                            ///
                                            /// CARBS
                                            ///
                                            Expanded(
                                              child: BokunSpizeListTileNutritionalValue(
                                                valueText: formatNutritionValue(
                                                  widget.meal.nutrition?.carbs,
                                                ),
                                                bottomText: 'uglj.',
                                                backgroundColor: context.colors.carbs,
                                                isLoading: isLoading,
                                              ),
                                            ),

                                            ///
                                            /// FATS
                                            ///
                                            Expanded(
                                              child: BokunSpizeListTileNutritionalValue(
                                                valueText: formatNutritionValue(
                                                  widget.meal.nutrition?.fat,
                                                ),
                                                bottomText: 'mas.',
                                                backgroundColor: context.colors.fat,
                                                isLoading: isLoading,
                                              ),
                                            ),
                                          ],
                                        ),

                                        if (widget.meal.foods?.isNotEmpty ?? false) ...[
                                          const SizedBox(height: 16),

                                          ///
                                          /// FOODS TITLE
                                          ///
                                          Text(
                                            'Hrana',
                                            style: context.textStyles.homeTitleBold,
                                          ),
                                          const SizedBox(height: 2),

                                          ///
                                          /// FOODS
                                          ///
                                          ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: widget.meal.foods!.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (_, index) {
                                              final food = widget.meal.foods![index];

                                              final quantity = formatNutritionValue(
                                                food.quantity,
                                              );

                                              return Row(
                                                children: [
                                                  PhosphorIcon(
                                                    PhosphorIcons.dotOutline(
                                                      PhosphorIconsStyle.duotone,
                                                    ),
                                                    color: context.colors.text,
                                                    duotoneSecondaryColor: context.colors.buttonPrimary,
                                                    size: 24,
                                                  ),
                                                  Expanded(
                                                    child: Text.rich(
                                                      TextSpan(
                                                        text: capitalizeFirstLetter(
                                                          food.name,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text: ' ',
                                                            style: context.textStyles.homeMealTime,
                                                          ),
                                                          TextSpan(
                                                            text: quantity,
                                                            style: context.textStyles.homeMealTime,
                                                          ),
                                                          TextSpan(
                                                            text: ' ',
                                                            style: context.textStyles.homeMealTime,
                                                          ),
                                                          TextSpan(
                                                            text: food.unit,
                                                            style: context.textStyles.homeMealTime,
                                                          ),
                                                        ],
                                                      ),
                                                      style: context.textStyles.homeMealKcal,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                      ],

                                      ///
                                      /// ORIGINAL TEXT TITLE
                                      ///
                                      Text(
                                        'Opis',
                                        style: context.textStyles.homeTitleBold,
                                      ),
                                      const SizedBox(height: 4),

                                      Text(
                                        widget.meal.originalText,
                                        style: context.textStyles.homeMealNote,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    ///
                    /// TRAILING
                    ///
                    const SizedBox(width: 12),
                    AnimatedOpacity(
                      opacity: (!isLoading && !hasError) ? 1 : 0,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeIn,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          AnimatedSwitcher(
                            duration: BokunSpizeDurations.animation,
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                            child: Text.rich(
                              key: ValueKey(
                                'trailing-${widget.meal.nutrition?.calories.toStringAsFixed(0) ?? ''}-${widget.meal.isLoading}-${widget.meal.error}',
                              ),
                              TextSpan(
                                text: widget.meal.nutrition?.calories.toStringAsFixed(0) ?? '',
                                children: [
                                  TextSpan(
                                    text: 'kcal',
                                    style: context.textStyles.homeMealKcal,
                                  ),
                                ],
                              ),
                              style: context.textStyles.homeMealValue,
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
            ),
          ),
        ),
      ),
    );
  }
}
