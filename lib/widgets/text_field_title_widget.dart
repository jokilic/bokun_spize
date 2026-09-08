import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../widgets/text_field_widget.dart';

class TextFieldTitleWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final String title;
  final String? hintText;
  final String? rightText;
  final Color textColor;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;
  final bool autocorrect;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  const TextFieldTitleWidget({
    required this.textEditingController,
    required this.focusNode,
    required this.title,
    required this.textColor,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType = TextInputType.text,
    this.autocorrect = false,
    this.hintText,
    this.rightText,
    this.onChanged,
    this.onSubmitted,
    this.hintStyle,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: BokunSpizeColors.white.withValues(alpha: 0.5),
    borderRadius: BorderRadius.circular(listTileRadius),
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(listTileRadius),
      highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
            const SizedBox(height: 4),

            ///
            /// TEXT FIELD & HINT
            ///
            Row(
              children: [
                ///
                /// TEXT FIELD
                ///
                Expanded(
                  child: TextFieldWidget(
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    autocorrect: autocorrect,
                    controller: textEditingController,
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
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                    textStyle:
                        textStyle ??
                        TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                  ),
                ),

                ///
                /// HINT
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
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
