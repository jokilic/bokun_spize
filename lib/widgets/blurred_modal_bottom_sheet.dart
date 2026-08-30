import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';

/// Opens sheet from passed `builder` with blur
Future<T?> showBlurredModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  double elevation = 0,
  double blurSigma = 8,
  bool isScrollControlled = true,
  Color backgroundColor = BokunSpizeColors.white,
  Color modalBarrierColor = Colors.transparent,
  ShapeBorder shape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(listTileRadius),
    ),
  ),
}) async {
  final navigator = Navigator.of(context);
  final localizations = MaterialLocalizations.of(context);

  final result = await navigator.push(
    BlurredModalBottomSheetRoute<T>(
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      barrierLabel: localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(
        localizations.bottomSheetLabel,
      ),
      elevation: 0,
      blurSigma: blurSigma,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      modalBarrierColor: modalBarrierColor,
      shape: shape,
      builder: (context) => builder(context),
    ),
  );

  return result;
}

class BlurredModalBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  final double blurSigma;

  BlurredModalBottomSheetRoute({
    required super.capturedThemes,
    required super.barrierOnTapHint,
    required super.barrierLabel,
    required super.elevation,
    required super.isScrollControlled,
    required super.backgroundColor,
    required super.modalBarrierColor,
    required super.shape,
    required super.builder,
    required this.blurSigma,
  });

  @override
  Widget buildModalBarrier() => AnimatedBuilder(
    animation: animation!,
    child: super.buildModalBarrier(),
    builder: (context, child) {
      final animatedBlurSigma = blurSigma * barrierCurve.transform(animation!.value);

      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: animatedBlurSigma,
          sigmaY: animatedBlurSigma,
        ),
        child: child,
      );
    },
  );
}
