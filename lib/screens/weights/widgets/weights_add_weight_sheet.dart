import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../util/date_time.dart';
import '../../../widgets/calendar_sheet.dart';
import '../../../widgets/time_sheet.dart';

class WeightsAddWeightSheet extends StatefulWidget {
  final double initialWeight;
  final Function({
    required double newWeight,
    required DateTime dateTime,
  })
  onSavePressed;

  const WeightsAddWeightSheet({
    required this.initialWeight,
    required this.onSavePressed,
    required super.key,
  });

  @override
  State<WeightsAddWeightSheet> createState() => WeightsAddWeightSheetState();
}

class WeightsAddWeightSheetState extends State<WeightsAddWeightSheet> {
  static const minimumWeight = 40.0;
  static const maximumWeight = 200.0;
  static const weightStep = 0.1;
  static const rulerItemExtent = 16.0;

  var selectedDateTime = DateTime.now();

  late final ScrollController rulerController;
  late var selectedWeight = widget.initialWeight;

  int get rulerItemCount => ((maximumWeight - minimumWeight) / weightStep).round() + 1;

  int get selectedIndex => ((selectedWeight - minimumWeight) / weightStep).round();

  @override
  void initState() {
    super.initState();
    rulerController = ScrollController(
      initialScrollOffset: selectedIndex * rulerItemExtent,
    );
  }

  @override
  void dispose() {
    rulerController.dispose();
    super.dispose();
  }

  void updateSelectedWeight() {
    final index = (rulerController.offset / rulerItemExtent).round().clamp(0, rulerItemCount - 1);
    final newWeight = ((minimumWeight * 10) + index).round() / 10;

    if (newWeight.toStringAsFixed(1) == selectedWeight.toStringAsFixed(1)) {
      return;
    }

    setState(
      () => selectedWeight = newWeight,
    );
  }

  void settleRuler() {
    final targetOffset = selectedIndex * rulerItemExtent;
    if ((rulerController.offset - targetOffset).abs() < 0.5) {
      return;
    }

    rulerController.animateTo(
      targetOffset,
      duration: BokunSpizeDurations.animation,
      curve: Curves.easeOut,
    );
  }

  /// Opens [CalendarSheet] and updates the selected `date`
  Future<void> updateDateViaPicker(BuildContext context) async => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: BokunSpizeColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(listTileRadius),
    ),
    builder: (context) => CalendarSheet(
      dateValue: selectedDateTime,
      onDateChanged: (newDate) => setState(
        () => selectedDateTime = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        ),
      ),
      primaryColor: BokunSpizeColors.blue,
    ),
  );

  /// Opens [Timeheet] and updates the selected `date`
  Future<void> updateTimeViaPicker(BuildContext context) async => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: BokunSpizeColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(listTileRadius),
    ),
    builder: (context) => TimeSheet(
      dateValue: selectedDateTime,
      onDateChanged: (newDate) => setState(
        () => selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          newDate.hour,
          newDate.minute,
        ),
      ),
      primaryColor: BokunSpizeColors.blue,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final date = getDateString(
      date: selectedDateTime,
      dateFormat: 'dd.MM.yyyy.',
    );

    final time = getDateString(
      date: selectedDateTime,
      dateFormat: 'HH:mm',
      useTodayYesterdayTomorrow: false,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),

            ///
            /// TITLE
            ///
            const Text(
              'Log weight',
              style: TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: BokunSpizeColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),

            ///
            /// DATE
            ///
            Text(
              '$date, $time',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: BokunSpizeColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            ///
            /// WEIGHT
            ///
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: selectedWeight.toStringAsFixed(1),
                  ),
                  TextSpan(
                    text: ' kg',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BokunSpizeColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              style: const TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: BokunSpizeColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            ///
            /// WEIGHT PICKER
            ///
            SizedBox(
              height: 120,
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  alignment: Alignment.center,
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          updateSelectedWeight();
                        }
                        if (notification is ScrollEndNotification) {
                          settleRuler();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: rulerController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: (constraints.maxWidth - rulerItemExtent) / 2,
                        ),
                        itemExtent: rulerItemExtent,
                        itemCount: rulerItemCount,
                        itemBuilder: (context, index) => buildRulerMark(index),
                      ),
                    ),

                    IgnorePointer(
                      child: Container(
                        width: 6,
                        height: 96,
                        decoration: BoxDecoration(
                          color: BokunSpizeColors.blue,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            ///
            /// DATE & TIME
            ///
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///
                /// DATE
                ///
                ElevatedButton.icon(
                  onPressed: () => updateDateViaPicker(context),
                  icon: const PhosphorIcon(
                    PhosphorIconsBold.calendarDot,
                    color: BokunSpizeColors.black,
                    size: 18,
                  ),
                  label: Text(date),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BokunSpizeColors.grey,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    backgroundColor: BokunSpizeColors.grey,
                    foregroundColor: BokunSpizeColors.black.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(width: 16),

                ///
                /// TIME
                ///
                ElevatedButton.icon(
                  onPressed: () => updateTimeViaPicker(context),
                  icon: const PhosphorIcon(
                    PhosphorIconsBold.clock,
                    color: BokunSpizeColors.black,
                    size: 18,
                  ),
                  label: Text(time),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BokunSpizeColors.grey,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    backgroundColor: BokunSpizeColors.grey,
                    foregroundColor: BokunSpizeColors.black.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            ///
            /// SAVE BUTTON
            ///
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onSavePressed(
                  newWeight: selectedWeight,
                  dateTime: selectedDateTime,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  padding: const EdgeInsets.all(22),
                  backgroundColor: BokunSpizeColors.blue,
                  foregroundColor: BokunSpizeColors.white,
                  disabledBackgroundColor: BokunSpizeColors.blue.withValues(alpha: 0.3),
                  disabledForegroundColor: BokunSpizeColors.white,
                ),
                child: const Text('Save weight'),
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

  Widget buildRulerMark(int index) {
    final isWholeKilogram = index % 10 == 0;
    final isSelected = index == selectedIndex;
    final weight = minimumWeight + (index * weightStep);
    final color = isSelected
        ? BokunSpizeColors.blue.withValues(alpha: 0.35)
        : BokunSpizeColors.black.withValues(
            alpha: isWholeKilogram ? 0.28 : 0.14,
          );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 80,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: isWholeKilogram ? 3 : 2,
              height: isWholeKilogram ? 48 : 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          child: isWholeKilogram
              ? OverflowBox(
                  minWidth: 48,
                  maxWidth: 48,
                  child: Text(
                    weight.toStringAsFixed(0),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
