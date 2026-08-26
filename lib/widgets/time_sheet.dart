import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';

class TimeSheet extends StatefulWidget {
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;
  final Color primaryColor;

  const TimeSheet({
    required this.dateValue,
    required this.onDateChanged,
    required this.primaryColor,
  });

  @override
  State<TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<TimeSheet> {
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
                  'Select time',
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
                activeStyle: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: widget.primaryColor,
                ),
                inactiveStyle: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: BokunSpizeColors.black.withValues(alpha: 0.45),
                ),
                disabledStyle: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: BokunSpizeColors.black.withValues(alpha: 0.2),
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
                    color: widget.primaryColor.withValues(alpha: 0.25),
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
