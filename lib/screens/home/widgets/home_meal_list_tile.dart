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
    elevation: 0.05,
    margin: const EdgeInsets.all(16),
    color: BokunSpizeColors.white,
    shadowColor: Colors.pink,
    surfaceTintColor: Colors.green,
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
                'https://upload.wikimedia.org/wikipedia/commons/2/21/Danny_DeVito_by_Gage_Skidmore.jpg',
                height: 104,
                width: 104,
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
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      /// TITLE
                      ///
                      Expanded(
                        child: Text(
                          'Čokolada sa sirom',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.6,
                            color: BokunSpizeColors.neutralDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(width: 4),

                      ///
                      /// TIME
                      ///
                      Text(
                        '15:15',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          height: 1.2,
                          letterSpacing: 1,
                          color: BokunSpizeColors.neutralDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  ///
                  /// FOOD
                  ///
                  const Text(
                    'Čokolada, sir, kruh',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      letterSpacing: 1,
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
                      color: BokunSpizeColors.tertiary,
                    ),
                    child: const Text(
                      '580 kcal',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: 1,
                        color: BokunSpizeColors.neutralLight,
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
