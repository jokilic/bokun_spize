import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';
import '../../../util/spacing.dart';
import '../../../widgets/text_field_widget.dart';

class ContactSheet extends StatefulWidget {
  final Function(String message) onSendPressed;

  const ContactSheet({
    required this.onSendPressed,
  });

  @override
  State<ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends State<ContactSheet> {
  late final TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    FocusManager.instance.primaryFocus?.unfocus();

    widget.onSendPressed(
      messageController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final validated = messageController.text.trim().isNotEmpty;

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
                      /// PLACEHOLDER BUTTON
                      ///
                      Opacity(
                        opacity: 0,
                        child: IgnorePointer(
                          child: IconButton(
                            onPressed: null,
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
                        ),
                      ),

                      ///
                      /// TITLE
                      ///
                      Expanded(
                        child: Text(
                          'accountContactSheetTitle'.tr(),
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
                  child: Text(
                    'accountContactSheetSubtitle'.tr(),
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
            /// NAME FIELD
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
                    autofocus: true,
                    minLines: 3,
                    maxLines: 3,
                    controller: messageController,
                    title: 'accountContactSheetTextFieldTitle'.tr(),
                    hintText: 'accountContactSheetTextFieldHint'.tr(),
                    textColor: context.colors.text,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ),

            ///
            /// SAVE BUTTON
            ///
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 4,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 14),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: validated ? sendMessage : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        padding: const EdgeInsets.all(22),
                        backgroundColor: context.colors.account,
                        foregroundColor: context.colors.buttonText,
                      ),
                      child: Text(
                        'accountContactSheetButton'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
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
