import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/colors.dart';
import '../../../theme/extensions.dart';
import '../../../util/color.dart';
import 'bokun_spize_text_field.dart';

class AddMealModal extends StatefulWidget {
  @override
  State<AddMealModal> createState() => _AddMealModalState();
}

class _AddMealModalState extends State<AddMealModal> {
  var isWordsValid = false;

  late final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// Validation
    textEditingController.addListener(validateTextField);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  /// Triggered on every [TextField] change
  /// Updates `Add` button state
  void validateTextField() {
    /// Parse values
    final words = textEditingController.text.trim();

    /// Validate values
    updateState(
      wordsValid: words.isNotEmpty,
    );
  }

  /// Updates `state`
  void updateState({
    bool? wordsValid,
  }) => setState(
    () => isWordsValid = wordsValid ?? isWordsValid,
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///
          /// EMAIL & PASSWORD
          ///

          ///
          /// TEXT
          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Nova spiza',
              style: context.textStyles.homeTitle,
            ),
          ),
          const SizedBox(height: 12),

          ///
          /// TEXT FIELD
          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BokunSpizeTextField(
              controller: textEditingController,
              labelText: 'Šta si izija?',
              keyboardType: TextInputType.multiline,
              minLines: null,
              maxLines: 3,
              textAlign: TextAlign.left,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(height: 28),

          ///
          /// BUTTON
          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isWordsValid
                    ? () {
                        HapticFeedback.lightImpact();

                        /// Parse values
                        final words = textEditingController.text.trim();

                        /// Dismiss sheet
                        Navigator.of(context).pop(words);
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.buttonPrimary,
                  foregroundColor: getWhiteOrBlackColor(
                    backgroundColor: context.colors.buttonPrimary,
                    whiteColor: BokunSpizeColors.lightThemeWhiteBackground,
                    blackColor: BokunSpizeColors.lightThemeBlackText,
                  ),
                  overlayColor: context.colors.buttonBackground,
                  disabledBackgroundColor: context.colors.disabledBackground,
                  disabledForegroundColor: context.colors.disabledText,
                ),
                child: Text(
                  'Dodaj'.toUpperCase(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
