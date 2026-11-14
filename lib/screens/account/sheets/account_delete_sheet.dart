import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';
import '../../../util/spacing.dart';
import '../../../widgets/text_field_widget.dart';

class AccountDeleteSheet extends StatefulWidget {
  final String deleteWord;
  final Function(String? password) onDeletePressed;
  final bool requiresPassword;

  const AccountDeleteSheet({
    required this.deleteWord,
    required this.onDeletePressed,
    required this.requiresPassword,
  });

  @override
  State<AccountDeleteSheet> createState() => _AccountDeleteSheetState();
}

class _AccountDeleteSheetState extends State<AccountDeleteSheet> {
  late final TextEditingController confirmController;
  late final TextEditingController passwordController;
  late final FocusNode confirmFocusNode;

  @override
  void initState() {
    super.initState();

    confirmController = TextEditingController();
    passwordController = TextEditingController();
    confirmFocusNode = FocusNode();
  }

  @override
  void dispose() {
    confirmController.dispose();
    passwordController.dispose();
    confirmFocusNode.dispose();

    super.dispose();
  }

  void deleteAccount() {
    FocusManager.instance.primaryFocus?.unfocus();

    final password = widget.requiresPassword ? passwordController.text.trim() : null;

    widget.onDeletePressed(password);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final validated =
        confirmController.text.isNotEmpty &&
        confirmController.text.toLowerCase() == widget.deleteWord.toLowerCase() &&
        (!widget.requiresPassword || passwordController.text.length >= 8);

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
                          'accountDeleteSheetTitle'.tr(),
                          style: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 24,
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
                    'accountDeleteSheetSubtitle'.tr(),
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),

            ///
            /// EXPLANATION
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: marginHorizontal,
                vertical: 8,
              ),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 3,
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
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(listTileRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(listTileRadius),
                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(listTileRadius),
                          color: context.colors.listTileBackground.withValues(alpha: 0.5),
                        ),
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
                                color: context.colors.delete.withValues(alpha: 0.25),
                                child: PhosphorIcon(
                                  PhosphorIconsBold.warningOctagon,
                                  color: context.colors.delete,
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
                                  Text(
                                    'deleteAccountExplanationTitle'.tr(),
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: context.colors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'deleteAccountExplanationSubtitle'.tr(),
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            ///
            /// PASSWORD TEXT FIELD
            ///
            if (widget.requiresPassword) ...[
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
                      autofocus: widget.requiresPassword,
                      obscureText: true,
                      controller: passwordController,
                      title: 'password'.tr(),
                      hintText: '•' * 8,
                      onSubmitted: (_) => confirmFocusNode.requestFocus(),
                      textColor: context.colors.text,
                      autofillHints: const [AutofillHints.password],
                      keyboardType: TextInputType.visiblePassword,
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.go,
                      onChanged: (_) => setState(() {}),
                      textFieldFontSize: 18,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],

            ///
            /// DELETE TEXT FIELD
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * (widget.requiresPassword ? 5 : 4),
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
                    autofocus: !widget.requiresPassword,
                    controller: confirmController,
                    focusNode: confirmFocusNode,
                    title: 'accountDeleteSheetTextFieldTitle'.tr(
                      args: [widget.deleteWord],
                    ),
                    hintText: widget.deleteWord,
                    onSubmitted: (_) {
                      if (!validated) {
                        return;
                      }

                      deleteAccount();
                    },
                    textColor: context.colors.text,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: widget.requiresPassword ? TextInputAction.next : TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    textFieldFontSize: 18,
                  ),
                ),
              ),
            ),

            ///
            /// DELETE BUTTON
            ///
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * (widget.requiresPassword ? 6 : 5),
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
                      onPressed: validated ? deleteAccount : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: context.colors.delete,
                        foregroundColor: context.colors.buttonText,
                      ),
                      child: Text(
                        'accountDeleteButton'.tr(),
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
