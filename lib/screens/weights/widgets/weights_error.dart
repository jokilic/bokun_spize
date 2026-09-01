import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';

class WeightsError extends StatelessWidget {
  final String error;
  final Function() onRetryPressed;

  const WeightsError({
    required this.error,
    required this.onRetryPressed,
  });

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
            PhosphorIconsBold.warningOctagon,
            color: BokunSpizeColors.blue,
            size: 88,
          ),
          const SizedBox(height: 16),
          const Text(
            'Erroro has happendo',
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
            error,
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.6,
              color: BokunSpizeColors.black.withValues(alpha: 0.75),
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
              foregroundColor: BokunSpizeColors.blue,
              textStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
