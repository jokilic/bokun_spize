import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../constants/constants.dart';
import '../constants/durations.dart';
import '../theme/extensions.dart';
import '../util/spacing.dart';

class CalendarSheet extends StatefulWidget {
  final Color primaryColor;
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;
  final bool showConfirmButton;
  final String subtitle;

  const CalendarSheet({
    required this.primaryColor,
    required this.dateValue,
    required this.onDateChanged,
    required this.subtitle,
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
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: context.colors.scaffoldBackground.withValues(alpha: 0.5),
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
                      'Select date',
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0.6,
                        color: context.colors.text,
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
                      backgroundColor: context.colors.scaffoldBackground.withValues(alpha: 0.5),
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
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.text,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
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
                    weekdayLabelTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: context.colors.text,
                    ),
                    controlsTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: context.colors.text,
                    ),
                    todayTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: context.colors.text,
                    ),
                    dayTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.text,
                    ),
                    selectedDayTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: context.colors.listTileBackground,
                    ),
                    monthTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.text,
                    ),
                    selectedMonthTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: context.colors.listTileBackground,
                    ),
                    yearTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.text,
                    ),
                    selectedYearTextStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: context.colors.listTileBackground,
                    ),
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
                      foregroundColor: context.colors.listTileBackground,
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
