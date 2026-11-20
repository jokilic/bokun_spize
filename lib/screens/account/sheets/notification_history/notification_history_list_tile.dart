import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../theme/extensions.dart';

class NotificationHistoryListTile extends StatelessWidget {
  final Function() onPressed;
  final Color color;
  final IconData icon;
  final String title;
  final String titleDate;
  final String date;
  final String time;

  const NotificationHistoryListTile({
    required this.onPressed,
    required this.color,
    required this.icon,
    required this.titleDate,
    required this.title,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal,
      vertical: 8,
    ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              /// SUMMARY
              ///
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'notificationHistoryListTileTitle'.tr(
                        args: [titleDate],
                      ),
                      style: context.textStyles.listTileTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: context.textStyles.listTileSubtitle,
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: date,
                        children: [
                          WidgetSpan(
                            child: PhosphorIcon(
                              PhosphorIconsBold.dotOutline,
                              size: 14,
                              color: context.colors.text.withValues(alpha: 0.7),
                            ),
                          ),
                          TextSpan(
                            text: time,
                          ),
                        ],
                      ),
                      style: context.textStyles.listTileSubtitle.copyWith(
                        color: context.colors.text.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
