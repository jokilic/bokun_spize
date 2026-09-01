import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';

class WalksEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal * 4,
      vertical: 12,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const PhosphorIcon(
            PhosphorIconsBold.personSimpleWalk,
            color: BokunSpizeColors.bordeaux,
            size: 88,
          ),
          const SizedBox(height: 16),
          const Text(
            'Walk journal is empty',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: BokunSpizeColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Try refreshing by pressing the corner icon',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.6,
              color: BokunSpizeColors.black.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
