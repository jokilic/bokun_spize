import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/contact_message/contact_message.dart';
import '../../../services/firebase_service.dart';
import '../../../theme/extensions.dart';
import '../../../util/spacing.dart';
import '../../../widgets/blurred_modal_bottom_sheet.dart';
import '../widgets/message_list_tile.dart';
import 'view_message_sheet.dart';

class MessagesSheet extends WatchingStatefulWidget {
  @override
  State<MessagesSheet> createState() => _MessagesSheetState();
}

class _MessagesSheetState extends State<MessagesSheet> {
  /// Opens [ViewMessageSheet]
  Future<void> openViewMessageSheet(
    BuildContext context, {
    required ContactMessage message,
  }) async => await showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => ViewMessageSheet(
      message: message,
    ),
  );

  @override
  Widget build(BuildContext context) {
    /// Listens to any changes in `contactMessages` from [Firebase]
    final contactMessages =
        watchStream<FirebaseService, List<ContactMessage>>(
          (firebaseService) => firebaseService.listenToContactMessages(),
          initialValue: const <ContactMessage>[],
        ).data ??
        const <ContactMessage>[];

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
                          // TODO: Localize
                          'Messages',
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
                    // TODO: Localize
                    'Read messages from users',
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
            /// MESSAGES
            ///
            if (contactMessages.isNotEmpty)
              SliverList.builder(
                itemCount: contactMessages.length,
                findChildIndexCallback: (key) {
                  final index = contactMessages.indexWhere(
                    (message) => ValueKey(message.id) == key,
                  );
                  return index == -1 ? null : index;
                },
                itemBuilder: (context, index) {
                  final message = contactMessages[index];

                  final listTileKey = ValueKey(message.id);
                  final listTile = MessageListTile(
                    onPressed: () => openViewMessageSheet(
                      context,
                      message: message,
                    ),
                    message: message,
                  );

                  if (index >= 5) {
                    return KeyedSubtree(
                      key: listTileKey,
                      child: listTile,
                    );
                  }

                  return Animate(
                    key: listTileKey,
                    delay: BokunSpizeDurations.stateTransitionStagger * index,
                    effects: const [
                      FadeEffect(
                        duration: BokunSpizeDurations.stateTransition,
                        curve: Curves.easeOut,
                      ),
                      MoveEffect(
                        begin: Offset(0, 18),
                        end: Offset.zero,
                        duration: BokunSpizeDurations.stateTransition,
                        curve: Curves.easeOutCubic,
                      ),
                      ScaleEffect(
                        begin: Offset(0.98, 0.98),
                        end: Offset(1, 1),
                        alignment: Alignment.topCenter,
                        duration: BokunSpizeDurations.stateTransition,
                        curve: Curves.easeOutCubic,
                      ),
                    ],
                    child: listTile,
                  );
                },
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
