import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../models/meal/meal.dart';
import '../../services/firebase_service.dart';

class HomeController extends ValueNotifier<DateTime> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  HomeController({
    required this.firebase,
  }) : super(
         DateUtils.dateOnly(
           DateTime.now(),
         ),
       );

  ///
  /// INIT
  ///

  void init() {
    mealsStream = firebase.listenToMeals(date: value);
  }

  ///
  /// VARIABLES
  ///

  late Stream<List<Meal>?> mealsStream;

  ///
  /// METHODS
  ///

  /// Updates the active date and switches the meal listener to that day
  @override
  set value(DateTime newValue) {
    final selectedDate = DateUtils.dateOnly(newValue);

    if (DateUtils.isSameDay(super.value, selectedDate)) {
      return;
    }

    mealsStream = firebase.listenToMeals(date: selectedDate);
    super.value = selectedDate;
  }

  /// Opens the calendar and updates the selected date when confirmed
  Future<void> updateDateViaPicker(BuildContext context) async => showCalendarDatePicker2Dialog(
    context: context,
    value: [value],
    onValueChanged: (newValue) {
      final chosenDate = newValue.firstOrNull;

      if (chosenDate != null && !DateUtils.isSameDay(value, chosenDate)) {
        value = chosenDate;
        Navigator.of(context).pop();
      }
    },
    config: CalendarDatePicker2WithActionButtonsConfig(
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
      dayBuilder:
          ({
            required date,
            textStyle,
            decoration,
            isSelected,
            isDisabled,
            isToday,
          }) {
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
      cancelButton: const Text(
        'CANCEL',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: BokunSpizeColors.neutralDark,
        ),
      ),
      okButton: const Text(
        'GO',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: BokunSpizeColors.neutralDark,
        ),
      ),
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
    borderRadius: BorderRadius.circular(8),
    dialogBackgroundColor: BokunSpizeColors.neutralLight,
    dialogSize: const Size(325, 410),
  );
}
