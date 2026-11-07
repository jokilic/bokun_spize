import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/spacing.dart';
import '../../../../util/typedefs.dart';
import '../../../../widgets/animated_digit_widget.dart';

class MacroGoalsSheet extends StatefulWidget {
  final Color activeColor;
  final double bmr;
  final DailyMacroValues initialDailyMacroValues;
  final DailyMacroValues? Function(double calories) calculateDailyMacroValues;
  final bool macroGoalsExist;
  final Function(DailyMacroValues dailyMacroValues) onSavePressed;
  final Function()? onDeletePressed;

  const MacroGoalsSheet({
    required this.activeColor,
    required this.bmr,
    required this.initialDailyMacroValues,
    required this.calculateDailyMacroValues,
    required this.macroGoalsExist,
    required this.onSavePressed,
    required this.onDeletePressed,
  });

  @override
  State<MacroGoalsSheet> createState() => _MacroGoalsSheetState();
}

class _MacroGoalsSheetState extends State<MacroGoalsSheet> {
  var validated = false;

  double? activeCalories;
  double? activeProtein;
  double? activeCarbs;
  double? activeFat;

  Timer? caloriesUpdateTimer;

  @override
  void initState() {
    super.initState();

    final dailyMacroValues = widget.initialDailyMacroValues;

    activeCalories = dailyMacroValues.calories;
    activeProtein = dailyMacroValues.protein;
    activeCarbs = dailyMacroValues.carbs;
    activeFat = dailyMacroValues.fat;

    updateValidated();
  }

  @override
  void dispose() {
    stopCaloriesUpdate();
    super.dispose();
  }

  /// Updates whether all daily macro values can be saved
  void updateValidated() => validated = (activeCalories ?? 0) > 0 && (activeProtein ?? 0) > 0 && (activeCarbs ?? 0) > 0 && (activeFat ?? 0) > 0;

  /// Recalculates all daily macro values for the selected calorie target
  bool updateCalories(double newCalories) {
    final newDailyMacroValues = widget.calculateDailyMacroValues(newCalories);

    if ((newDailyMacroValues?.carbs ?? 0) <= 0) {
      return false;
    }

    setState(() {
      activeCalories = newDailyMacroValues!.calories;
      activeProtein = newDailyMacroValues.protein;
      activeCarbs = newDailyMacroValues.carbs;
      activeFat = newDailyMacroValues.fat;

      updateValidated();
    });

    return true;
  }

  /// Starts updating calories while the button remains pressed
  void startCaloriesUpdate(double amount) {
    stopCaloriesUpdate();

    if (!changeCalories(amount)) {
      return;
    }

    caloriesUpdateTimer = Timer.periodic(
      BokunSpizeDurations.animation,
      (_) => changeCalories(amount),
    );
  }

  /// Changes calories by one 50 calorie step
  bool changeCalories(double amount) {
    final currentCalories = activeCalories ?? 0;
    final steppedCalories = amount.isNegative ? ((currentCalories / 50).ceil() - 1) * 50 : ((currentCalories / 50).floor() + 1) * 50;

    final newCalories = steppedCalories.clamp(0, double.infinity).toDouble();

    if (newCalories == currentCalories) {
      stopCaloriesUpdate();
      return false;
    }

    if (!updateCalories(newCalories)) {
      stopCaloriesUpdate();
      return false;
    }

    HapticFeedback.lightImpact();

    return true;
  }

  /// Stops the active calorie update timer
  void stopCaloriesUpdate() {
    caloriesUpdateTimer?.cancel();
    caloriesUpdateTimer = null;
  }

  /// Saves the currently provided daily macro goals
  void onSavePressed() {
    final newDailyMacroValues = (
      calories: activeCalories!,
      protein: activeProtein!,
      carbs: activeCarbs!,
      fat: activeFat!,
    );

    widget.onSavePressed(newDailyMacroValues);

    Navigator.of(context).pop();
  }

  /// Deletes the currently saved daily macro goals
  void onDeletePressed() {
    if (widget.onDeletePressed != null) {
      widget.onDeletePressed!();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCalories = activeCalories ?? 0;

    final currentProtein = activeProtein ?? 0;
    final currentCarbs = activeCarbs ?? 0;
    final currentFat = activeFat ?? 0;

    final proteinCalories = currentProtein * 4;
    final proteinPercentage = currentCalories > 0 ? proteinCalories / currentCalories * 100 : 0;

    final carbsCalories = currentCarbs * 4;
    final carbsPercentage = currentCalories > 0 ? carbsCalories / currentCalories * 100 : 0;

    final fatCalories = currentFat * 9;
    final fatPercentage = currentCalories > 0 ? fatCalories / currentCalories * 100 : 0;

    final decreasedCalories = (((currentCalories / 50).ceil() - 1) * 50).clamp(0, double.infinity).toDouble();
    final canDecreaseCalories = (widget.calculateDailyMacroValues(decreasedCalories)?.carbs ?? 0) > 0;

    return ClipRRect(
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
                        opacity: widget.macroGoalsExist ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: !widget.macroGoalsExist,
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
                          'goalsTitle'.tr(),
                          style: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 24,
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
                    'goalsSubtitle'.tr(),
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

            ///
            /// CALORIES
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 3,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 12),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Material(
                    color: context.colors.listTileBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(listTileRadius),
                    child: InkWell(
                      onTap: HapticFeedback.lightImpact,
                      borderRadius: BorderRadius.circular(listTileRadius),
                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(listTileRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///
                                  /// TITLE
                                  ///
                                  Text(
                                    'calories'.tr().toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Epilogue',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: context.colors.text.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  ///
                                  /// BUTTONS & CALORIES
                                  ///
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ///
                                      /// DECREMENT
                                      ///
                                      Material(
                                        color: canDecreaseCalories ? context.colors.scaffoldBackground : context.colors.listTileBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          onTap: canDecreaseCalories ? () {} : null,
                                          onTapDown: canDecreaseCalories ? (_) => startCaloriesUpdate(-1) : null,
                                          onTapUp: canDecreaseCalories ? (_) => stopCaloriesUpdate() : null,
                                          onTapCancel: stopCaloriesUpdate,
                                          borderRadius: BorderRadius.circular(12),
                                          highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                          splashColor: Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: PhosphorIcon(
                                              PhosphorIconsBold.minus,
                                              size: 22,
                                              color: context.colors.text,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      ///
                                      /// CALORIES & BMR
                                      ///
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ///
                                          /// CALORIES
                                          ///
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  alignment: PlaceholderAlignment.middle,
                                                  child: AnimatedDigitWidget(
                                                    value: activeCalories,
                                                    loop: false,
                                                    duration: BokunSpizeDurations.animation,
                                                    curve: Curves.easeIn,
                                                    textStyle: TextStyle(
                                                      fontFamily: 'Epilogue',
                                                      fontSize: 36,
                                                      fontWeight: FontWeight.w900,
                                                      color: context.colors.text,
                                                    ),
                                                  ),
                                                ),
                                                const WidgetSpan(
                                                  child: SizedBox(width: 4),
                                                ),
                                                TextSpan(
                                                  text: 'caloriesUnit'.tr(),
                                                  style: TextStyle(
                                                    fontFamily: 'Epilogue',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: context.colors.text.withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            style: TextStyle(
                                              fontFamily: 'Epilogue',
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: context.colors.text,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          ///
                                          /// BMR
                                          ///
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'bmr'.tr().toUpperCase(),
                                                ),
                                                const TextSpan(
                                                  text: ':',
                                                ),
                                                const WidgetSpan(
                                                  child: SizedBox(width: 4),
                                                ),
                                                TextSpan(
                                                  text: '${widget.bmr.toStringAsFixed(0)} ${'caloriesUnit'.tr()}',
                                                  style: TextStyle(
                                                    fontFamily: 'Epilogue',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: context.colors.text.withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            style: TextStyle(
                                              fontFamily: 'Epilogue',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: context.colors.text.withValues(alpha: 0.5),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),

                                      ///
                                      /// INCREMENT
                                      ///
                                      Material(
                                        color: widget.activeColor,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          onTap: () {},
                                          onTapDown: (_) => startCaloriesUpdate(1),
                                          onTapUp: (_) => stopCaloriesUpdate(),
                                          onTapCancel: stopCaloriesUpdate,
                                          borderRadius: BorderRadius.circular(12),
                                          highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                          splashColor: Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: PhosphorIcon(
                                              PhosphorIconsBold.plus,
                                              size: 22,
                                              color: context.colors.buttonText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  ///
                                  /// EXPLANATION
                                  ///
                                  Material(
                                    color: context.colors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(listTileRadius / 2),
                                    child: InkWell(
                                      onTap: HapticFeedback.lightImpact,
                                      borderRadius: BorderRadius.circular(listTileRadius / 2),
                                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(listTileRadius / 2),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'goalsExplanation'.tr(),
                                                style: TextStyle(
                                                  fontFamily: 'PlusJakartaSans',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: context.colors.text.withValues(alpha: 0.75),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            ///
            /// MACROS
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 4,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 12),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Material(
                    color: context.colors.listTileBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(listTileRadius),
                    child: InkWell(
                      onTap: HapticFeedback.lightImpact,
                      borderRadius: BorderRadius.circular(listTileRadius),
                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(listTileRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///
                                  /// TITLE
                                  ///
                                  Text(
                                    'macros'.tr().toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Epilogue',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: context.colors.text.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  ///
                                  /// PROTEIN
                                  ///
                                  Material(
                                    color: context.colors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(listTileRadius / 2),
                                    child: InkWell(
                                      onTap: HapticFeedback.lightImpact,
                                      borderRadius: BorderRadius.circular(listTileRadius / 2),
                                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(listTileRadius / 2),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ///
                                            /// NAME
                                            ///
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 12,
                                                    width: 12,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: context.colors.protein,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        ///
                                                        /// TITLE
                                                        ///
                                                        Text(
                                                          'protein'.tr(),
                                                          style: TextStyle(
                                                            fontFamily: 'Epilogue',
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700,
                                                            color: context.colors.text,
                                                          ),
                                                        ),

                                                        ///
                                                        /// PERCENTAGE
                                                        ///
                                                        Text(
                                                          '${proteinPercentage.toStringAsFixed(0)}% ${'dailyIntake'.tr()}',
                                                          style: TextStyle(
                                                            fontFamily: 'PlusJakartaSans',
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w500,
                                                            color: context.colors.text.withValues(alpha: 0.75),
                                                          ),
                                                          textAlign: TextAlign.right,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            ///
                                            /// VALUE
                                            ///
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  ///
                                                  /// GRAMS
                                                  ///
                                                  Text(
                                                    '${currentProtein.toStringAsFixed(0)}${'gramUnit'.tr()}',
                                                    style: TextStyle(
                                                      fontFamily: 'Epilogue',
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w800,
                                                      color: context.colors.text,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),

                                                  ///
                                                  /// CALORIES
                                                  ///
                                                  Text(
                                                    '${proteinCalories.toStringAsFixed(0)} ${'caloriesUnit'.tr()}',
                                                    style: TextStyle(
                                                      fontFamily: 'PlusJakartaSans',
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                      color: context.colors.text.withValues(alpha: 0.75),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  ///
                                  /// CARBS
                                  ///
                                  Material(
                                    color: context.colors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(listTileRadius / 2),
                                    child: InkWell(
                                      onTap: HapticFeedback.lightImpact,
                                      borderRadius: BorderRadius.circular(listTileRadius / 2),
                                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(listTileRadius / 2),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ///
                                            /// NAME
                                            ///
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 12,
                                                    width: 12,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: context.colors.carbs,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        ///
                                                        /// TITLE
                                                        ///
                                                        Text(
                                                          'carbs'.tr(),
                                                          style: TextStyle(
                                                            fontFamily: 'Epilogue',
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700,
                                                            color: context.colors.text,
                                                          ),
                                                        ),

                                                        ///
                                                        /// PERCENTAGE
                                                        ///
                                                        Text(
                                                          '${carbsPercentage.toStringAsFixed(0)}% ${'dailyIntake'.tr()}',
                                                          style: TextStyle(
                                                            fontFamily: 'PlusJakartaSans',
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w500,
                                                            color: context.colors.text.withValues(alpha: 0.75),
                                                          ),
                                                          textAlign: TextAlign.right,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            ///
                                            /// VALUE
                                            ///
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  ///
                                                  /// GRAMS
                                                  ///
                                                  Text(
                                                    '${currentCarbs.toStringAsFixed(0)}${'gramUnit'.tr()}',
                                                    style: TextStyle(
                                                      fontFamily: 'Epilogue',
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w800,
                                                      color: context.colors.text,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),

                                                  ///
                                                  /// CALORIES
                                                  ///
                                                  Text(
                                                    '${carbsCalories.toStringAsFixed(0)} ${'caloriesUnit'.tr()}',
                                                    style: TextStyle(
                                                      fontFamily: 'PlusJakartaSans',
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                      color: context.colors.text.withValues(alpha: 0.75),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  ///
                                  /// FAT
                                  ///
                                  Material(
                                    color: context.colors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(listTileRadius / 2),
                                    child: InkWell(
                                      onTap: HapticFeedback.lightImpact,
                                      borderRadius: BorderRadius.circular(listTileRadius / 2),
                                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(listTileRadius / 2),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ///
                                            /// NAME
                                            ///
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 12,
                                                    width: 12,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: context.colors.fat,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        ///
                                                        /// TITLE
                                                        ///
                                                        Text(
                                                          'fats'.tr(),
                                                          style: TextStyle(
                                                            fontFamily: 'Epilogue',
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700,
                                                            color: context.colors.text,
                                                          ),
                                                        ),

                                                        ///
                                                        /// PERCENTAGE
                                                        ///
                                                        Text(
                                                          '${fatPercentage.toStringAsFixed(0)}% ${'dailyIntake'.tr()}',
                                                          style: TextStyle(
                                                            fontFamily: 'PlusJakartaSans',
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w500,
                                                            color: context.colors.text.withValues(alpha: 0.75),
                                                          ),
                                                          textAlign: TextAlign.right,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            ///
                                            /// VALUE
                                            ///
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  ///
                                                  /// GRAMS
                                                  ///
                                                  Text(
                                                    '${currentFat.toStringAsFixed(0)}${'gramUnit'.tr()}',
                                                    style: TextStyle(
                                                      fontFamily: 'Epilogue',
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w800,
                                                      color: context.colors.text,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),

                                                  ///
                                                  /// CALORIES
                                                  ///
                                                  Text(
                                                    '${fatCalories.toStringAsFixed(0)} ${'caloriesUnit'.tr()}',
                                                    style: TextStyle(
                                                      fontFamily: 'PlusJakartaSans',
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                      color: context.colors.text.withValues(alpha: 0.75),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
            ),

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
                  delay: BokunSpizeDurations.stateTransitionStagger * 5,
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
                      child: Text(
                        'saveGoals'.tr(),
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
}
