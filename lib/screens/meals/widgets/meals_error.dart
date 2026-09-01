import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';

class MealsError extends StatelessWidget {
  final String error;
  final Function() onRetryPressed;

  const MealsError({
    required this.error,
    required this.onRetryPressed,
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal,
      vertical: 12,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          const PhosphorIcon(
            PhosphorIconsBold.warningOctagon,
            color: BokunSpizeColors.green,
            size: 96,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: BokunSpizeColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            error,
            style: const TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              color: BokunSpizeColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          TextButton.icon(
            onPressed: onRetryPressed,
            icon: const PhosphorIcon(
              PhosphorIconsBold.arrowClockwise,
              size: 20,
            ),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: BokunSpizeColors.green,
              textStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
