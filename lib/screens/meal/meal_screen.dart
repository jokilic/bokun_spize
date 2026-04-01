import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../theme/colors.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/color.dart';
import '../../constants/durations.dart';
import '../../models/meal.dart';
import '../../services/speech_to_text_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../widgets/bokun_spize_text_field.dart';
import 'meal_controller.dart';

class MealScreen extends WatchingStatefulWidget {
  final Meal? passedMeal;

  const MealScreen({
    required this.passedMeal,
  });

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<MealController>(
      () => MealController(
        speechToText: getIt.get<SpeechToTextService>(),
        passedMeal: widget.passedMeal,
      ),
      instanceName: widget.passedMeal?.id,
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<MealController>(
      instanceName: widget.passedMeal?.id,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealController = getIt.get<MealController>(
      instanceName: widget.passedMeal?.id,
    );
    final speechToTextService = getIt.get<SpeechToTextService>();

    final mealState = watchIt<MealController>(
      instanceName: widget.passedMeal?.id,
    ).value;
    final speechToTextState = watchIt<SpeechToTextService>().value;

    final available = speechToTextState.available;
    final isListening = speechToTextState.isListening;

    final hasMeal = widget.passedMeal != null;

    final title = hasMeal ? 'Uredi obrok' : 'Novi obrok';
    final buttonText = hasMeal ? 'Uredi obrok' : 'Dodaj obrok';

    final description = hasMeal ? 'Ne možeš uređivati opis obroka, jedino datum i vrijeme.' : 'Opiši svoj obrok što detaljnije, tako će procjena biti preciznija.';

    return Material(
      color: context.colors.scaffoldBackground,
      borderRadius: BorderRadius.circular(8),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          ///
          /// NEW MEAL TITLE & VOICE BUTTON
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
                      title,
                      style: context.textStyles.homeTitle,
                    ),
                  ),
                ),

                ///
                /// VOICE OR DELETE BUTTON
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

                      /// Meal exists, trigger delete
                      if (hasMeal) {
                        /// Dismiss sheet
                        Navigator.of(context).pop(
                          (
                            words: null,
                            dateTime: null,
                            deleteMeal: true,
                          ),
                        );
                      }
                      /// New meal, trigger speech to text
                      else {
                        /// Speech to text is not available, initialize & trigger it
                        if (!available) {
                          await speechToTextService.loadSpeechToText();
                          await mealController.onSpeechToTextPressed(
                            locale: 'hr',
                          );
                        }
                        /// Speech to text is available, trigger it
                        else {
                          await mealController.onSpeechToTextPressed(
                            locale: 'hr',
                          );
                        }
                      }
                    },
                    highlightColor: context.colors.listTileBackground,
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
                        hasMeal
                            ? PhosphorIcons.trash(
                                PhosphorIconsStyle.duotone,
                              )
                            : PhosphorIcons.microphone(
                                PhosphorIconsStyle.duotone,
                              ),
                        color: context.colors.text,
                        duotoneSecondaryColor: hasMeal ? context.colors.delete : context.colors.buttonPrimary,
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
            child: Material(
              color: context.colors.scaffoldBackground,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onLongPress: hasMeal
                    ? () {
                        HapticFeedback.lightImpact();

                        /// Get text from [TextEditingController]
                        final text = mealController.textEditingController.text.trim();

                        /// No text, return
                        if (text.isEmpty) {
                          return;
                        }

                        /// Copy text to clipboard
                        Clipboard.setData(
                          ClipboardData(
                            text: text,
                          ),
                        );
                      }
                    : null,
                highlightColor: context.colors.listTileBackground,
                borderRadius: BorderRadius.circular(8),
                child: BokunSpizeTextField(
                  enabled: !hasMeal,
                  controller: mealController.textEditingController,
                  labelText: 'Što si imao za obrok?',
                  keyboardType: TextInputType.multiline,
                  minLines: null,
                  maxLines: 3,
                  textAlign: TextAlign.left,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          ///
          /// TEXT
          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              description,
              style: context.textStyles.homeMealNote,
            ),
          ),
          const SizedBox(height: 20),

          ///
          /// DATE TITLE & EXPAND BUTTON
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
                      'Datum i vrijeme',
                      style: context.textStyles.homeTitle,
                    ),
                  ),
                ),

                ///
                /// EXPAND BUTTON
                ///
                const SizedBox(width: 4),
                Material(
                  color: context.colors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      mealController.updateState(
                        expanded: !mealController.value.expanded,
                      );
                    },
                    highlightColor: context.colors.listTileBackground,
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeIn,
                      padding: const EdgeInsets.all(8),
                      child: PhosphorIcon(
                        mealState.expanded
                            ? PhosphorIcons.caretUp(
                                PhosphorIconsStyle.duotone,
                              )
                            : PhosphorIcons.caretDown(
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
          /// DATE & TIME
          ///
          AnimatedCrossFade(
            alignment: Alignment.centerLeft,
            duration: BokunSpizeDurations.animation,
            firstCurve: Curves.easeIn,
            secondCurve: Curves.easeIn,
            sizeCurve: Curves.easeIn,
            crossFadeState: mealState.expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                ///
                /// DATE
                ///
                Material(
                  color: context.colors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      mealController.updateState(
                        dateEditMode: true,
                      );
                    },
                    highlightColor: context.colors.buttonBackground,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                      decoration: BoxDecoration(
                        color: mealState.dateEditMode ? context.colors.listTileBackground : null,
                        border: Border.all(
                          color: context.colors.text,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IgnorePointer(
                        ignoring: !mealState.dateEditMode,
                        child: CalendarDatePicker2(
                          config: CalendarDatePicker2Config(
                            calendarViewScrollPhysics: const BouncingScrollPhysics(),
                            currentDate: DateTime.now(),
                            customModePickerIcon: const SizedBox.shrink(),
                            daySplashColor: Colors.transparent,
                            dynamicCalendarRows: true,
                            hideMonthPickerDividers: true,
                            hideScrollViewMonthWeekHeader: true,
                            hideScrollViewTopHeader: true,
                            hideScrollViewTopHeaderDivider: true,
                            hideYearPickerDividers: true,
                            lastMonthIcon: PhosphorIcon(
                              PhosphorIcons.caretCircleLeft(
                                PhosphorIconsStyle.duotone,
                              ),
                              color: context.colors.text,
                              duotoneSecondaryColor: context.colors.buttonPrimary,
                              size: 28,
                            ),
                            nextMonthIcon: PhosphorIcon(
                              PhosphorIcons.caretCircleRight(
                                PhosphorIconsStyle.duotone,
                              ),
                              color: context.colors.text,
                              duotoneSecondaryColor: context.colors.buttonPrimary,
                              size: 28,
                            ),
                            selectedDayHighlightColor: context.colors.text,
                            controlsTextStyle: context.textStyles.homeTitle,
                            dayTextStyle: context.textStyles.homeMealKcal,
                            monthTextStyle: context.textStyles.homeMealKcal,
                            selectedDayTextStyle: context.textStyles.homeMealKcal.copyWith(
                              color: context.colors.listTileBackground,
                            ),
                            selectedMonthTextStyle: context.textStyles.homeMealKcal,
                            selectedYearTextStyle: context.textStyles.homeMealKcal,
                            todayTextStyle: context.textStyles.homeMealKcal,
                            weekdayLabelTextStyle: context.textStyles.homeMealNote,
                            yearTextStyle: context.textStyles.homeMealKcal,
                          ),
                          value: [mealState.transactionDate],
                          onValueChanged: (dates) => mealController.updateState(
                            transactionDate: dates.first,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                ///
                /// TIME
                ///
                Material(
                  color: context.colors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      mealController.updateState(
                        timeEditMode: true,
                      );
                    },
                    highlightColor: context.colors.buttonBackground,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: mealState.timeEditMode ? context.colors.listTileBackground : null,
                        border: Border.all(
                          color: context.colors.text,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IgnorePointer(
                        ignoring: !mealState.timeEditMode,
                        child: ScrollDateTimePicker(
                          onChange: (newTime) => mealController.updateState(
                            transactionTime: newTime,
                          ),
                          itemExtent: 64,
                          style: DateTimePickerStyle(
                            activeStyle: context.textStyles.homeMealValue,
                            inactiveStyle: context.textStyles.homeMealKcal,
                            disabledStyle: context.textStyles.homeMealKcal.copyWith(
                              color: context.colors.disabledText,
                            ),
                          ),
                          wheelOption: const DateTimePickerWheelOption(
                            physics: BouncingScrollPhysics(),
                          ),
                          dateOption: DateTimePickerOption(
                            dateFormat: DateFormat(
                              'HH:mm',
                              'hr',
                            ),
                            minDate: DateTime(2010),
                            maxDate: DateTime(2040),
                            initialDate: mealState.transactionTime,
                          ),
                          centerWidget: DateTimePickerCenterWidget(
                            builder: (context, constraints, child) => Container(
                              decoration: ShapeDecoration(
                                color: context.colors.listTileBackground,
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: context.colors.text,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),

          ///
          /// ADD BUTTON
          ///
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: mealState.wordsValid
                    ? () {
                        HapticFeedback.lightImpact();

                        /// Get `words` from [TextEditingController]
                        final words = mealController.textEditingController.text.trim();

                        /// Dismiss sheet
                        Navigator.of(context).pop(
                          (
                            words: words,
                            dateTime: getTransactionDateTime(
                              transactionDate: mealState.transactionDate,
                              transactionTime: mealState.transactionTime,
                            ),
                            deleteMeal: false,
                          ),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    MediaQuery.paddingOf(context).bottom + 12,
                  ),
                  backgroundColor: context.colors.buttonPrimary,
                  foregroundColor: getWhiteOrBlackColor(
                    backgroundColor: context.colors.buttonPrimary,
                    whiteColor: BokunSpizeColors.darkThemeText,
                    blackColor: BokunSpizeColors.lightThemeText,
                  ),
                  overlayColor: context.colors.listTileBackground,
                  disabledBackgroundColor: context.colors.disabledBackground,
                  disabledForegroundColor: context.colors.disabledText,
                ),
                child: Text(
                  buttonText.toUpperCase(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
