import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../main.dart';

class InsightsAddWeight extends StatelessWidget {
  final Function() onPressed;

  const InsightsAddWeight({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    sliver: SliverToBoxAdapter(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(listTileRadius),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(listTileRadius),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(listTileRadius),
            highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(listTileRadius),
                border: Border.all(
                  color: BokunSpizeColors.primary,
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: const Column(
                children: [
                  ///
                  /// ICON
                  ///
                  Icon(
                    Icons.add_circle_outline,
                    color: BokunSpizeColors.primary,
                    size: 28,
                  ),

                  SizedBox(height: 4),

                  ///
                  /// TEXT
                  ///
                  Text(
                    'Unesi masu',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: BokunSpizeColors.neutralDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
