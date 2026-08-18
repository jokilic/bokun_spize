import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../../../constants/durations.dart';
import '../../../main.dart';
import '../../../models/weight_track/weight_track.dart';
import '../../../util/weight_track.dart';

class InsightsGraph extends StatelessWidget {
  final List<WeightTrack> weightTracks;
  final int weightChangeWithinDays;

  const InsightsGraph({
    required this.weightTracks,
    required this.weightChangeWithinDays,
  });

  @override
  Widget build(BuildContext context) {
    final visibleWeightTracks = getWeightTracksForGraph(
      weightTracks: weightTracks,
      weightChangeWithinDays: weightChangeWithinDays,
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      sliver: SliverToBoxAdapter(
        child: AspectRatio(
          aspectRatio: 1.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(listTileRadius),
            child: ColoredBox(
              color: BokunSpizeColors.white,
              child: visibleWeightTracks.isEmpty
                  ? Center(
                      child: Text(
                        'Unesi težinu za prikaz grafa',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BokunSpizeColors.neutralDark.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: buildLineChart(
                        weightTracks: visibleWeightTracks,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLineChart({
    required List<WeightTrack> weightTracks,
  }) {
    final firstDateTime = weightTracks.first.dateTime;
    final lastDateTime = weightTracks.last.dateTime;

    final timeSpan = lastDateTime.difference(firstDateTime);
    final timeSpanInDays = timeSpan.inMilliseconds / Duration.millisecondsPerDay;

    final hasSinglePosition = timeSpanInDays <= 0;
    final isSingleDay = DateUtils.isSameDay(firstDateTime, lastDateTime);

    /// The X values represent elapsed days so entries keep their real spacing
    final spots = weightTracks.map((weightTrack) {
      final elapsedTime = weightTrack.dateTime.difference(firstDateTime);
      final elapsedDays = elapsedTime.inMilliseconds / Duration.millisecondsPerDay;

      return FlSpot(
        hasSinglePosition ? 0 : elapsedDays,
        weightTrack.weight,
      );
    }).toList();

    final weights = weightTracks.map(
      (weightTrack) => weightTrack.weight,
    );

    final minimumWeight = weights.reduce((a, b) => a < b ? a : b);
    final maximumWeight = weights.reduce((a, b) => a > b ? a : b);

    final weightRange = maximumWeight - minimumWeight;
    final weightPadding = weightRange > 2 ? weightRange * 0.45 : 1.0;

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

    final lineEndColor = Color.lerp(
      BokunSpizeColors.primary,
      BokunSpizeColors.primary.withValues(alpha: 0.25),
      0.75,
    )!;

    return LineChart(
      LineChartData(
        minX: chartMinX,
        maxX: chartMaxX,
        minY: minimumWeight - weightPadding,
        maxY: maximumWeight + weightPadding,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
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
            spots: spots,
            isCurved: spots.length > 2,
            preventCurveOverShooting: true,
            preventCurveOvershootingThreshold: weightRange > 0 ? weightRange : 1,
            isStrokeCapRound: true,
            isStrokeJoinRound: true,
            barWidth: 3.5,
            gradientArea: LineChartGradientArea.wholeChart,
            gradient: LinearGradient(
              colors: [
                BokunSpizeColors.primary,
                lineEndColor,
              ],
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  BokunSpizeColors.primary.withValues(alpha: 0.16),
                  BokunSpizeColors.primary.withValues(alpha: 0),
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
                color: BokunSpizeColors.primary,
                strokeWidth: 6,
                strokeColor: BokunSpizeColors.primary.withValues(alpha: 0.25),
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
    final label =
        DateUtils.isSameDay(
          dateTime,
          DateTime.now(),
        )
        ? 'Today'.toUpperCase()
        : DateFormat(
            'MMM dd',
            'en',
          ).format(dateTime).toUpperCase();

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
          color: BokunSpizeColors.neutralDark.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
