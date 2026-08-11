import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';

class HomeMealListTileFood extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ///
      /// TITLE & QUANTITY
      ///
      Row(
        children: [
          ///
          /// TITLE
          ///
          Expanded(
            child: Text(
              'Whole grain toast',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: BokunSpizeColors.neutralDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          ///
          /// QUANTITY
          ///
          Text(
            '1 slice',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: BokunSpizeColors.neutralDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      SizedBox(height: 4),

      ///
      /// NUTRITION
      ///
      Row(
        spacing: 8,
        children: [
          Flexible(
            child: Text(
              '120 kcal',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: BokunSpizeColors.neutralDark,
              ),
            ),
          ),
          Flexible(
            child: Text(
              '12g P',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: BokunSpizeColors.neutralDark,
              ),
            ),
          ),
          Flexible(
            child: Text(
              '22g C',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: BokunSpizeColors.neutralDark,
              ),
            ),
          ),
          Flexible(
            child: Text(
              '2g F',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: BokunSpizeColors.neutralDark,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
