import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/extensions.dart';
import '../../util/color.dart';

class BokunSpizeListTileNutritionalValue extends StatelessWidget {
  final String? valueText;
  final String bottomText;
  final Color backgroundColor;
  final bool isLoading;

  const BokunSpizeListTileNutritionalValue({
    required this.valueText,
    required this.bottomText,
    required this.backgroundColor,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 48,
        width: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: Text.rich(
          TextSpan(
            text: valueText ?? '--',
            children: [
              if (valueText != null)
                TextSpan(
                  text: 'g',
                  style: context.textStyles.homeMealTime.copyWith(
                    color: getWhiteOrBlackColor(
                      backgroundColor: backgroundColor,
                      whiteColor: BokunSpizeColors.whiteBackground,
                      blackColor: BokunSpizeColors.black,
                    ),
                  ),
                ),
            ],
          ),
          style: context.textStyles.homeMealKcal.copyWith(
            color: getWhiteOrBlackColor(
              backgroundColor: backgroundColor,
              whiteColor: BokunSpizeColors.whiteBackground,
              blackColor: BokunSpizeColors.black,
            ),
          ),
          maxLines: isLoading ? null : 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        bottomText,
        style: context.textStyles.homeMealTime,
        maxLines: isLoading ? null : 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    ],
  );
}
