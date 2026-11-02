import 'package:flutter/material.dart';

import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';

class UserMetricsHeight extends StatefulWidget {
  final double initialHeight;
  final Function(double newHeight) onHeightChanged;

  const UserMetricsHeight({
    required this.initialHeight,
    required this.onHeightChanged,
    super.key,
  });

  @override
  State<UserMetricsHeight> createState() => UserMetricsHeightState();
}

class UserMetricsHeightState extends State<UserMetricsHeight> {
  static const minimumHeight = 100.0;
  static const maximumHeight = 225.0;
  static const heightStep = 1.0;
  static const rulerItemExtent = 16.0;

  late final ScrollController rulerController;
  late var selectedHeight = widget.initialHeight;

  int get rulerItemCount => ((maximumHeight - minimumHeight) / heightStep).round() + 1;

  int get selectedIndex => ((selectedHeight - minimumHeight) / heightStep).round();

  @override
  void initState() {
    super.initState();

    selectedHeight = normalizedHeight(
      widget.initialHeight,
    );

    rulerController = ScrollController(
      initialScrollOffset: selectedIndex * rulerItemExtent,
    );
  }

  @override
  void dispose() {
    rulerController.dispose();
    super.dispose();
  }

  double normalizedHeight(double height) {
    final clampedHeight = height.clamp(
      minimumHeight,
      maximumHeight,
    );
    final stepIndex = ((clampedHeight - minimumHeight) / heightStep).round();

    return minimumHeight + (stepIndex * heightStep);
  }

  void updateSelectedHeight() {
    final index = (rulerController.offset / rulerItemExtent).round().clamp(
      0,
      rulerItemCount - 1,
    );

    final newHeight = minimumHeight + (index * heightStep);

    if (newHeight == selectedHeight) {
      return;
    }

    setState(
      () => selectedHeight = newHeight,
    );

    widget.onHeightChanged(newHeight);
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
  Widget build(BuildContext context) => Column(
    children: [
      ///
      /// HEIGHT
      ///
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: selectedHeight.toStringAsFixed(0),
            ),
            const WidgetSpan(
              child: SizedBox(width: 4),
            ),
            TextSpan(
              text: 'cm',
              style: TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.colors.text.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        style: TextStyle(
          fontFamily: 'Epilogue',
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: context.colors.text,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),

      ///
      /// HEIGHT PICKER
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
                    updateSelectedHeight();
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
                    color: context.colors.protein,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  /// Builds a major or minor ruler mark for the supplied height index
  Widget buildRulerMark(int index) {
    final isMajorMark = index % 10 == 0;
    final isSelected = index == selectedIndex;
    final height = minimumHeight + (index * heightStep);
    final color = isSelected
        ? context.colors.protein.withValues(alpha: 0.5)
        : context.colors.text.withValues(
            alpha: isMajorMark ? 0.75 : 0.5,
          );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 80,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: isMajorMark ? 3 : 2,
              height: isMajorMark ? 48 : 16,
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
          child: isMajorMark
              ? OverflowBox(
                  minWidth: 48,
                  maxWidth: 48,
                  child: Text(
                    height.toStringAsFixed(0),
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
