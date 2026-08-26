import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';

class CalendarSheet extends StatefulWidget {
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;
  final Color primaryColor;

  const CalendarSheet({
    required this.dateValue,
    required this.onDateChanged,
    required this.primaryColor,
  });

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  late var selectedDateTime = widget.dateValue;

  // TODO: Use CustomScrollView

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    letterSpacing: 0.6,
                    color: BokunSpizeColors.black,
                  ),
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
                  disabledBackgroundColor: BokunSpizeColors.white,
                  disabledForegroundColor: BokunSpizeColors.black,
                ),
              ),
            ],
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
                backgroundColor: widget.primaryColor,
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
