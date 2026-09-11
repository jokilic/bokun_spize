import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/steps_with_date/steps_with_date.dart';
import '../../../theme/extensions.dart';
import '../../../util/date_time.dart';
import '../../../util/steps_with_date.dart';

class WalksGraph extends StatelessWidget {
  final bool isLoading;
  final Function(int newDays) onSelectedDays;
  final List<int> dayEntries;
  final List<StepsWithDate> stepsWithDate;
  final int calendarDays;

  const WalksGraph({
    required this.isLoading,
    required this.onSelectedDays,
    required this.dayEntries,
    required this.stepsWithDate,
    required this.calendarDays,
  });

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal,
          vertical: 12,
        ),
        sliver: SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ///
              /// GRAPH TITLE LOADING
              ///
              if (isLoading)
                Animate(
                  onPlay: (controller) => controller.loop(
                    reverse: true,
                    min: 0.6,
                  ),
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.shimmer,
                      curve: Curves.easeIn,
                    ),
                  ],
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: context.colors.listTileBackground.withValues(alpha: 0.5),
                    ),
                    height: 30,
                    width: 144,
                  ),
                )
              ///
              /// GRAPH TITLE
              ///
              else
                Expanded(
                  child: Text(
                    'Recent progress',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: context.colors.text,
                    ),
                  ),
                ),

              ///
              /// GRAPH BUTTON LOADING
              ///
              if (isLoading)
                Animate(
                  onPlay: (controller) => controller.loop(
                    reverse: true,
                    min: 0.6,
                  ),
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.shimmer,
                      curve: Curves.easeIn,
                    ),
                  ],
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: context.colors.listTileBackground.withValues(alpha: 0.5),
                    ),
                    height: 30,
                    width: 104,
                  ),
                )
              ///
              /// GRAPH BUTTON
              ///
              else
                PopupMenuButton<int>(
                  menuPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 8),
                  elevation: 0,
                  color: context.colors.listTileBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: onSelectedDays,
                  itemBuilder: (context) => dayEntries
                      .map(
                        (calendarDays) => PopupMenuItem<int>(
                          value: calendarDays,
                          child: Text(
                            '$calendarDays days',
                            style: TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.colors.text,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: context.colors.listTileBackground.withValues(alpha: 0.5),
                      shape: const StadiumBorder(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 4, 16, 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(
                            PhosphorIconsBold.caretDown,
                            color: context.colors.text,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$calendarDays days',
                            style: TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 16,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                              color: context.colors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      ///
      /// GRAPH
      ///
      WalksGraphWidget(
        isLoading: isLoading,
        stepsWithDate: stepsWithDate,
        calendarDays: calendarDays,
      ),
      const SliverToBoxAdapter(
        child: SizedBox(height: 20),
      ),
    ],
  );
}

class WalksGraphWidget extends StatelessWidget {
  final bool isLoading;
  final List<StepsWithDate> stepsWithDate;
  final int calendarDays;

  const WalksGraphWidget({
    required this.isLoading,
    required this.stepsWithDate,
    required this.calendarDays,
  });

  @override
  Widget build(BuildContext context) {
    final visibleStepsWithDate = getStepsWithDateForGraph(
      stepsWithDate: stepsWithDate,
      calendarDays: calendarDays,
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: marginHorizontal,
        vertical: 8,
      ),
      sliver: SliverToBoxAdapter(
        child: AspectRatio(
          aspectRatio: 1.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(listTileRadius),
            child: Animate(
              onPlay: (controller) {
                if (isLoading) {
                  controller.loop(
                    reverse: true,
                    min: 0.6,
                  );
                }
              },
              effects: [
                if (isLoading)
                  const FadeEffect(
                    duration: BokunSpizeDurations.shimmer,
                    curve: Curves.easeIn,
                  ),
              ],
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(listTileRadius),
                  color: context.colors.listTileBackground.withValues(alpha: 0.5),
                ),
                child: isLoading
                    ? const SizedBox.shrink()
                    : visibleStepsWithDate.isEmpty
                    ? Center(
                        child: Text(
                          'No step data for the graph',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.colors.text.withValues(alpha: 0.4),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: buildLineChart(
                          stepsWithDate: visibleStepsWithDate,
                          calendarDays: calendarDays,
                          context: context,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLineChart({
    required List<StepsWithDate> stepsWithDate,
    required int calendarDays,
    required BuildContext context,
  }) {
    final lastDateTime = stepsWithDate.last.dateTime;
    final firstDateTime = lastDateTime.subtract(
      Duration(days: calendarDays),
    );

    final timeSpan = lastDateTime.difference(firstDateTime);
    final timeSpanInDays = timeSpan.inMilliseconds / Duration.millisecondsPerDay;

    final hasSinglePosition = timeSpanInDays <= 0;
    final isSingleDay = DateUtils.isSameDay(firstDateTime, lastDateTime);

    /// X values use elapsed days to retain gaps between calendar dates.
    final spots = stepsWithDate.map((stepWithDate) {
      final elapsedTime = stepWithDate.dateTime.difference(firstDateTime);
      final elapsedDays = elapsedTime.inMilliseconds / Duration.millisecondsPerDay;

      return FlSpot(
        hasSinglePosition ? 0 : elapsedDays.clamp(0, timeSpanInDays).toDouble(),
        stepWithDate.steps.toDouble(),
      );
    }).toList();

    final stepTotals = stepsWithDate.map(
      (stepWithDate) => stepWithDate.steps,
    );
    final minimumSteps = stepTotals.reduce((a, b) => a < b ? a : b).toDouble();
    final maximumSteps = stepTotals.reduce((a, b) => a > b ? a : b).toDouble();
    final stepsRange = maximumSteps - minimumSteps;
    final stepsPadding = stepsRange > 1000 ? stepsRange * 0.25 : 500.0;

    final firstCalendarDate = DateTime(
      firstDateTime.year,
      firstDateTime.month,
      firstDateTime.day,
    );
    final lastCalendarDate = DateTime(
      lastDateTime.year,
      lastDateTime.month,
      lastDateTime.day,
    );
    final calendarDaySpan = lastCalendarDate.difference(firstCalendarDate).inDays;

    final titleCount = switch (calendarDaySpan) {
      >= 3 => 4,
      2 => 3,
      1 => 2,
      _ => 1,
    };
    final titleInterval = titleCount > 1 ? timeSpanInDays / (titleCount - 1) : 1.0;

    final chartMinX = hasSinglePosition ? -1.0 : 0.0;
    final chartMaxX = hasSinglePosition ? 1.0 : timeSpanInDays;
    final chartMinY = (minimumSteps - stepsPadding).clamp(0.0, double.infinity).toDouble();

    final lineEndColor = Color.lerp(
      context.colors.fat,
      context.colors.fat.withValues(alpha: 0.25),
      0.75,
    )!;

    return LineChart(
      LineChartData(
        minX: chartMinX,
        maxX: chartMaxX,
        minY: chartMinY,
        maxY: maximumSteps + stepsPadding,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchSpotThreshold: double.infinity,
          touchTooltipData: LineTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(100),
            tooltipMargin: 12,
            maxContentWidth: 160,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (touchedSpot) => context.colors.fat,
            getTooltipItems: (touchedSpots) => touchedSpots.map(
              (touchedSpot) {
                final stepWithDate = stepsWithDate[touchedSpot.spotIndex];

                final date = getDateString(
                  date: stepWithDate.dateTime,
                  dateFormat: 'MMM d, yyyy',
                  useTodayYesterdayTomorrow: false,
                );

                final steps = stepWithDate.steps.round().toStringAsFixed(0);

                return LineTooltipItem(
                  date,
                  TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: context.colors.buttonText.withValues(alpha: 0.7),
                  ),
                  children: [
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: '$steps steps',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: context.colors.buttonText,
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
          getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes
              .map(
                (spotIndex) => TouchedSpotIndicatorData(
                  FlLine(
                    color: context.colors.fat.withValues(alpha: 0.25),
                    strokeWidth: 3.5,
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4.5,
                      color: context.colors.fat,
                      strokeWidth: 6,
                      strokeColor: context.colors.fat.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: titleInterval,
              getTitlesWidget: (value, meta) => buildBottomTitle(
                value: value,
                meta: meta,
                firstDateTime: firstDateTime,
                lastDateTime: lastDateTime,
                hasSinglePosition: hasSinglePosition,
                isSingleDay: isSingleDay,
                labelColor: context.colors.text,
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            curveSmoothness: 0.15,
            spots: spots,
            isCurved: spots.length > 2,
            preventCurveOverShooting: true,
            preventCurveOvershootingThreshold: stepsRange > 0 ? stepsRange : 1,
            isStrokeCapRound: true,
            isStrokeJoinRound: true,
            barWidth: 3.5,
            gradientArea: LineChartGradientArea.wholeChart,
            gradient: LinearGradient(
              colors: [
                context.colors.fat,
                lineEndColor,
              ],
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colors.fat.withValues(alpha: 0.16),
                  context.colors.fat.withValues(alpha: 0),
                ],
              ),
            ),
            dotData: FlDotData(
              checkToShowDot: (spot, barData) => identical(
                spot,
                barData.spots.last,
              ),
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4.5,
                color: context.colors.fat,
                strokeWidth: 6,
                strokeColor: context.colors.fat.withValues(alpha: 0.25),
              ),
            ),
          ),
        ],
      ),
      duration: BokunSpizeDurations.animation,
      curve: Curves.easeIn,
    );
  }

  Widget buildBottomTitle({
    required double value,
    required TitleMeta meta,
    required DateTime firstDateTime,
    required DateTime lastDateTime,
    required bool hasSinglePosition,
    required bool isSingleDay,
    required Color labelColor,
  }) {
    final isSinglePositionTitle = hasSinglePosition && value.abs() < 0.001;
    final isLastTitle = (value - meta.max).abs() < 0.001;

    if (hasSinglePosition && !isSinglePositionTitle || !hasSinglePosition && isSingleDay && !isLastTitle) {
      return const SizedBox.shrink();
    }

    final dateTime = hasSinglePosition || isLastTitle
        ? lastDateTime
        : firstDateTime.add(
            Duration(
              milliseconds: (value * Duration.millisecondsPerDay).round(),
            ),
          );
    final label = getDateString(
      date: dateTime,
      dateFormat: 'MMM d',
    ).toUpperCase();

    return SideTitleWidget(
      meta: meta,
      fitInside: SideTitleFitInsideData.fromTitleMeta(
        meta,
        distanceFromEdge: 2,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Epilogue',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: labelColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
