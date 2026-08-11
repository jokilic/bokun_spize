import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

import '../../../constants/colors.dart';
import '../../../constants/durations.dart';
import '../../../models/meal/meal.dart';

class HomeMealListTile extends StatefulWidget {
  final Future<void> Function() onDeletePressed;
  final Future<void> Function() onCopyPressed;
  final Meal meal;

  const HomeMealListTile({
    required this.onDeletePressed,
    required this.onCopyPressed,
    required this.meal,
  });

  @override
  State<HomeMealListTile> createState() => _HomeMealListTileState();
}

class _HomeMealListTileState extends State<HomeMealListTile> {
  var expanded = false;

  void toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(
      () => expanded = !expanded,
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SwipeActionCell(
        key: ValueKey(widget.meal.id),
        backgroundColor: BokunSpizeColors.white,
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
            backgroundRadius: 16,
            icon: const Icon(
              Icons.tram_rounded,
              color: BokunSpizeColors.white,
              size: 28,
            ),
          ),
        ],
        trailingActions: [
          SwipeAction(
            onTap: (handler) async {
              await handler(false);
              await widget.onCopyPressed();
            },
            color: BokunSpizeColors.alternative,
            backgroundRadius: 16,
            icon: const Icon(
              Icons.copy_rounded,
              color: BokunSpizeColors.white,
              size: 28,
            ),
          ),
        ],
        child: Material(
          color: BokunSpizeColors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            highlightColor: BokunSpizeColors.neutralLight.withValues(alpha: 0.5),
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ///
                  /// TOP SECTION
                  ///
                  Row(
                    children: [
                      ///
                      /// IMAGE
                      ///
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://thedeliciousplate.com/wp-content/uploads/2024/01/Mediterranean-tomato-and-cucumber-salad-11.jpg',
                          height: 92,
                          width: 92,
                          fit: BoxFit.cover,
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
                            /// TITLE & TIME
                            ///
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ///
                                /// TITLE
                                ///
                                const Expanded(
                                  child: Text(
                                    'Raw nut mix',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1.4,
                                      color: BokunSpizeColors.neutralDark,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                const SizedBox(width: 4),

                                ///
                                /// TIME
                                ///
                                Text(
                                  '15:15',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1,
                                    letterSpacing: 1,
                                    color: BokunSpizeColors.neutralDark.withValues(alpha: 0.75),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            ///
                            /// FOOD
                            ///
                            const Text(
                              'Quinoa, chickpeas, tahini',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                                letterSpacing: 1.4,
                                color: BokunSpizeColors.neutralDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            ///
                            /// CALORIES
                            ///
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: BokunSpizeColors.tertiary.withValues(alpha: 0.25),
                              ),
                              child: const Text(
                                '580 kcal',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                  color: BokunSpizeColors.tertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      secondChild: Container(
                        height: 300,
                        width: 50,
                        color: BokunSpizeColors.primary,
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
