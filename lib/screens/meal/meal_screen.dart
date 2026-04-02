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
import '../../widgets/bokun_spize_app_bar.dart';
import '../../widgets/bokun_spize_little_button.dart';
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

    final mealState = watchIt<MealController>(
      instanceName: widget.passedMeal?.id,
    ).value;
    final speechToTextState = watchIt<SpeechToTextService>().value;

    final available = speechToTextState.available;
    final isListening = speechToTextState.isListening;

    final hasMeal = widget.passedMeal != null;

    final shouldShowTextField = !hasMeal || mealController.textEditingController.text.isNotEmpty;
    final shouldShowImage = !hasMeal || mealState.imageFile != null;

    final title = hasMeal ? 'Uredi obrok' : 'Novi obrok';
    final subtitle = hasMeal ? 'Uredi već postojeći obrok' : 'Dodaj novi obrok u svoj dnevnik';
    final buttonText = hasMeal ? 'Uredi obrok' : 'Dodaj obrok';

    final description = !shouldShowTextField
        ? 'Nisi ostavio opis obroka.'
        : hasMeal
        ? 'Ne možeš uređivati opis obroka, jedino datum i vrijeme.'
        : 'Opiši svoj obrok što detaljnije, tako će procjena biti preciznija.';

    final imageText = !shouldShowImage
        ? 'Nisi ostavio sliku obroka.'
        : hasMeal
        ? 'Ne možeš mijenjati sliku obroka, jedino datum i vrijeme.'
        : 'Dodaj sliku svog obroka, tako će procjena biti preciznija.';

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          ///
          /// APP BAR
          ///
          BokunSpizeAppBar(
            smallTitle: title,
            bigTitle: title,
            bigSubtitle: subtitle,
            leadingWidget: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                highlightColor: context.colors.buttonBackground,
              ),
              icon: PhosphorIcon(
                PhosphorIcons.arrowLeft(
                  PhosphorIconsStyle.duotone,
                ),
                color: context.colors.text,
                duotoneSecondaryColor: context.colors.buttonPrimary,
                size: 28,
              ),
            ),
            actionWidgets: [
              if (hasMeal)
                IconButton(
                  onPressed: () async {
                    unawaited(
                      HapticFeedback.lightImpact(),
                    );

                    /// Trigger delete & dismiss sheet
                    Navigator.of(context).pop(
                      (
                        words: null,
                        dateTime: null,
                        imageFile: null,
                        deleteMeal: true,
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    highlightColor: context.colors.buttonBackground,
                  ),
                  icon: PhosphorIcon(
                    PhosphorIcons.trash(
                      PhosphorIconsStyle.duotone,
                    ),
                    color: context.colors.text,
                    duotoneSecondaryColor: context.colors.delete,
                    size: 28,
                  ),
                ),
            ],
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// NEW MEAL TITLE & BUTTONS
          ///
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  ///
                  /// TITLE
                  ///
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Opis obroka',
                        style: context.textStyles.homeTitle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  ///
                  /// VOICE BUTTON
                  ///
                  if (!hasMeal)
                    BokunSpizeLittleButton(
                      onPressed: () async {
                        unawaited(
                          HapticFeedback.lightImpact(),
                        );

                        /// Trigger speech to text
                        await mealController.onSpeechToTextPressed(
                          locale: 'hr',
                          speechToTextAvailable: available,
                        );
                      },
                      icon: PhosphorIcons.microphone(
                        PhosphorIconsStyle.duotone,
                      ),
                      backgroundColor: isListening ? context.colors.buttonPrimary : Colors.transparent,
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// TEXT FIELD
          ///
          if (shouldShowTextField) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
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
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
          ],

          ///
          /// TEXT
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverToBoxAdapter(
              child: Text(
                description,
                style: context.textStyles.homeMealNote,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 12),
          ),

          ///
          /// IMAGE
          ///
          SliverToBoxAdapter(
            child: AnimatedSize(
              alignment: Alignment.topLeft,
              duration: BokunSpizeDurations.animation,
              curve: Curves.easeIn,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  /// TITLE & BUTTONS
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
                              'Slika obroka',
                              style: context.textStyles.homeTitle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        if (!hasMeal) ...[
                          ///
                          /// GALLERY BUTTON
                          ///
                          BokunSpizeLittleButton(
                            onPressed: () async {
                              unawaited(
                                HapticFeedback.lightImpact(),
                              );

                              /// Trigger camera
                              await mealController.onGalleryPressed();
                            },
                            icon: PhosphorIcons.images(
                              PhosphorIconsStyle.duotone,
                            ),
                          ),
                          const SizedBox(width: 4),

                          ///
                          /// CAMERA BUTTON
                          ///
                          BokunSpizeLittleButton(
                            onPressed: () async {
                              unawaited(
                                HapticFeedback.lightImpact(),
                              );

                              /// Trigger camera
                              await mealController.onCameraPressed();
                            },
                            icon: PhosphorIcons.camera(
                              PhosphorIconsStyle.duotone,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],

                        ///
                        /// DELETE BUTTON
                        ///
                        if (!hasMeal && mealState.imageFile != null)
                          BokunSpizeLittleButton(
                            onPressed: () async {
                              unawaited(
                                HapticFeedback.lightImpact(),
                              );

                              /// Update `state` + trigger validation
                              mealController
                                ..updateState(
                                  imageFile: null,
                                )
                                ..triggerValidation();
                            },
                            icon: PhosphorIcons.trash(
                              PhosphorIconsStyle.duotone,
                            ),
                            duotoneSecondaryColor: context.colors.delete,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  ///
                  /// IMAGE
                  ///
                  if (shouldShowImage) ...[
                    Material(
                      color: context.colors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: !hasMeal && mealState.imageFile == null
                            ? () async {
                                unawaited(
                                  HapticFeedback.lightImpact(),
                                );

                                /// Trigger camera
                                await mealController.onCameraPressed();
                              }
                            : null,
                        highlightColor: context.colors.listTileBackground,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.colors.text,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AnimatedSwitcher(
                            duration: BokunSpizeDurations.animation,
                            reverseDuration: BokunSpizeDurations.animation,
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeIn,
                            child: mealState.imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      key: ValueKey(mealState.imageFile!),
                                      mealState.imageFile!,
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: context.colors.delete.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                        height: 160,
                                        width: double.infinity,
                                        child: PhosphorIcon(
                                          PhosphorIcons.imageBroken(
                                            PhosphorIconsStyle.duotone,
                                          ),
                                          color: context.colors.text,
                                          size: 56,
                                          duotoneSecondaryColor: context.colors.delete,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: !hasMeal ? context.colors.listTileBackground : Colors.transparent,
                                    ),
                                    height: 160,
                                    width: double.infinity,
                                    child: PhosphorIcon(
                                      !hasMeal && mealState.imageFile == null
                                          ? PhosphorIcons.bowlFood(
                                              PhosphorIconsStyle.duotone,
                                            )
                                          : PhosphorIcons.x(
                                              PhosphorIconsStyle.duotone,
                                            ),
                                      size: 56,
                                      color: context.colors.text,
                                      duotoneSecondaryColor: context.colors.buttonPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  ///
                  /// TEXT
                  ///
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      imageText,
                      style: context.textStyles.homeMealNote,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          ///
          /// DATE TITLE & EXPAND BUTTON
          ///
          SliverPadding(
            padding: const EdgeInsets.only(left: 28, right: 20),
            sliver: SliverToBoxAdapter(
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
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// DATE & TIME
          ///
          SliverToBoxAdapter(
            child: Column(
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
        ],
      ),

      ///
      /// ADD BUTTON
      ///
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: mealState.validationPassed
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
                        imageFile: mealState.imageFile,
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
    );
  }
}
