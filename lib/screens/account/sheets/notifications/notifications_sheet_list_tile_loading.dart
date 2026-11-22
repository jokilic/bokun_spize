import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../theme/extensions.dart';

class NotificationsSheetListTileLoading extends StatelessWidget {
  final Color color;

  const NotificationsSheetListTileLoading({
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(listTileRadius),
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(listTileRadius),
      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(listTileRadius),
          color: context.colors.listTileBackground.withValues(alpha: 0.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ///
            /// LOADING ICON
            ///
            Animate(
              onPlay: (controller) => controller.loop(
                reverse: true,
                min: 0.6,
              ),
              effects: const [
                FadeEffect(
                  duration: BokunSpizeDurations.shimmer,
                  curve: Curves.easeIn,
                ),
              ],
              child: Container(
                width: listTileIconRadius,
                height: listTileIconRadius,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: color.withValues(alpha: 0.25),
                ),
              ),
            ),
            const SizedBox(width: 20),

            ///
            /// LOADING TEXT
            ///
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Animate(
                    onPlay: (controller) => controller.loop(
                      reverse: true,
                      min: 0.6,
                    ),
                    effects: const [
                      FadeEffect(
                        duration: BokunSpizeDurations.shimmer,
                        curve: Curves.easeIn,
                      ),
                    ],
                    child: Container(
                      height: 20,
                      width: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Animate(
                    onPlay: (controller) => controller.loop(
                      reverse: true,
                      min: 0.6,
                    ),
                    effects: const [
                      FadeEffect(
                        duration: BokunSpizeDurations.shimmer,
                        curve: Curves.easeIn,
                      ),
                    ],
                    child: Container(
                      height: 12,
                      width: 144,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            ///
            /// LOADING SWITCH
            ///
            Animate(
              onPlay: (controller) => controller.loop(
                reverse: true,
                min: 0.6,
              ),
              effects: const [
                FadeEffect(
                  duration: BokunSpizeDurations.shimmer,
                  curve: Curves.easeIn,
                ),
              ],
              child: Container(
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: context.colors.scaffoldBackground.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
