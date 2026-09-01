import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/durations.dart';

class WalksListTileLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: marginHorizontal,
      vertical: 8,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(listTileRadius),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(listTileRadius),
          highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(listTileRadius),
              color: BokunSpizeColors.white.withValues(alpha: 0.5),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ///
                /// LOADING IMAGE
                ///
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
                      borderRadius: BorderRadius.circular(100),
                      color: BokunSpizeColors.bordeaux.withValues(alpha: 0.5),
                    ),
                    height: listTileIconRadius,
                    width: listTileIconRadius,
                  ),
                ),
                const SizedBox(width: 20),

                ///
                /// TEXT
                ///
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      /// LOADING TITLE
                      ///
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
                            color: BokunSpizeColors.grey.withValues(alpha: 0.5),
                          ),
                          height: 20,
                          width: 112,
                        ),
                      ),
                      const SizedBox(height: 2),

                      ///
                      /// LOADING SUBTITLE
                      ///
                      const SizedBox(height: 8),
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
                            color: BokunSpizeColors.grey.withValues(alpha: 0.5),
                          ),
                          height: 12,
                          width: 56,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                ///
                /// CALORIES
                ///
                Column(
                  children: [
                    ///
                    /// CALORIES VALUE
                    ///
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
                          color: BokunSpizeColors.grey.withValues(alpha: 0.5),
                        ),
                        height: 28,
                        width: 48,
                      ),
                    ),

                    ///
                    /// CALORIES UNIT
                    ///
                    const SizedBox(height: 8),
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
                          color: BokunSpizeColors.grey.withValues(alpha: 0.5),
                        ),
                        height: 12,
                        width: 32,
                      ),
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
