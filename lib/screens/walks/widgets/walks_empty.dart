import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';

class WalksEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: marginHorizontal,
      vertical: 12,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: 24),
          PhosphorIcon(
            PhosphorIconsBold.personSimpleWalk,
            color: BokunSpizeColors.bordeaux,
            size: 96,
          ),
          SizedBox(height: 16),
          Text(
            'Walking journal',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: BokunSpizeColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            'No step data at this time',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              color: BokunSpizeColors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
