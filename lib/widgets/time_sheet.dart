import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';

import '../constants/colors.dart';
import '../main.dart';

class TimeSheet extends StatefulWidget {
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;

  const TimeSheet({
    required this.dateValue,
    required this.onDateChanged,
  });

  @override
  State<TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<TimeSheet> {
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
            'Odaberi vrijeme',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: BokunSpizeColors.neutralDark,
            ),
          ),
          const SizedBox(height: 20),

          ///
          /// TIME
          ///
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ScrollDateTimePicker(
              onChange: (newDateTime) => selectedDateTime = newDateTime,
              itemExtent: 64,
              style: DateTimePickerStyle(
                activeStyle: const TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: BokunSpizeColors.primary,
                ),
                inactiveStyle: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: BokunSpizeColors.neutralDark.withValues(alpha: 0.45),
                ),
                disabledStyle: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: BokunSpizeColors.neutralDark.withValues(alpha: 0.2),
                ),
              ),
              wheelOption: const DateTimePickerWheelOption(
                physics: BouncingScrollPhysics(),
              ),
              dateOption: DateTimePickerOption(
                dateFormat: DateFormat(
                  'HH:mm',
                  Localizations.localeOf(context).languageCode,
                ),
                minDate: DateTime(2020),
                maxDate: DateTime(2050),
                initialDate: selectedDateTime,
              ),
              centerWidget: DateTimePickerCenterWidget(
                builder: (context, constraints, child) => Container(
                  decoration: ShapeDecoration(
                    color: BokunSpizeColors.primary.withValues(alpha: 0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: child,
                ),
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
                padding: const EdgeInsets.all(20),
                backgroundColor: BokunSpizeColors.primary,
                foregroundColor: BokunSpizeColors.white,
                disabledBackgroundColor: BokunSpizeColors.neutralLight,
                disabledForegroundColor: BokunSpizeColors.neutralDark,
              ),
              child: const Text('Spremi'),
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
