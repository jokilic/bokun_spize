import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../models/steps_with_date/steps_with_date.dart';
import '../../../util/date_time.dart';
import '../../../util/steps_with_date.dart';

class WalksGraph extends StatelessWidget {
  final List<StepsWithDate> stepsWithDate;
  final int calendarDays;

  const WalksGraph({
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(listTileRadius),
                color: BokunSpizeColors.white.withValues(alpha: 0.5),
              ),
              child: visibleStepsWithDate.isEmpty
                  ? Center(
                      child: Text(
                        'No step data for the graph',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BokunSpizeColors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: buildLineChart(
                        stepsWithDate: visibleStepsWithDate,
                        calendarDays: calendarDays,
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
      BokunSpizeColors.bordeaux,
      BokunSpizeColors.bordeaux.withValues(alpha: 0.25),
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
            getTooltipColor: (touchedSpot) => BokunSpizeColors.bordeaux,
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
                    color: BokunSpizeColors.white.withValues(alpha: 0.7),
                  ),
                  children: [
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: '$steps steps',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: BokunSpizeColors.white,
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
                    color: BokunSpizeColors.bordeaux.withValues(alpha: 0.25),
                    strokeWidth: 3.5,
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4.5,
                      color: BokunSpizeColors.bordeaux,
                      strokeWidth: 6,
                      strokeColor: BokunSpizeColors.bordeaux.withValues(alpha: 0.25),
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
                BokunSpizeColors.bordeaux,
                lineEndColor,
              ],
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  BokunSpizeColors.bordeaux.withValues(alpha: 0.16),
                  BokunSpizeColors.bordeaux.withValues(alpha: 0),
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
                color: BokunSpizeColors.bordeaux,
                strokeWidth: 6,
                strokeColor: BokunSpizeColors.bordeaux.withValues(alpha: 0.25),
              ),
            ),
          ),
        ],
      ),
      duration: BokunSpizeDurations.animation,
      curve: Curves.easeOutCubic,
    );
  }

  Widget buildBottomTitle({
    required double value,
    required TitleMeta meta,
    required DateTime firstDateTime,
    required DateTime lastDateTime,
    required bool hasSinglePosition,
    required bool isSingleDay,
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
          color: BokunSpizeColors.black.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
