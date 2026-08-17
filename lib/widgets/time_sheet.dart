import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';

import '../constants/colors.dart';
import '../main.dart';

class TimeSheet extends StatelessWidget {
  final DateTime dateValue;
  final Function(DateTime newDate) onDateChanged;

  const TimeSheet({
    required this.dateValue,
    required this.onDateChanged,
  });

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
              border: Border.all(
                color: BokunSpizeColors.neutralDark,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ScrollDateTimePicker(
              onChange: onDateChanged,
              itemExtent: 64,
              style: DateTimePickerStyle(
                activeStyle: const TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: BokunSpizeColors.neutralDark,
                ),
                inactiveStyle: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: BokunSpizeColors.neutralDark.withValues(alpha: 0.45),
                ),
                disabledStyle: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
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
                minDate: DateTime(2010),
                maxDate: DateTime(2040, 12, 31, 23, 59),
                initialDate: dateValue,
              ),
              centerWidget: DateTimePickerCenterWidget(
                builder: (context, constraints, child) => Container(
                  decoration: const ShapeDecoration(
                    color: BokunSpizeColors.neutralLight,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: BokunSpizeColors.neutralDark,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: child,
                ),
              ),
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
