import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/durations.dart';
import '../theme/extensions.dart';

class BokunSpizeLittleButton extends StatelessWidget {
  final Future Function() onPressed;
  final PhosphorIconData icon;
  final Color backgroundColor;
  final Color? duotoneSecondaryColor;

  const BokunSpizeLittleButton({
    required this.onPressed,
    required this.icon,
    this.backgroundColor = Colors.transparent,
    this.duotoneSecondaryColor,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.scaffoldBackground,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onPressed,
      highlightColor: context.colors.listTileBackground,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        duration: BokunSpizeDurations.animation,
        curve: Curves.easeIn,
        padding: const EdgeInsets.all(8),
        child: PhosphorIcon(
          icon,
          color: context.colors.text,
          duotoneSecondaryColor: duotoneSecondaryColor ?? context.colors.buttonPrimary,
          size: 16,
        ),
      ),
    ),
  );
}
