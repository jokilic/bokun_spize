import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../../../constants/durations.dart';
import '../../../main.dart';

class InsightsAddWeightSheet extends StatefulWidget {
  final DateTime currentDateTime;
  final double initialWeight;
  final Function(double newWeight) onSavePressed;

  const InsightsAddWeightSheet({
    required this.currentDateTime,
    required this.initialWeight,
    required this.onSavePressed,
  });

  @override
  State<InsightsAddWeightSheet> createState() => InsightsAddWeightSheetState();
}

class InsightsAddWeightSheetState extends State<InsightsAddWeightSheet> {
  static const minimumWeight = 40.0;
  static const maximumWeight = 200.0;
  static const weightStep = 0.1;
  static const rulerItemExtent = 40.0;

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

  String formattedDateTime() {
    final date = DateUtils.isSameDay(widget.currentDateTime, DateTime.now()) ? 'Danas' : DateFormat('dd.MM.yyyy.').format(widget.currentDateTime);
    final time = DateFormat('HH:mm').format(widget.currentDateTime);
    return '$date, $time';
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
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
            'Unesi masu',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: BokunSpizeColors.neutralDark,
            ),
          ),
          const SizedBox(height: 2),

          ///
          /// DATE
          ///
          Text(
            formattedDateTime(),
            style: const TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: BokunSpizeColors.neutralDark,
            ),
          ),
          const SizedBox(height: 64),

          ///
          /// WEIGHT
          ///
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: selectedWeight.toStringAsFixed(1),
                ),
                const TextSpan(
                  text: ' kg',
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: BokunSpizeColors.neutralDark,
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: BokunSpizeColors.neutralDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

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
                        color: BokunSpizeColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 66,
            child: ElevatedButton(
              onPressed: () => widget.onSavePressed(selectedWeight),
              style: ElevatedButton.styleFrom(
                elevation: 8,
                shadowColor: BokunSpizeColors.neutralDark.withValues(alpha: 0.2),
                backgroundColor: BokunSpizeColors.primary,
                foregroundColor: BokunSpizeColors.white,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Spremi masu',
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget buildRulerMark(int index) {
    final isWholeKilogram = index % 10 == 0;
    final isHalfKilogram = index % 5 == 0;
    final isSelected = index == selectedIndex;
    final weight = minimumWeight + (index * weightStep);
    final color = isSelected
        ? BokunSpizeColors.primary.withValues(alpha: 0.35)
        : BokunSpizeColors.neutralDark.withValues(
            alpha: isWholeKilogram ? 0.28 : 0.14,
          );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: isWholeKilogram ? 2.5 : 2,
          height: isWholeKilogram
              ? 34
              : isHalfKilogram
              ? 25
              : 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          child: isHalfKilogram
              ? Text(
                  weight.toStringAsFixed(isWholeKilogram ? 0 : 1),
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
