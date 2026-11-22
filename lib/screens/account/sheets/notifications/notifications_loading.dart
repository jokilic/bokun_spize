import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../theme/extensions.dart';
import 'notifications_sheet_list_tile_loading.dart';

class NotificationsLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = [
      context.colors.carbs,
      context.colors.protein,
      context.colors.fat,
    ];

    return SliverList.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal,
          vertical: 8,
        ),
        child: Animate(
          key: ValueKey(index),
          delay: BokunSpizeDurations.stateTransitionStagger * (3 + index),
          effects: const [
            FadeEffect(
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOut,
            ),
            MoveEffect(
              begin: Offset(0, 18),
              end: Offset.zero,
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOutCubic,
            ),
          ],
          child: NotificationsSheetListTileLoading(
            color: colors[index],
          ),
        ),
      ),
    );
  }
}
