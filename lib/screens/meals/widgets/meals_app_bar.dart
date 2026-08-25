import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';

class MealsAppBar extends StatelessWidget {
  final String? title;
  final String dayString;
  final int currentCalories;
  final int? dailyCalories;

  const MealsAppBar({
    required this.title,
    required this.dayString,
    required this.currentCalories,
    required this.dailyCalories,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: BokunSpizeColors.grey,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 240,
    leadingWidth: double.infinity,
    leading: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ///
          /// ICON
          ///
          IconButton(
            onPressed: null,
            icon: const PhosphorIcon(
              PhosphorIconsBold.bowlFood,
              size: 26,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(14),
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
      titlePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: currentCalories > 0
          ? FadingFlexibleTitle(
              dayString: dayString,
              currentCalories: currentCalories,
              dailyCalories: dailyCalories,
            )
          : null,
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final String dayString;
  final int currentCalories;
  final int? dailyCalories;

  const FadingFlexibleTitle({
    required this.dayString,
    required this.currentCalories,
    required this.dailyCalories,
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
            Text.rich(
              TextSpan(
                text: currentCalories.toStringAsFixed(0),
                style: const TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: 1.5,
                  color: BokunSpizeColors.green,
                ),
                children: [
                  const WidgetSpan(
                    child: SizedBox(width: 4),
                  ),
                  TextSpan(
                    text: dailyCalories != null ? '/ ${dailyCalories!.toStringAsFixed(0)} kcal' : 'kcal',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: 1.5,
                      color: BokunSpizeColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            ///
            /// NUTRITION
            ///
            Row(
              children: [
                ///
                /// PROTEIN
                ///
                Expanded(
                  child: Container(
                    height: 7,
                    decoration: const BoxDecoration(
                      color: BokunSpizeColors.green,
                    ),
                  ),
                ),

                ///
                /// CARBS
                ///
                Expanded(
                  child: Container(
                    height: 7,
                    decoration: const BoxDecoration(
                      color: BokunSpizeColors.blue,
                    ),
                  ),
                ),

                ///
                /// FATS
                ///
                Expanded(
                  child: Container(
                    height: 7,
                    decoration: const BoxDecoration(
                      color: BokunSpizeColors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ///
                /// PROTEIN
                ///
                Expanded(
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
                      ),
                    ],
                  ),
                ),

                ///
                /// CARBS
                ///
                Expanded(
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
                      ),
                    ],
                  ),
                ),

                ///
                /// FATS
                ///
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 7,
                        width: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: BokunSpizeColors.red,
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
                      ),
                    ],
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
