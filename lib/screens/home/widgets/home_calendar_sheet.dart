import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';

class HomeCalendarSheet extends StatelessWidget {
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;

  const HomeCalendarSheet({
    required this.dateValue,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: CalendarDatePicker2(
        value: [dateValue],
        onValueChanged: (newValue) {
          final chosenDate = newValue.firstOrNull;

          if (chosenDate != null && !DateUtils.isSameDay(dateValue, chosenDate)) {
            onDateChanged(chosenDate);
            Navigator.of(context).pop();
          }
        },
        config: CalendarDatePicker2Config(
          calendarType: CalendarDatePicker2Type.single,
          weekdayLabelTextStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.neutralDark,
          ),
          controlsTextStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.neutralDark,
          ),
          dayTextStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: BokunSpizeColors.neutralDark,
          ),
          todayTextStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.neutralDark,
          ),
          selectedDayTextStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.neutralLight,
          ),
          selectedMonthTextStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.neutralLight,
          ),
          selectedYearTextStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.neutralLight,
          ),
          selectedDayHighlightColor: BokunSpizeColors.primary,
          daySplashColor: BokunSpizeColors.secondary,
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
          useAbbrLabelForMonthModePicker: true,
          lastMonthIcon: const Icon(
            Icons.chevron_left_rounded,
            size: 20,
            color: BokunSpizeColors.neutralDark,
          ),
          nextMonthIcon: const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: BokunSpizeColors.neutralDark,
          ),
        ),
      ),
    ),
  );
}
