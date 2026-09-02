import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';
import '../constants/durations.dart';
import '../util/spacing.dart';

class CalendarSheet extends StatefulWidget {
  final Color primaryColor;
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;
  final bool showConfirmButton;

  const CalendarSheet({
    required this.primaryColor,
    required this.dateValue,
    required this.onDateChanged,
    this.showConfirmButton = true,
  });

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  late var selectedDateTime = widget.dateValue;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
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
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: BokunSpizeColors.grey.withValues(alpha: 0.5),
                          foregroundColor: BokunSpizeColors.black,
                        ),
                      ),
                    ),
                  ),

                  ///
                  /// TITLE
                  ///
                  const Expanded(
                    child: Text(
                      'Select date',
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0.6,
                        color: BokunSpizeColors.black,
                      ),
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
                      padding: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      backgroundColor: BokunSpizeColors.grey.withValues(alpha: 0.5),
                      foregroundColor: BokunSpizeColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),

        ///
        /// CALENDAR
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
                    weekdayLabelTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: BokunSpizeColors.black,
                    ),
                    controlsTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: BokunSpizeColors.black,
                    ),
                    todayTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: BokunSpizeColors.black,
                    ),
                    dayTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: BokunSpizeColors.black,
                    ),
                    selectedDayTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: BokunSpizeColors.white,
                    ),
                    monthTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BokunSpizeColors.black,
                    ),
                    selectedMonthTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: BokunSpizeColors.white,
                    ),
                    yearTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BokunSpizeColors.black,
                    ),
                    selectedYearTextStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: BokunSpizeColors.white,
                    ),
                    selectedDayHighlightColor: widget.primaryColor,
                    daySplashColor: widget.primaryColor,
                    dayBuilder: ({required date, textStyle, decoration, isSelected, isDisabled, isToday}) {
                      var currentDecoration = decoration;

                      if ((isToday ?? false) && !(isSelected ?? false)) {
                        currentDecoration = BoxDecoration(
                          border: Border.all(
                            color: BokunSpizeColors.black,
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
                    lastMonthIcon: const PhosphorIcon(
                      PhosphorIconsBold.caretLeft,
                      color: BokunSpizeColors.black,
                      size: 22,
                    ),
                    nextMonthIcon: const PhosphorIcon(
                      PhosphorIconsBold.caretRight,
                      color: BokunSpizeColors.black,
                      size: 22,
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
            child: SizedBox(height: 20),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 3,
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
                      textStyle: const TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      padding: const EdgeInsets.all(22),
                      backgroundColor: widget.primaryColor,
                      foregroundColor: BokunSpizeColors.white,
                    ),
                    child: const Text(
                      'Confirm',
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
  );
}
