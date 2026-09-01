import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';

class WeightsLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: marginHorizontal,
      vertical: 12,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          PhosphorIcon(
            PhosphorIconsBold.chartLine,
            color: BokunSpizeColors.blue,
            size: 96,
          ),
          SizedBox(height: 16),
          Text(
            'Weight journal',
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
            'Loading...',
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
