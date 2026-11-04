import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/spacing.dart';
import '../../../../util/typedefs.dart';

// TODO: Update staggered animations like other screens

class MacroGoalsSheet extends StatefulWidget {
  final Color activeColor;
  final double bmr;
  final DailyMacroValues initialDailyMacroValues;
  final Function(DailyMacroValues dailyMacroValues) onSavePressed;
  final Function()? onDeletePressed;

  const MacroGoalsSheet({
    required this.activeColor,
    required this.bmr,
    required this.initialDailyMacroValues,
    required this.onSavePressed,
    required this.onDeletePressed,
  });

  @override
  State<MacroGoalsSheet> createState() => _MacroGoalsSheetState();
}

class _MacroGoalsSheetState extends State<MacroGoalsSheet> {
  var validated = false;

  late final bool passedMacroGoalsExist;

  @override
  void initState() {
    super.initState();

    final validMacroGoals = widget.initialDailyCalories > 0 && widget.initialDailyProtein > 0 && widget.initialDailyCarbs > 0 && widget.initialDailyFat > 0;

    passedMacroGoalsExist = widget.onDeletePressed != null && validMacroGoals;
    validated = widget.bmr > 0 && validMacroGoals;
  }

  /// Saves the currently provided daily macro goals
  void onSavePressed() {
    widget.onSavePressed(
      dailyCalories: widget.initialDailyCalories,
      dailyProtein: widget.initialDailyProtein,
      dailyCarbs: widget.initialDailyCarbs,
      dailyFat: widget.initialDailyFat,
    );

    Navigator.of(context).pop();
  }

  void onDeletePressed() {
    if (widget.onDeletePressed != null) {
      widget.onDeletePressed!();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: ColoredBox(
      color: context.colors.scaffoldBackground,
      child: CustomScrollView(
        shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          ///
          /// TITLE & CLOSE BUTTON
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 10),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ///
                    /// DELETE BUTTON
                    ///
                    Opacity(
                      opacity: passedMacroGoalsExist ? 1 : 0,
                      child: IgnorePointer(
                        ignoring: !passedMacroGoalsExist,
                        child: IconButton(
                          onPressed: onDeletePressed,
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.trash,
                            size: 22,
                          ),
                          style: IconButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            backgroundColor: context.colors.delete,
                            foregroundColor: context.colors.listTileBackground,
                          ),
                        ),
                      ),
                    ),

                    ///
                    /// TITLE
                    ///
                    Expanded(
                      child: Text(
                        // TODO
                        'Podaci korisnika',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 0.6,
                          color: context.colors.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    ///
                    /// CLOSE BUTTON
                    ///
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const PhosphorIcon(
                        PhosphorIconsBold.x,
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                        foregroundColor: context.colors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ///
          /// SUBTITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 2,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 8),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Text(
                  // TODO
                  'Tvoje mjere',
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.colors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          // TODO: Content here

          ///
          /// SAVE BUTTON
          ///
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 6,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 14),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: validated ? onSavePressed : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      padding: const EdgeInsets.all(22),
                      backgroundColor: widget.activeColor,
                      foregroundColor: context.colors.buttonText,
                      disabledBackgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      disabledForegroundColor: widget.activeColor,
                    ),
                    child: const Text(
                      // TODO
                      'Spremi',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),

          ///
          /// BOTTOM SPACING
          ///
          SliverToBoxAdapter(
            child: SizedBox(
              height: getBottomSpacing(context),
            ),
          ),
        ],
      ),
    ),
  );
}
