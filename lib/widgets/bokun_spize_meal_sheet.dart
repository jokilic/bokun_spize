import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../theme/colors.dart';
import '../../../theme/extensions.dart';
import '../../../util/color.dart';
import '../constants/durations.dart';
import '../screens/home/home_controller.dart';
import '../services/speech_to_text_service.dart';
import '../util/dependencies.dart';
import 'bokun_spize_text_field.dart';

class BokunSpizeMealSheet extends WatchingStatefulWidget {
  final TextEditingController textEditingController;

  const BokunSpizeMealSheet({
    required this.textEditingController,
  });

  @override
  State<BokunSpizeMealSheet> createState() => _BokunSpizeMealSheetState();
}

class _BokunSpizeMealSheetState extends State<BokunSpizeMealSheet> {
  var isWordsValid = false;

  @override
  void initState() {
    super.initState();

    /// Validation
    widget.textEditingController.addListener(validateTextField);
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(validateTextField);
    getIt.get<HomeController>().onDismissSheet();
    super.dispose();
  }

  /// Triggered on every [TextField] change
  /// Updates `Add` button state
  void validateTextField() {
    /// Parse values
    final words = widget.textEditingController.text.trim();

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
  Widget build(BuildContext context) {
    final homeController = getIt.get<HomeController>();
    final speechToTextService = getIt.get<SpeechToTextService>();

    final speechToTextState = watchIt<SpeechToTextService>().value;

    final available = speechToTextState.available;
    final isListening = speechToTextState.isListening;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// TITLE & VOICE BUTTON
            ///
            Padding(
              padding: const EdgeInsets.only(left: 28, right: 20),
              child: Row(
                children: [
                  ///
                  /// TITLE
                  ///
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Novi obrok',
                        style: context.textStyles.homeTitle,
                      ),
                    ),
                  ),

                  ///
                  /// VOICE BUTTON
                  ///
                  const SizedBox(width: 4),
                  Material(
                    color: context.colors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () async {
                        unawaited(
                          HapticFeedback.lightImpact(),
                        );

                        /// Speech to text is available, trigger it
                        if (available) {
                          await homeController.onSpeechToTextPressed(
                            locale: 'en',
                          );
                        }
                        /// Speech to text is not available, initialize it
                        else {
                          await speechToTextService.loadSpeechToText();
                        }
                      },
                      highlightColor: context.colors.buttonBackground,
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        decoration: BoxDecoration(
                          color: isListening ? context.colors.buttonPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        duration: BokunSpizeDurations.animation,
                        curve: Curves.easeIn,
                        padding: const EdgeInsets.all(8),
                        child: PhosphorIcon(
                          PhosphorIcons.microphone(
                            PhosphorIconsStyle.duotone,
                          ),
                          color: context.colors.text,
                          duotoneSecondaryColor: context.colors.buttonPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            ///
            /// TEXT FIELD
            ///
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BokunSpizeTextField(
                controller: widget.textEditingController,
                labelText: 'Što si imao za obrok?',
                keyboardType: TextInputType.multiline,
                minLines: null,
                maxLines: 3,
                textAlign: TextAlign.left,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
              ),
            ),
            const SizedBox(height: 8),

            ///
            /// TEXT
            ///
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Opiši svoj obrok što detaljnije, tako će procjena biti preciznija.',
                style: context.textStyles.homeMealNote,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Nešto poput "Dva komada pohanog mesa uz malo pire krumpira i čašu Coca Cole"',
                style: context.textStyles.homeMealNote,
              ),
            ),
            const SizedBox(height: 28),

            ///
            /// ADD BUTTON
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
                          final words = widget.textEditingController.text.trim();

                          /// Dismiss sheet
                          Navigator.of(context).pop(words);
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.buttonPrimary,
                    foregroundColor: getWhiteOrBlackColor(
                      backgroundColor: context.colors.buttonPrimary,
                      whiteColor: BokunSpizeColors.whiteBackground,
                      blackColor: BokunSpizeColors.black,
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
