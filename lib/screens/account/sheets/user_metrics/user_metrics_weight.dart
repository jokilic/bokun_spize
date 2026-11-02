import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../constants/durations.dart';
import '../../../../theme/extensions.dart';

class UserMetricsWeight extends StatefulWidget {
  final double initialWeight;
  final Function(double newWeight) onWeightChanged;
  final Color primaryColor;

  const UserMetricsWeight({
    required this.initialWeight,
    required this.onWeightChanged,
    required this.primaryColor,
    super.key,
  });

  @override
  State<UserMetricsWeight> createState() => UserMetricsWeightState();
}

class UserMetricsWeightState extends State<UserMetricsWeight> {
  static const minimumWeight = 40.0;
  static const maximumWeight = 200.0;
  static const weightStep = 0.1;
  static const rulerItemExtent = 8.0;

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
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      children: [
        ///
        /// HEIGHT
        ///
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: selectedWeight.toStringAsFixed(1),
              ),
              const WidgetSpan(
                child: SizedBox(width: 4),
              ),
              TextSpan(
                text: 'kilogram'.tr(),
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.text.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          style: TextStyle(
            fontFamily: 'Epilogue',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: context.colors.text,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        ///
        /// HEIGHT PICKER
        ///
        SizedBox(
          height: 56,
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
                  child: Transform.translate(
                    offset: const Offset(0, -8),
                    child: Container(
                      width: 6,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.primaryColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  /// Builds a major or minor ruler mark for the supplied height index
  Widget buildRulerMark(int index) {
    final isWholeKilogram = index % 10 == 0;
    final isSelected = index == selectedIndex;
    final weight = minimumWeight + (index * weightStep);
    final color = isSelected
        ? widget.primaryColor
        : context.colors.text.withValues(
            alpha: isWholeKilogram ? 0.75 : 0.5,
          );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: isWholeKilogram ? 3 : 2,
              height: isWholeKilogram ? 18 : 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 16,
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
