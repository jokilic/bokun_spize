import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../theme/extensions.dart';

class NotificationsSheetListTile extends StatelessWidget {
  final Function() onPressed;
  final bool isActive;
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const NotificationsSheetListTile({
    required this.onPressed,
    required this.isActive,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
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
                child: PhosphorIcon(
                  icon,
                  color: color,
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
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            ///
            /// SWITCH
            ///
            Switch.adaptive(
              value: isActive,
              activeThumbColor: color,
              activeTrackColor: color.withValues(alpha: 0.25),
              inactiveThumbColor: context.colors.listTileBackground,
              inactiveTrackColor: context.colors.scaffoldBackground,
              trackOutlineColor: WidgetStateColor.resolveWith(
                (states) => Colors.transparent,
              ),
              onChanged: (_) => onPressed(),
            ),
          ],
        ),
      ),
    ),
  );
}
