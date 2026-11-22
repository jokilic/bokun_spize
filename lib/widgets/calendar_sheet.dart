import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../constants/constants.dart';
import '../constants/durations.dart';
import '../theme/extensions.dart';
import '../util/spacing.dart';

class CalendarSheet extends StatefulWidget {
  final Color primaryColor;
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;
  final String subtitle;
  final bool showConfirmButton;

  const CalendarSheet({
    required this.primaryColor,
    required this.dateValue,
    required this.onDateChanged,
    required this.subtitle,
    required this.showConfirmButton,
  });

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  late var selectedDateTime = widget.dateValue;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: Material(
      color: context.colors.scaffoldBackground,
      child: CustomScrollView(
        shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          ///
          /// TITLE & CLOSE BUTTON
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 10),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ///
                    /// PLACEHOLDER BUTTON
                    ///
                    Opacity(
                      opacity: 0,
                      child: IgnorePointer(
                        child: IconButton(
                          onPressed: null,
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.x,
                            size: 22,
                          ),
                          style: IconButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                            foregroundColor: context.colors.text,
                          ),
                        ),
                      ),
                    ),

                    ///
                    /// TITLE
                    ///
                    Expanded(
                      child: Text(
                        'calendarSheetTitle'.tr(),
                        style: context.textStyles.sheetTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    ///
                    /// CLOSE BUTTON
                    ///
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const PhosphorIcon(
                        PhosphorIconsBold.x,
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                        foregroundColor: context.colors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ///
          /// SUBTITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 2,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 8),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Text(
                  widget.subtitle,
                  style: context.textStyles.sheetSubtitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),

          ///
          /// CALENDAR
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: marginHorizontal,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 3,
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOut,
                  ),
                  ScaleEffect(
                    begin: Offset(0.98, 0.98),
                    end: Offset(1, 1),
                    alignment: Alignment.topCenter,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: AnimatedSize(
                  alignment: Alignment.topCenter,
                  duration: BokunSpizeDurations.animation,
                  curve: Curves.easeIn,
                  child: Theme(
                    data: ThemeData(
                      brightness: Theme.brightnessOf(context),
                    ),
                    child: Localizations.override(
                      context: context,
                      delegates: GlobalMaterialLocalizations.delegates,
                      child: Material(
                        type: MaterialType.transparency,
                        child: CalendarDatePicker2(
                          value: [widget.dateValue],
                          onValueChanged: (newValue) {
                            final chosenDate = newValue.firstOrNull;

                            if (chosenDate != null && !DateUtils.isSameDay(widget.dateValue, chosenDate)) {
                              selectedDateTime = chosenDate;

                              if (!widget.showConfirmButton) {
                                widget.onDateChanged(selectedDateTime);
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          config: CalendarDatePicker2Config(
                            calendarViewScrollPhysics: const BouncingScrollPhysics(),
                            calendarType: CalendarDatePicker2Type.single,
                            dynamicCalendarRows: true,
                            customModePickerIcon: const SizedBox.shrink(),
                            weekdayLabelTextStyle: context.textStyles.calendarWeekdayLabel,
                            controlsTextStyle: context.textStyles.calendarControl,
                            todayTextStyle: context.textStyles.calendarToday,
                            dayTextStyle: context.textStyles.calendarDay,
                            selectedDayTextStyle: context.textStyles.calendarSelectedDay,
                            monthTextStyle: context.textStyles.calendarPeriod,
                            selectedMonthTextStyle: context.textStyles.calendarSelectedPeriod,
                            yearTextStyle: context.textStyles.calendarPeriod,
                            selectedYearTextStyle: context.textStyles.calendarSelectedPeriod,
                            selectedDayHighlightColor: widget.primaryColor,
                            daySplashColor: widget.primaryColor,
                            dayBuilder: ({required date, textStyle, decoration, isSelected, isDisabled, isToday}) {
                              var currentDecoration = decoration;

                              if ((isToday ?? false) && !(isSelected ?? false)) {
                                currentDecoration = BoxDecoration(
                                  border: Border.all(
                                    color: context.colors.text,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                );
                              }

                              return Container(
                                alignment: Alignment.center,
                                decoration: currentDecoration,
                                child: Text(
                                  DateFormat.d().format(date),
                                  style: textStyle,
                                ),
                              );
                            },
                            firstDayOfWeek: DateTime.monday,
                            lastMonthIcon: PhosphorIcon(
                              PhosphorIconsBold.caretLeft,
                              color: context.colors.text,
                              size: 22,
                            ),
                            nextMonthIcon: PhosphorIcon(
                              PhosphorIconsBold.caretRight,
                              color: context.colors.text,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          ///
          /// SAVE BUTTON
          ///
          if (widget.showConfirmButton) ...[
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 4,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 14),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onDateChanged(selectedDateTime);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: context.textStyles.mainButton,
                        padding: const EdgeInsets.all(20),
                        backgroundColor: widget.primaryColor,
                        foregroundColor: context.colors.buttonText,
                      ),
                      child: Text(
                        'confirmDate'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          ///
          /// BOTTOM SPACING
          ///
          SliverToBoxAdapter(
            child: SizedBox(
              height: getBottomSpacing(context),
            ),
          ),
        ],
      ),
    ),
  );
}
