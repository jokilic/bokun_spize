import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../../../main.dart';

class InsightsAddWeightSheet extends StatelessWidget {
  final DateTime currentDateTime;
  final Function(double newWeight) onSavePressed;

  const InsightsAddWeightSheet({
    required this.currentDateTime,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          ///
          /// TITLE
          ///
          const Text(
            'Unesi masu',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: BokunSpizeColors.neutralDark,
            ),
          ),
          const SizedBox(height: 20),

          // TODO: UI work here
          SizedBox(
            height: MediaQuery.paddingOf(context).bottom,
          ),
        ],
      ),
    ),
  );
}
