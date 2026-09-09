import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../widgets/text_field_widget.dart';

class TextFieldTitleWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String title;
  final String? hintText;
  final String? rightText;
  final Widget? rightWidget;
  final Color textColor;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;
  final bool autocorrect;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final Iterable<String>? autofillHints;
  final double textFieldFontSize;

  const TextFieldTitleWidget({
    required this.controller,
    required this.focusNode,
    required this.title,
    required this.textColor,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType = TextInputType.text,
    this.autocorrect = false,
    this.hintText,
    this.rightText,
    this.rightWidget,
    this.onChanged,
    this.onSubmitted,
    this.hintStyle,
    this.textStyle,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.autofillHints,
    this.textFieldFontSize = 22,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: BokunSpizeColors.white.withValues(
      alpha: enabled ? 0.5 : 0.25,
    ),
    borderRadius: BorderRadius.circular(listTileRadius),
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(listTileRadius),
      highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(listTileRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// TITLE
            ///
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: BokunSpizeColors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),

            ///
            /// TEXT FIELD & HINT
            ///
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ///
                /// TEXT FIELD
                ///
                Expanded(
                  child: TextFieldWidget(
                    autofillHints: autofillHints,
                    minLines: minLines,
                    maxLines: maxLines,
                    enabled: enabled,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    autocorrect: autocorrect,
                    controller: controller,
                    focusNode: focusNode,
                    hintText: hintText,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    keyboardType: keyboardType,
                    textAlign: TextAlign.left,
                    textCapitalization: textCapitalization,
                    textInputAction: textInputAction,
                    hintStyle:
                        hintStyle ??
                        TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: textFieldFontSize,
                          fontWeight: FontWeight.w700,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                    textStyle:
                        textStyle ??
                        TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: textFieldFontSize,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                  ),
                ),

                ///
                /// RIGHT TEXT
                ///
                if (rightText?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      rightText!,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                ///
                /// RIGHT WIDGET
                ///
                ?rightWidget,
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
