import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/durations.dart';
import '../models/meal.dart';
import '../theme/extensions.dart';

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
                        color: context.colors.buttonPrimary,
                        border: Border.all(
                          color: context.colors.buttonPrimary,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
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
                      ),
                    ),
                    const SizedBox(width: 12),

                    ///
                    /// TITLE & SUBTITLE
                    ///
                    Expanded(
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
                              widget.meal.name ?? '--',
                              style: context.textStyles.homeMealTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            secondChild: Text(
                              widget.meal.name ?? '--',
                              style: context.textStyles.homeMealTitle,
                            ),
                          ),

                          ///
                          /// TIME
                          ///
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
                        ],
                      ),
                    ),

                    ///
                    /// TRAILING
                    ///
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
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
