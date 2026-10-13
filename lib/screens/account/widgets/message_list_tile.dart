import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../models/contact_message/contact_message.dart';
import '../../../theme/extensions.dart';
import '../../../util/date_time.dart';

class MessageListTile extends StatelessWidget {
  final ContactMessage message;
  final Function() onPressed;

  const MessageListTile({
    required this.message,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final date = getDateString(
      date: message.createdAt,
      dateFormat: 'dd.MM.yyyy.',
      languageCode: context.locale.languageCode,
    );

    final time = getDateString(
      date: message.createdAt,
      dateFormat: 'HH:mm',
      useTodayYesterdayTomorrow: false,
      languageCode: context.locale.languageCode,
    );

    return SliverPadding(
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
                      color: context.colors.protein,
                      child: PhosphorIcon(
                        PhosphorIconsBold.chatCircleText,
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
                          message.userEmail,
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
    );
  }
}
