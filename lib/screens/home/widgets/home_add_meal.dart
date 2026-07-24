import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class HomeAddMeal extends StatelessWidget {
  final Function() onPressed;

  const HomeAddMeal({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: BokunSpizeColors.neutralLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: BokunSpizeColors.neutralDark.withValues(alpha: 0.25),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          highlightColor: BokunSpizeColors.primary.withValues(alpha: 0.05),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 28,
              ),
              child: Column(
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
