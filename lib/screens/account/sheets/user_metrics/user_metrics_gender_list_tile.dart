import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../theme/extensions.dart';

class UserMetricsGenderListTile extends StatelessWidget {
  final Function() onPressed;
  final IconData? icon;
  final String title;
  final Color primaryColor;
  final bool isActive;

  const UserMetricsGenderListTile({
    required this.onPressed,
    required this.title,
    required this.primaryColor,
    required this.isActive,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      highlightColor: isActive ? primaryColor : context.colors.listTileBackground.withValues(alpha: 0.5),
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: AnimatedContainer(
        duration: BokunSpizeDurations.animation,
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive ? primaryColor : context.colors.listTileBackground.withValues(alpha: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
                color: context.colors.buttonText,
                child: icon != null
                    ? PhosphorIcon(
                        icon!,
                        color: primaryColor,
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
                      color: isActive ? context.colors.buttonText : context.colors.text,
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
