import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';
import '../util/spacing.dart';

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
                    'Select time',
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
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),

        ///
        /// TIME
        ///
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
          sliver: SliverToBoxAdapter(
            child: Container(
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
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),

        ///
        /// SAVE BUTTON
        ///
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
          sliver: SliverToBoxAdapter(
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
                child: const Text('Confirm'),
              ),
            ),
          ),
        ),

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
