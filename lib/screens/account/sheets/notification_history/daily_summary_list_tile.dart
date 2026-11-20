import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../models/notification/daily_summary.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/date_time.dart';

class DailySummaryListTile extends StatelessWidget {
  final DailySummary dailySummary;

  const DailySummaryListTile({
    required this.dailySummary,
  });

  @override
  Widget build(BuildContext context) {
    final date = getDateString(
      date: dailySummary.dayBeingSummarized,
      dateFormat: 'dd MMM',
      languageCode: context.locale.languageCode,
      includeYearIfNotCurrentYear: true,
    );
    final time = getDateString(
      date: dailySummary.summaryAt,
      dateFormat: 'HH:mm',
      useTodayYesterdayTomorrow: false,
      languageCode: context.locale.languageCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
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
                padding: const EdgeInsets.all(listTileIconRadius / 4),
                color: context.colors.protein,
                child: PhosphorIcon(
                  PhosphorIconsBold.notification,
                  color: context.colors.buttonText,
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
                    'notificationsDailySummaryTitle'.tr(),
                    style: context.textStyles.listTileTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dailySummary.notificationForLanguage(languageCode),
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
    );
  }
}
