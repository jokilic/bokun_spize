import 'package:flutter/material.dart';

import '../constants/colors.dart';

class TextFieldWidget extends StatelessWidget {
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

  const TextFieldWidget({
    required this.controller,
    required this.keyboardType,
    required this.textAlign,
    required this.textCapitalization,
    required this.textInputAction,
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
  });

  @override
  Widget build(BuildContext context) => TextField(
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
      filled: true,
      fillColor: BokunSpizeColors.white.withValues(alpha: 0.5),
      contentPadding: contentPadding,
      border: OutlineInputBorder(
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
    textCapitalization: textCapitalization,
    textInputAction: textInputAction,
  );
}
