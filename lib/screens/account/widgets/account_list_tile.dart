import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../theme/extensions.dart';

class AccountListTile extends StatelessWidget {
  final Function() onPressed;
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final Widget trailingWidget;

  const AccountListTile({
    required this.onPressed,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal,
      vertical: 8,
    ),
    sliver: SliverToBoxAdapter(
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
                const SizedBox(width: 20),

                ///
                /// TRAILING WIDGET
                ///
                trailingWidget,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
