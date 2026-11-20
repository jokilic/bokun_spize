import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../theme/extensions.dart';

class NotificationHistoryEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal * 4,
      vertical: 8,
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
            PhosphorIcon(
              PhosphorIconsBold.notification,
              color: context.colors.fat,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'notificationHistoryEmptyTitle'.tr(),
              style: context.textStyles.emptyStateTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'notificationHistoryEmptySubtitle'.tr(),
              style: context.textStyles.emptyStateDescription,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
