import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';

class AccountListTile extends StatelessWidget {
  final Duration animationDelay;
  final Function() onPressed;
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;

  const AccountListTile({
    required this.onPressed,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal,
      vertical: 8,
    ),
    sliver: SliverToBoxAdapter(
      child: Animate(
        delay: animationDelay,
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
          ScaleEffect(
            begin: Offset(0.98, 0.98),
            end: Offset(1, 1),
            alignment: Alignment.topCenter,
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOutCubic,
          ),
        ],
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(listTileRadius),
          child: InkWell(
            onTap: onPressed,
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
                  /// ICON
                  ///
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.all(listTileIconRadius / 4),
                      color: iconBackgroundColor,
                      child: PhosphorIcon(
                        icon,
                        color: context.colors.buttonText,
                        size: listTileIconRadius / 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  ///
                  /// TEXT
                  ///
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///
                        /// TITLE
                        ///
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: context.colors.text,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        ///
                        /// SUBTITLE
                        ///
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.colors.text.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
