import 'package:flutter/material.dart';

import '../theme/extensions.dart';

class BokunSpizeTextField extends StatelessWidget {
  final bool autocorrect;
  final bool autofocus;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final TextInputType keyboardType;
  final int? minLines;
  final int? maxLines;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final Function(String value)? onSubmitted;
  final Iterable<String>? autofillHints;

  const BokunSpizeTextField({
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    required this.textAlign,
    required this.textCapitalization,
    required this.textInputAction,
    this.focusNode,
    this.autocorrect = true,
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.onSubmitted,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: context.colors.text,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(8),
    );

    return TextField(
      autofillHints: autofillHints,
      enabled: enabled,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      autocorrect: autocorrect,
      autofocus: autofocus,
      controller: controller,
      focusNode: focusNode,
      cursorHeight: 24,
      cursorRadius: const Radius.circular(8),
      cursorWidth: 1.5,
      cursorColor: context.colors.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? context.colors.listTileBackground : null,
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: border,
        disabledBorder: border,
        focusedErrorBorder: border,
        labelText: labelText,
        labelStyle: context.textStyles.textField,
      ),
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      style: context.textStyles.textField,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
    );
  }
}
