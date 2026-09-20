import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';

class SearchEmpty extends StatelessWidget {
  final String query;

  const SearchEmpty({
    required this.query,
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal * 4,
      vertical: 12,
    ),
    sliver: SliverToBoxAdapter(
      child: Animate(
        effects: const [
          FadeEffect(
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOut,
          ),
          MoveEffect(
            begin: Offset(0, 24),
            end: Offset.zero,
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOutCubic,
          ),
          ScaleEffect(
            begin: Offset(0.96, 0.96),
            end: Offset(1, 1),
            alignment: Alignment.topCenter,
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOutBack,
          ),
        ],
        child: Column(
          children: [
            const SizedBox(height: 24),
            PhosphorIcon(
              PhosphorIconsBold.magnifyingGlass,
              color: context.colors.protein,
              size: 88,
            ),
            const SizedBox(height: 16),
            Text(
              query.characters.length < minimumSearchLength ? 'Search your meal journal' : 'No meals found',
              style: TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: context.colors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              query.characters.length < minimumSearchLength ? 'Enter at least $minimumSearchLength characters to search' : 'Try a different meal name or ingredient',
              style: TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.6,
                color: context.colors.text.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
