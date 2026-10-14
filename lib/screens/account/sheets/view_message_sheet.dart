import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/contact_message/contact_message.dart';
import '../../../theme/extensions.dart';
import '../../../util/date_time.dart';
import '../../../util/spacing.dart';
import '../../../widgets/text_field_widget.dart';
import '../widgets/view_message_list_tile.dart';

class ViewMessageSheet extends StatelessWidget {
  final ContactMessage message;
  final Function()? onDeletePressed;

  const ViewMessageSheet({
    required this.message,
    required this.onDeletePressed,
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: ColoredBox(
        color: context.colors.scaffoldBackground,
        child: CustomScrollView(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            ///
            /// TITLE & CLOSE BUTTON
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 10),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ///
                      /// DELETE BUTTON
                      ///
                      IconButton(
                        onPressed: () {
                          if (onDeletePressed != null) {
                            onDeletePressed!();
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.trash,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: context.colors.delete,
                          foregroundColor: context.colors.listTileBackground,
                        ),
                      ),

                      ///
                      /// TITLE
                      ///
                      Expanded(
                        child: Text(
                          'message'.tr(),
                          style: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: 0.6,
                            color: context.colors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      ///
                      /// CLOSE BUTTON
                      ///
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.x,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                          foregroundColor: context.colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ///
            /// SUBTITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 2,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 8),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Text.rich(
                    TextSpan(
                      text: date,
                      children: [
                        WidgetSpan(
                          child: PhosphorIcon(
                            PhosphorIconsBold.dotOutline,
                            size: 16,
                            color: context.colors.text,
                          ),
                        ),
                        TextSpan(
                          text: time,
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            ///
            /// TEXT
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 3,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 18),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                    ScaleEffect(
                      begin: Offset(0.98, 0.98),
                      end: Offset(1, 1),
                      alignment: Alignment.topCenter,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: TextFieldWidget(
                    readOnly: true,
                    minLines: 3,
                    maxLines: 3,
                    controller: TextEditingController(
                      text: message.message,
                    ),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    title: 'message'.tr(),
                    textColor: context.colors.text,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            ///
            /// EMAIL
            ///
            ViewMessageListTile(
              animationDelay: BokunSpizeDurations.stateTransitionStagger * 4,
              onPressed: () {
                // TODO: Open mail
              },
              icon: PhosphorIconsBold.at,
              iconBackgroundColor: context.colors.protein,
              title: message.userEmail,
              subtitle: 'emailAddress'.tr(),
            ),

            ///
            /// PLATFORM
            ///
            ViewMessageListTile(
              animationDelay: BokunSpizeDurations.stateTransitionStagger * 5,
              onPressed: () {},
              icon: PhosphorIconsBold.deviceMobileCamera,
              iconBackgroundColor: context.colors.carbs,
              title: message.platform,
              subtitle: 'platform'.tr(),
            ),

            ///
            /// APP VERSION
            ///
            ViewMessageListTile(
              animationDelay: BokunSpizeDurations.stateTransitionStagger * 6,
              onPressed: () {},
              icon: PhosphorIconsBold.gitBranch,
              iconBackgroundColor: context.colors.fat,
              title: 'v${message.appVersion}',
              subtitle: 'appVersion'.tr(),
            ),

            ///
            /// BOTTOM SPACING
            ///
            SliverToBoxAdapter(
              child: SizedBox(
                height: getBottomSpacing(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
