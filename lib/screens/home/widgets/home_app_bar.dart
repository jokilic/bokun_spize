import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class HomeAppBar extends StatelessWidget {
  final String? userName;
  final String? userPhoto;
  final Function() onCalendarPressed;
  final String dayString;
  final int currentCalories;
  final int? dailyCalories;

  const HomeAppBar({
    required this.userName,
    required this.userPhoto,
    required this.onCalendarPressed,
    required this.dayString,
    required this.currentCalories,
    required this.dailyCalories,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: BokunSpizeColors.neutralLight,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 192,
    leadingWidth: double.infinity,
    leading: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ///
          /// AVATAR
          ///
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/2/21/Danny_DeVito_by_Gage_Skidmore.jpg',
              fit: BoxFit.cover,
              height: 52,
              width: 52,
            ),
          ),
          const SizedBox(width: 12),

          ///
          /// NAME
          ///
          Text(
            userName ?? 'Bokun spize',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BokunSpizeColors.neutralDark,
            ),
          ),
        ],
      ),
    ),
    actions: [
      IconButton(
        onPressed: onCalendarPressed,
        icon: const Icon(
          Icons.calendar_month_rounded,
          size: 24,
        ),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.all(14),
          backgroundColor: BokunSpizeColors.neutralLight,
          foregroundColor: BokunSpizeColors.neutralDark,
          disabledBackgroundColor: BokunSpizeColors.neutralLight,
          disabledForegroundColor: BokunSpizeColors.neutralDark,
        ),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: FadingFlexibleTitle(
        dayString: dayString,
        currentCalories: currentCalories,
        dailyCalories: dailyCalories,
      ),
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
            Text(
              dayString.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: BokunSpizeColors.neutralDark,
              ),
            ),
            Text.rich(
              TextSpan(
                text: currentCalories.toStringAsFixed(0),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: 1,
                  color: BokunSpizeColors.primary,
                ),
                children: [
                  const WidgetSpan(
                    child: SizedBox(width: 4),
                  ),
                  TextSpan(
                    text: dailyCalories != null ? '/ ${dailyCalories!.toStringAsFixed(0)} kcal' : 'kcal',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: 1,
                      color: BokunSpizeColors.neutralDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
