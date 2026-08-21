import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';
import '../../../util/date_time.dart';

class WalksAppBar extends StatelessWidget {
  final String? title;
  final String timeString;
  final int? currentSteps;
  final double? stepsChange;
  final DateTime? stepsChangeDateTime;

  const WalksAppBar({
    required this.title,
    required this.timeString,
    required this.currentSteps,
    required this.stepsChange,
    required this.stepsChangeDateTime,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar.large(
    backgroundColor: BokunSpizeColors.grey,
    elevation: 0,
    scrolledUnderElevation: 0,
    expandedHeight: 200,
    leadingWidth: double.infinity,
    leading: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ///
          /// AVATAR
          ///
          IconButton(
            onPressed: null,
            icon: const PhosphorIcon(
              PhosphorIconsBold.carrot,
              size: 28,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              foregroundColor: BokunSpizeColors.secondary,
              disabledBackgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
              disabledForegroundColor: BokunSpizeColors.secondary,
            ),
          ),
          const SizedBox(width: 14),

          ///
          /// APP TITLE
          ///
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 24,
                height: 1.2,
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
                color: BokunSpizeColors.primary,
              ),
            ),
        ],
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: currentSteps != null
          ? FadingFlexibleTitle(
              timeString: timeString,
              currentSteps: currentSteps,
              stepsChange: stepsChange,
              stepsChangeDateTime: stepsChangeDateTime,
            )
          : null,
    ),
  );
}

class FadingFlexibleTitle extends StatelessWidget {
  final String timeString;
  final int? currentSteps;
  final double? stepsChange;
  final DateTime? stepsChangeDateTime;

  const FadingFlexibleTitle({
    required this.timeString,
    required this.currentSteps,
    required this.stepsChange,
    required this.stepsChangeDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    if (settings == null) {
      return const SizedBox.shrink();
    }

    final delta = settings.maxExtent - settings.minExtent;
    final t = ((settings.currentExtent - settings.minExtent) / delta).clamp(0.0, 1.0);
    final opacity = Curves.easeIn.transform(t);

    final dy = Tween<double>(begin: 8, end: 0).transform(t);

    final changeColor = stepsChange != null
        ? switch (stepsChange!) {
            > 0 => BokunSpizeColors.primary,
            < 0 => BokunSpizeColors.tertiary,
            _ => BokunSpizeColors.black,
          }
        : BokunSpizeColors.black;
    final stepsChangeDateString = stepsChangeDateTime != null
        ? getDateString(
            date: stepsChangeDateTime!,
            dateFormat: 'MMM d',
          ).toUpperCase()
        : null;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// CURRENT STEPS
            ///
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeString.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: currentSteps != null ? NumberFormat.decimalPattern('en').format(currentSteps) : '--',
                      style: const TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 1.5,
                        color: BokunSpizeColors.primary,
                      ),
                      children: [
                        const WidgetSpan(
                          child: SizedBox(width: 4),
                        ),
                        TextSpan(
                          text: 'steps',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 1.5,
                            color: BokunSpizeColors.black.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            ///
            /// LATEST COMPLETED DAY CHANGE AGAINST ITS RECENT AVERAGE
            ///
            if (stepsChange != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PhosphorIcon(
                        stepsChange! > 0 ? PhosphorIconsBold.trendUp : PhosphorIconsBold.trendDown,
                        color: changeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${stepsChange! > 0 ? '+' : ''}${NumberFormat.decimalPattern('en').format(stepsChange!.round())}',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: changeColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (stepsChangeDateString != null)
                    Text(
                      '$stepsChangeDateString vs recent avg',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        color: BokunSpizeColors.black,
                      ),
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
