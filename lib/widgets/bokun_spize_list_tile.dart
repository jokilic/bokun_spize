import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/durations.dart';
import '../models/meal.dart';
import '../theme/colors.dart';
import '../theme/extensions.dart';
import '../util/color.dart';

class BokunSpizeListTile extends StatefulWidget {
  final Function() onLongPressed;
  final Function() onDeletePressed;
  final Meal meal;

  const BokunSpizeListTile({
    required this.onLongPressed,
    required this.onDeletePressed,
    required this.meal,
  });

  @override
  State<BokunSpizeListTile> createState() => _BokunSpizeListTileState();
}

class _BokunSpizeListTileState extends State<BokunSpizeListTile> {
  var expanded = false;

  void toggleExpanded() => setState(
    () => expanded = !expanded,
  );

  @override
  Widget build(BuildContext context) => AnimatedSize(
    alignment: Alignment.topCenter,
    duration: BokunSpizeDurations.animation,
    curve: Curves.easeIn,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SwipeActionCell(
          key: ValueKey(widget.meal),
          backgroundColor: context.colors.scaffoldBackground,
          openAnimationDuration: 175,
          closeAnimationDuration: 175,
          deleteAnimationDuration: 175,
          openAnimationCurve: Curves.easeIn,
          closeAnimationCurve: Curves.easeIn,
          leadingActions: [
            SwipeAction(
              onTap: (handler) async {
                unawaited(
                  handler(true),
                );
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
                    Container(
                      height: 32,
                      width: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.meal.isLoading
                            ? Colors.transparent
                            : widget.meal.error == null
                            ? context.colors.buttonPrimary
                            : context.colors.delete,
                        border: Border.all(
                          color: widget.meal.isLoading
                              ? context.colors.text
                              : widget.meal.error == null
                              ? context.colors.buttonPrimary
                              : context.colors.delete,
                          width: 1.5,
                        ),
                      ),
                      child: widget.meal.isLoading
                          ? PhosphorIcon(
                              PhosphorIcons.spinnerGap(
                                PhosphorIconsStyle.duotone,
                              ),
                              color: context.colors.text,
                              duotoneSecondaryColor: context.colors.text,
                              size: 20,
                            )
                          : widget.meal.error == null
                          ? Padding(
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
                            )
                          : PhosphorIcon(
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
                            ),
                    ),
                    const SizedBox(width: 12),

                    ///
                    /// TITLE & SUBTITLE
                    ///
                    Expanded(
                      child: Animate(
                        key: ValueKey(widget.meal.isLoading),
                        onPlay: (controller) => controller.loop(
                          reverse: true,
                          min: 0.6,
                        ),
                        effects: [
                          if (widget.meal.isLoading)
                            const FadeEffect(
                              curve: Curves.easeIn,
                              duration: BokunSpizeDurations.loading,
                            ),
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),

                            ///
                            /// TITLE
                            ///
                            AnimatedCrossFade(
                              duration: BokunSpizeDurations.animation,
                              firstCurve: Curves.easeIn,
                              secondCurve: Curves.easeIn,
                              sizeCurve: Curves.easeIn,
                              crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                              firstChild: Text(
                                widget.meal.isLoading ? widget.meal.originalText : widget.meal.name ?? widget.meal.error ?? '--',
                                style: context.textStyles.homeMealTitle,
                                maxLines: widget.meal.isLoading ? null : 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              secondChild: Text(
                                widget.meal.isLoading ? widget.meal.originalText : widget.meal.name ?? widget.meal.error ?? '--',
                                style: context.textStyles.homeMealTitle,
                              ),
                            ),

                            ///
                            /// TIME
                            ///
                            if (!widget.meal.isLoading) ...[
                              const SizedBox(height: 4),
                              AnimatedCrossFade(
                                duration: BokunSpizeDurations.animation,
                                firstCurve: Curves.easeIn,
                                secondCurve: Curves.easeIn,
                                sizeCurve: Curves.easeIn,
                                crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                firstChild: Text(
                                  DateFormat(
                                    'HH:mm',
                                    'hr',
                                  ).format(
                                    widget.meal.createdAt,
                                  ),
                                  style: context.textStyles.homeMealTime,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                secondChild: Text(
                                  DateFormat(
                                    'HH:mm',
                                    'hr',
                                  ).format(
                                    widget.meal.createdAt,
                                  ),
                                  style: context.textStyles.homeMealTime,
                                ),
                              ),

                              ///
                              /// ADDITIONAL INFO
                              ///
                              AnimatedCrossFade(
                                duration: BokunSpizeDurations.animation,
                                firstCurve: Curves.easeIn,
                                secondCurve: Curves.easeIn,
                                sizeCurve: Curves.easeIn,
                                crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                firstChild: const SizedBox.shrink(),
                                secondChild: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    ///
                    /// TRAILING
                    ///
                    if (!widget.meal.isLoading && widget.meal.error == null) ...[
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              text: widget.meal.nutrition?.calories.toStringAsFixed(0) ?? '--',
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
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
