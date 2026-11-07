import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../constants/durations.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/height.dart';
import '../../../../widgets/animated_digit_widget.dart';

class UserMetricsHeight extends StatefulWidget {
  final double initialHeight;
  final Function(double newHeight) onHeightChanged;
  final Color primaryColor;

  const UserMetricsHeight({
    required this.initialHeight,
    required this.onHeightChanged,
    required this.primaryColor,
    super.key,
  });

  @override
  State<UserMetricsHeight> createState() => UserMetricsHeightState();
}

class UserMetricsHeightState extends State<UserMetricsHeight> {
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
                text: selectedHeight.toStringAsFixed(0),
              ),
              const WidgetSpan(
                child: SizedBox(width: 4),
              ),
              TextSpan(
                text: 'centimeter'.tr(),
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
    final isMajorMark = index % 10 == 0;
    final isSelected = index == selectedIndex;
    final height = minimumHeight + (index * heightStep);
    final color = isSelected
        ? widget.primaryColor
        : context.colors.text.withValues(
            alpha: isMajorMark ? 0.75 : 0.5,
          );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: isMajorMark ? 3 : 2,
              height: isMajorMark ? 18 : 12,
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
