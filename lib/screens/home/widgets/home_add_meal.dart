import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class HomeAddMeal extends StatelessWidget {
  final Function() onPressed;

  const HomeAddMeal({
    required this.onPressed,
  });

  final listTileRadius = 32.0;

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
              padding: const EdgeInsets.all(32),
              child: const Column(
                children: [
                  ///
                  /// ICON
                  ///
                  Icon(
                    Icons.add_circle_outline,
                    color: BokunSpizeColors.primary,
                    size: 40,
                  ),

                  SizedBox(height: 12),

                  ///
                  /// TEXT
                  ///
                  Text(
                    'Dodaj obrok',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.neutralDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
