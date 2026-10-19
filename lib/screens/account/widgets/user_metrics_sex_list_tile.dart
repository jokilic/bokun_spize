import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../theme/extensions.dart';

class UserMetricsSexListTile extends StatelessWidget {
  final Function() onPressed;
  final Color color;
  final IconData? icon;
  final String title;

  const UserMetricsSexListTile({
    required this.onPressed,
    required this.color,
    required this.title,
    this.icon,
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ///
            /// ICON
            ///
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: listTileIconSmallRadius,
                height: listTileIconSmallRadius,
                alignment: Alignment.center,
                color: color.withValues(alpha: 0.25),
                child: icon != null
                    ? PhosphorIcon(
                        icon!,
                        color: context.colors.carbs,
                        size: listTileIconSmallRadius / 2,
                      )
                    : const SizedBox(
                        height: listTileIconSmallRadius / 2,
                        width: listTileIconSmallRadius / 2,
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
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
