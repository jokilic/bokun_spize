import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/durations.dart';

class MealsAppBar extends StatelessWidget {
  final String? title;
  final String dayString;
  final double currentCalories;
  final double currentProtein;
  final double currentCarbs;
  final double currentFat;
  final double? dailyCalories;
  final double? dailyProtein;
  final double? dailyCarbs;
  final double? dailyFat;

  const MealsAppBar({
    required this.title,
    required this.dayString,
    required this.currentCalories,
    required this.currentProtein,
    required this.currentCarbs,
    required this.currentFat,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: BokunSpizeColors.grey,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 240,
    leadingWidth: double.infinity,
    leading: Padding(
      padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
      child: Row(
        children: [
          ///
          /// ICON
          ///
          IconButton(
            onPressed: null,
            icon: const PhosphorIcon(
              PhosphorIconsBold.bowlFood,
              size: 24,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              foregroundColor: BokunSpizeColors.green,
              disabledBackgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              disabledForegroundColor: BokunSpizeColors.green,
            ),
          ),
          const SizedBox(width: 14),

          ///
          /// APP TITLE
          ///
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: const TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  height: 1.2,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w800,
                  color: BokunSpizeColors.green,
                ),
              ),
            ),
        ],
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
      title: FadingFlexibleTitle(
        dayString: dayString,
        currentCalories: currentCalories,
        currentProtein: currentProtein,
        currentCarbs: currentCarbs,
        currentFat: currentFat,
        dailyCalories: dailyCalories,
        dailyProtein: dailyProtein,
        dailyCarbs: dailyCarbs,
        dailyFat: dailyFat,
      ),
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final String dayString;
  final double currentCalories;
  final double currentProtein;
  final double currentCarbs;
  final double currentFat;
  final double? dailyCalories;
  final double? dailyProtein;
  final double? dailyCarbs;
  final double? dailyFat;

  const FadingFlexibleTitle({
    required this.dayString,
    required this.currentCalories,
    required this.currentProtein,
    required this.currentCarbs,
    required this.currentFat,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    if (settings == null) {
      return const SizedBox.shrink();
    }

    final delta = settings.maxExtent - settings.minExtent;
    final t = ((settings.currentExtent - settings.minExtent) / delta).clamp(0.0, 1.0);
    final opacity = Curves.easeIn.transform(t);

    final dy = Tween<double>(begin: 8, end: 0).transform(t);

    final hasDailyProtein = dailyProtein != null && dailyProtein! > 0;
    final hasDailyCarbs = dailyCarbs != null && dailyCarbs! > 0;
    final hasDailyFat = dailyFat != null && dailyFat! > 0;

    final proteinBarValue = hasDailyProtein ? dailyProtein! : currentProtein;
    final carbsBarValue = hasDailyCarbs ? dailyCarbs! : currentCarbs;
    final fatBarValue = hasDailyFat ? dailyFat! : currentFat;

    final proteinFlex = proteinBarValue.round() > 0 ? proteinBarValue.round() : 1;
    final carbsFlex = carbsBarValue.round() > 0 ? carbsBarValue.round() : 1;
    final fatFlex = fatBarValue.round() > 0 ? fatBarValue.round() : 1;

    final proteinProgress = hasDailyProtein
        ? (currentProtein / dailyProtein!).clamp(0.0, 1.0).toDouble()
        : currentProtein > 0
        ? 1.0
        : 0.0;
    final carbsProgress = hasDailyCarbs
        ? (currentCarbs / dailyCarbs!).clamp(0.0, 1.0).toDouble()
        : currentCarbs > 0
        ? 1.0
        : 0.0;
    final fatProgress = hasDailyFat
        ? (currentFat / dailyFat!).clamp(0.0, 1.0).toDouble()
        : currentFat > 0
        ? 1.0
        : 0.0;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// DAY
            ///
            Text(
              dayString.toUpperCase(),
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: BokunSpizeColors.black.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),

            ///
            /// CALORIES
            ///
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                ///
                /// VALUE
                ///
                AnimatedDigitWidget(
                  value: currentCalories.round(),
                  loop: false,
                  curve: Curves.easeIn,
                  duration: BokunSpizeDurations.animation,
                  textStyle: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: 1.5,
                    color: BokunSpizeColors.green,
                  ),
                ),

                ///
                /// DAILY VALUE & UNIT
                ///
                Transform.translate(
                  offset: const Offset(0, 5),
                  child: Text(
                    dailyCalories != null ? '/ ${dailyCalories!.toStringAsFixed(0)} kcal' : 'kcal',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: 1.5,
                      color: BokunSpizeColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            ///
            /// NUTRITION VALUES
            ///
            SizedBox(
              height: nutritionValuesHeight,
              child: Row(
                spacing: 12,
                children: [
                  ///
                  /// PROTEIN
                  ///
                  Expanded(
                    flex: proteinFlex,
                    child: Opacity(
                      opacity: currentProtein.round() > 0 ? 1 : 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: ColoredBox(
                          color: BokunSpizeColors.white.withValues(alpha: 0.5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: proteinProgress,
                              child: Container(
                                height: nutritionValuesHeight,
                                color: BokunSpizeColors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///
                  /// CARBS
                  ///
                  Expanded(
                    flex: carbsFlex,
                    child: Opacity(
                      opacity: currentCarbs.round() > 0 ? 1 : 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: ColoredBox(
                          color: BokunSpizeColors.white.withValues(alpha: 0.5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: carbsProgress,
                              child: Container(
                                height: nutritionValuesHeight,
                                color: BokunSpizeColors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///
                  /// FATS
                  ///
                  Expanded(
                    flex: fatFlex,
                    child: Opacity(
                      opacity: currentFat.round() > 0 ? 1 : 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: ColoredBox(
                          color: BokunSpizeColors.white.withValues(alpha: 0.5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: fatProgress,
                              child: Container(
                                height: nutritionValuesHeight,
                                color: BokunSpizeColors.bordeaux,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            ///
            /// NUTRITION TEXT
            ///
            Row(
              children: [
                ///
                /// PROTEIN
                ///
                Expanded(
                  child: Opacity(
                    opacity: currentProtein.round() > 0 ? 1 : 0,
                    child: Row(
                      children: [
                        Container(
                          height: 7,
                          width: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: BokunSpizeColors.green,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Protein'.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.4,
                            color: BokunSpizeColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                ///
                /// CARBS
                ///
                Expanded(
                  child: Opacity(
                    opacity: currentCarbs.round() > 0 ? 1 : 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 7,
                          width: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: BokunSpizeColors.blue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Carbs'.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.4,
                            color: BokunSpizeColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                ///
                /// FATS
                ///
                Expanded(
                  child: Opacity(
                    opacity: currentFat.round() > 0 ? 1 : 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 7,
                          width: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: BokunSpizeColors.bordeaux,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Fats'.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.4,
                            color: BokunSpizeColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
