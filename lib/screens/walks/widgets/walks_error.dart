import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';

class WalksError extends StatelessWidget {
  final String error;
  final bool? permissionAuthorized;

  const WalksError({
    required this.error,
    required this.permissionAuthorized,
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
              PhosphorIconsBold.warningOctagon,
              color: context.colors.delete,
              size: 88,
            ),
            const SizedBox(height: 16),
            Text(
              (permissionAuthorized != null && !permissionAuthorized!) ? 'walksErrorPermissionTitle'.tr() : 'Error in walk journal'.tr(),
              style: context.textStyles.emptyStateTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              error,
              style: context.textStyles.emptyStateDescription,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
