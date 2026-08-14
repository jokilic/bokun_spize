import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

import '../../../constants/colors.dart';
import '../../../main.dart';
import '../../../models/weight_track/weight_track.dart';

class InsightsListTile extends StatelessWidget {
  final Future<void> Function() onDeletePressed;
  final WeightTrack weightTrack;

  const InsightsListTile({
    required this.onDeletePressed,
    required this.weightTrack,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: SwipeActionCell(
        key: ValueKey(weightTrack.id),
        backgroundColor: BokunSpizeColors.neutralLight,
        openAnimationDuration: 175,
        closeAnimationDuration: 175,
        deleteAnimationDuration: 175,
        openAnimationCurve: Curves.easeIn,
        closeAnimationCurve: Curves.easeIn,
        leadingActions: [
          SwipeAction(
            onTap: (handler) async {
              await handler(true);
              await onDeletePressed();
            },
            color: BokunSpizeColors.tertiary,
            backgroundRadius: listTileRadius,
            icon: const Icon(
              Icons.delete_rounded,
              color: BokunSpizeColors.white,
              size: 28,
            ),
          ),
        ],
        child: Material(
          color: BokunSpizeColors.white,
          borderRadius: BorderRadius.circular(listTileRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(listTileRadius),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ///
                /// ICON
                ///
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: BokunSpizeColors.neutralLight,
                    child: const Icon(
                      Icons.monitor_weight_rounded,
                      size: 24,
                      color: BokunSpizeColors.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                ///
                /// TEXT
                ///
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      /// TITLE
                      ///
                      Text(
                        'Ponedjeljak, 13. Kol',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: BokunSpizeColors.neutralDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),

                      ///
                      /// SUBTITLE
                      ///
                      Text(
                        '08:15',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: BokunSpizeColors.neutralDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ///
                    /// WEIGHT
                    ///
                    Text.rich(
                      TextSpan(
                        text: weightTrack.weight.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: BokunSpizeColors.neutralDark,
                        ),
                        children: [
                          const WidgetSpan(
                            child: SizedBox(width: 4),
                          ),
                          TextSpan(
                            text: 'kg',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              letterSpacing: 1.5,
                              color: BokunSpizeColors.neutralDark.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    ///
                    /// CHANGE
                    ///
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 14,
                          color: BokunSpizeColors.primary,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '0.8kg',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: BokunSpizeColors.primary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
