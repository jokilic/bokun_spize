import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../widgets/text_field_widget.dart';

class ManualAddMealNutritionTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final String title;
  final String hintText;
  final Color textColor;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;

  const ManualAddMealNutritionTextField({
    required this.textEditingController,
    required this.focusNode,
    required this.title,
    required this.hintText,
    required this.textColor,
    this.onChanged,
    this.onSubmitted,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(listTileRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// TITLE
            ///
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: BokunSpizeColors.black.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),

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
                    autocorrect: false,
                    controller: textEditingController,
                    focusNode: focusNode,
                    hintText: '0',
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.left,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    hintStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                    textStyle: TextStyle(
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
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    hintText,
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
