import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../models/user_metrics/activity_level.dart';
import '../../../models/user_metrics/sex.dart';
import '../../../models/user_metrics/user_metrics.dart';
import '../../../services/firebase_service.dart';
import '../../../util/dependencies.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final String userPhoto;
  final int currentCalories;
  final int dailyCalories;

  const HomeAppBar({
    required this.userName,
    required this.userPhoto,
    required this.currentCalories,
    required this.dailyCalories,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: BokunSpizeColors.neutralLight,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 160,
    leading: Container(
      height: 40,
      width: 100,
      color: Colors.indigo,
    ),
    actions: [
      IconButton(
        onPressed: () => getIt.get<FirebaseService>().writeUserMetrics(
          newUserMetrics: UserMetrics(
            age: 25,
            height: 183,
            weight: 73,
            activity: ActivityLevel.sedentary,
            sex: Sex.female,
            tdeeCalories: 2600,
            bmrCalories: 1800,
            dailyCalories: 1400,
            dailyProtein: 100,
            dailyCarbs: 50,
            dailyFat: 50,
          ),
        ),
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
      titlePadding: const EdgeInsets.all(16),
      title: FadingFlexibleTitle(
        userName: userName,
        userPhoto: userPhoto,
        currentCalories: currentCalories,
        dailyCalories: dailyCalories,
      ),
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final String userName;
  final String userPhoto;
  final int currentCalories;
  final int dailyCalories;

  const FadingFlexibleTitle({
    required this.userName,
    required this.userPhoto,
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

    final showSubtitle = t > 0.25;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: currentCalories.toStringAsFixed(0),
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: 1,
                  color: BokunSpizeColors.primary,
                ),
                children: [
                  TextSpan(
                    text: ' / ${dailyCalories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 18,
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
