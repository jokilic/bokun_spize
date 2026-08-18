import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../main.dart';
import '../constants/colors.dart';

class CalendarSheet extends StatefulWidget {
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;

  const CalendarSheet({
    required this.dateValue,
    required this.onDateChanged,
  });

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  late var selectedDateTime = widget.dateValue;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          ///
          /// TITLE
          ///
          const Text(
            'Select date',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: BokunSpizeColors.neutralDark,
            ),
          ),
          const SizedBox(height: 20),

          ///
          /// CALENDAR
          ///
          CalendarDatePicker2(
            value: [widget.dateValue],
            onValueChanged: (newValue) {
              final chosenDate = newValue.firstOrNull;

              if (chosenDate != null && !DateUtils.isSameDay(widget.dateValue, chosenDate)) {
                selectedDateTime = chosenDate;
              }
            },
            config: CalendarDatePicker2Config(
              calendarType: CalendarDatePicker2Type.single,
              dynamicCalendarRows: true,
              weekdayLabelTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: BokunSpizeColors.neutralDark,
              ),
              controlsTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: BokunSpizeColors.neutralDark,
              ),
              dayTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: BokunSpizeColors.neutralDark,
              ),
              todayTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: BokunSpizeColors.neutralDark,
              ),
              selectedDayTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: BokunSpizeColors.neutralLight,
              ),
              selectedMonthTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: BokunSpizeColors.neutralLight,
              ),
              monthTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: BokunSpizeColors.neutralDark,
              ),
              selectedYearTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: BokunSpizeColors.neutralLight,
              ),
              yearTextStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: BokunSpizeColors.neutralDark,
              ),
              selectedDayHighlightColor: BokunSpizeColors.primary,
              daySplashColor: BokunSpizeColors.primary,
              dayBuilder: ({required date, textStyle, decoration, isSelected, isDisabled, isToday}) {
                var currentDecoration = decoration;

                if ((isToday ?? false) && !(isSelected ?? false)) {
                  currentDecoration = BoxDecoration(
                    border: Border.all(
                      color: BokunSpizeColors.neutralDark,
                      width: 1.5,
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
                color: BokunSpizeColors.neutralDark,
                size: 28,
              ),
              nextMonthIcon: const PhosphorIcon(
                PhosphorIconsBold.caretRight,
                color: BokunSpizeColors.neutralDark,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),

          ///
          /// SAVE BUTTON
          ///
          SizedBox(
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
                backgroundColor: BokunSpizeColors.primary,
                foregroundColor: BokunSpizeColors.white,
              ),
              child: const Text('Confirm'),
            ),
          ),

          ///
          /// BOTTOM SPACING
          ///
          SizedBox(
            height: MediaQuery.paddingOf(context).bottom + 16,
          ),
        ],
      ),
    ),
  );
}
