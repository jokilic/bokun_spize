import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../models/meal/meal.dart';

class HomeMealListTile extends StatelessWidget {
  final Meal meal;

  const HomeMealListTile({
    required this.meal,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    color: BokunSpizeColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ///
            /// IMAGE
            ///
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
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
                          // meal.name!,
                          // 'Mediterranean Power Bowl',
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
                        fontSize: 16,
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
      ),
    ),
  );
}
