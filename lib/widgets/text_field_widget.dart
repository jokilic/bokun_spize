import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
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

  const TextFieldWidget({
    required this.controller,
    required this.title,
    required this.textColor,
    this.focusNode,
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
                  child: TextFieldBody(
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

class TextFieldBody extends StatelessWidget {
  final bool autocorrect;
  final bool autofocus;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final Widget? hintWidget;
  final TextInputType keyboardType;
  final int? minLines;
  final int? maxLines;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;
  final Iterable<String>? autofillHints;
  final double borderRadius;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final EdgeInsets contentPadding;
  final bool enabled;
  final bool filled;

  const TextFieldBody({
    required this.controller,
    required this.keyboardType,
    required this.textAlign,
    required this.textCapitalization,
    required this.textInputAction,
    this.textAlignVertical,
    this.hintText,
    this.hintWidget,
    this.focusNode,
    this.autocorrect = true,
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.borderRadius = 100,
    this.hintStyle,
    this.textStyle,
    this.contentPadding = const EdgeInsets.all(20),
    this.enabled = true,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) => TextField(
    enabled: enabled,
    autofillHints: autofillHints,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    obscureText: obscureText,
    autocorrect: autocorrect,
    autofocus: autofocus,
    controller: controller,
    focusNode: focusNode,
    cursorHeight: 24,
    cursorRadius: const Radius.circular(8),
    cursorWidth: 1.5,
    cursorColor: BokunSpizeColors.green,
    decoration: InputDecoration(
      isDense: true,
      filled: filled,
      enabled: enabled,
      fillColor: BokunSpizeColors.white.withValues(
        alpha: enabled ? 0.5 : 0.25,
      ),
      contentPadding: contentPadding,
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      hint: hintWidget,
      hintText: hintText,
      hintStyle:
          hintStyle ??
          TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: BokunSpizeColors.black.withValues(alpha: 0.5),
          ),
    ),
    keyboardType: keyboardType,
    minLines: minLines,
    maxLines: maxLines,
    style:
        textStyle ??
        const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: BokunSpizeColors.black,
        ),
    textAlign: textAlign,
    textAlignVertical: textAlignVertical,
    textCapitalization: textCapitalization,
    textInputAction: textInputAction,
  );
}
