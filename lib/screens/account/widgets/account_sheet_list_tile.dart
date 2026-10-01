import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';

class AccountSheetListTile extends StatelessWidget {
  final Function() onPressed;
  final bool isActive;
  final Color color;
  final IconData? icon;
  final String? emojiIcon;
  final String title;
  final String subtitle;

  const AccountSheetListTile({
    required this.onPressed,
    required this.isActive,
    required this.color,
    required this.title,
    required this.subtitle,
    this.icon,
    this.emojiIcon,
  });

  @override
  Widget build(BuildContext context) => Material(
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
                width: listTileIconRadius,
                height: listTileIconRadius,
                alignment: Alignment.center,
                color: color.withValues(alpha: 0.25),
                child: icon != null
                    ? PhosphorIcon(
                        icon!,
                        color: color,
                        size: listTileIconRadius / 2,
                      )
                    : emojiIcon != null
                    ? Text(
                        emojiIcon!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: listTileIconRadius / 2,
                          height: 1,
                          leadingDistribution: TextLeadingDistribution.even,
                          fontWeight: FontWeight.w500,
                          color: context.colors.text.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox(
                        height: listTileIconRadius / 2,
                        width: listTileIconRadius / 2,
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

            ///
            /// CHECKBOX
            ///
            AnimatedOpacity(
              opacity: isActive ? 1 : 0,
              duration: BokunSpizeDurations.animation,
              child: PhosphorIcon(
                PhosphorIconsBold.checkCircle,
                color: color,
                size: listTileIconRadius / 2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
