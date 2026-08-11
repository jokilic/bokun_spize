import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';

class HomeMealListTileNutrition extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: BokunSpizeColors.neutralLight,
      borderRadius: BorderRadius.circular(100),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
    child: Row(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ///
        /// CALORIES
        ///
        Expanded(
          child: Column(
            children: [
              Text(
                'Cals'.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.neutralDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                '420',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.neutralDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        ///
        /// PROTEIN
        ///
        Expanded(
          child: Column(
            children: [
              Text(
                'Prot'.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                '24g',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        ///
        /// CARBS
        ///
        Expanded(
          child: Column(
            children: [
              Text(
                'Carb'.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                '32g',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        ///
        /// FATS
        ///
        Expanded(
          child: Column(
            children: [
              Text(
                'Fat'.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.tertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                '18g',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: BokunSpizeColors.tertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
