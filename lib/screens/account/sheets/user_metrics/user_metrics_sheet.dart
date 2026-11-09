import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../models/user_metrics/user_metrics.dart';
import '../../../../models/weight_track/weight_track.dart';
import '../../../../theme/extensions.dart';
import '../../../../util/spacing.dart';
import '../../../../widgets/animated_digit_widget.dart';
import 'user_metrics_gender_list_tile.dart';
import 'user_metrics_height.dart';
import 'user_metrics_weight.dart';

class UserMetricsSheet extends StatefulWidget {
  final UserMetrics passedUserMetrics;
  final WeightTrack? lastWeightTrack;
  final bool userMetricsExist;
  final Future<UserMetrics?> Function({
    required Gender newGender,
    required int newAge,
    required double newHeight,
    required double newWeight,
  })
  onSavePressed;
  final Function()? onDeletePressed;

  const UserMetricsSheet({
    required this.passedUserMetrics,
    required this.lastWeightTrack,
    required this.userMetricsExist,
    required this.onSavePressed,
    required this.onDeletePressed,
  });

  @override
  State<UserMetricsSheet> createState() => _UserMetricsSheetState();
}

class _UserMetricsSheetState extends State<UserMetricsSheet> {
  final defaultAge = 30;
  final defaultHeight = 180.0;
  final defaultWeight = 75.0;

  var validated = false;

  Color? activeColor;

  Gender? activeGender;
  int? activeAge;
  double? activeHeight;
  double? activeWeight;

  Timer? ageUpdateTimer;

  @override
  void initState() {
    super.initState();

    final userMetrics = widget.passedUserMetrics;

    activeAge = userMetrics.age ?? defaultAge;
    activeHeight = userMetrics.height ?? defaultHeight;
    activeWeight = userMetrics.weight ?? widget.lastWeightTrack?.weight ?? defaultWeight;

    if (userMetrics.gender != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => updateGender(
          userMetrics.gender!,
        ),
      );
    }

    updateValidated();
  }

  @override
  void dispose() {
    stopAgeUpdate();
    super.dispose();
  }

  void updateValidated() => validated = activeGender != null && activeAge != null && activeHeight != null && activeWeight != null;

  void updateGender(Gender newGender) => setState(() {
    activeGender = newGender;
    activeColor = newGender == Gender.male ? context.colors.carbs : context.colors.fat;
    updateValidated();
  });

  void updateAge(int newAge) => setState(() {
    activeAge = newAge;
    updateValidated();
  });

  void updateHeight(double newHeight) => setState(() {
    activeHeight = newHeight;
    updateValidated();
  });

  void updateWeight(double newWeight) => setState(() {
    activeWeight = newWeight;
    updateValidated();
  });

  void startAgeUpdate(int amount) {
    stopAgeUpdate();
    changeAge(amount);

    ageUpdateTimer = Timer.periodic(
      BokunSpizeDurations.animation,
      (_) => changeAge(amount),
    );
  }

  void changeAge(int amount) {
    final currentAge = activeAge ?? defaultAge;
    final newAge = (currentAge + amount).clamp(1, 100).toInt();

    if (newAge == currentAge) {
      stopAgeUpdate();
      return;
    }

    HapticFeedback.lightImpact();
    updateAge(newAge);
  }

  void stopAgeUpdate() {
    ageUpdateTimer?.cancel();
    ageUpdateTimer = null;
  }

  /// Saves the currently provided user metrics
  Future<void> onSavePressed() async {
    unawaited(
      HapticFeedback.lightImpact(),
    );

    setState(() => validated = false);

    final updatedUserMetrics = await widget.onSavePressed(
      newGender: activeGender!,
      newAge: activeAge!,
      newHeight: activeHeight!,
      newWeight: activeWeight!,
    );

    if (!mounted) {
      return;
    }

    if (updatedUserMetrics == null) {
      setState(updateValidated);
      return;
    }

    Navigator.of(context).pop(updatedUserMetrics);
  }

  /// Deletes the currently saved user metrics
  void onDeletePressed() {
    if (widget.onDeletePressed != null) {
      HapticFeedback.lightImpact();
      widget.onDeletePressed!();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAge = activeAge ?? defaultAge;
    final currentHeight = activeHeight ?? defaultHeight;
    final currentWeight = activeWeight ?? defaultWeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: ColoredBox(
        color: context.colors.scaffoldBackground,
        child: CustomScrollView(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            ///
            /// TITLE & CLOSE BUTTON
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 10),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ///
                      /// DELETE BUTTON
                      ///
                      Opacity(
                        opacity: widget.userMetricsExist ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: !widget.userMetricsExist,
                          child: IconButton(
                            onPressed: onDeletePressed,
                            icon: const PhosphorIcon(
                              PhosphorIconsBold.trash,
                              size: 22,
                            ),
                            style: IconButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              backgroundColor: context.colors.delete,
                              foregroundColor: context.colors.buttonText,
                            ),
                          ),
                        ),
                      ),

                      ///
                      /// TITLE
                      ///
                      Expanded(
                        child: Text(
                          'userMetricsTitle'.tr(),
                          style: TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: 0.6,
                            color: context.colors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      ///
                      /// CLOSE BUTTON
                      ///
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.x,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                          foregroundColor: context.colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ///
            /// SUBTITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 2,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 8),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Text(
                    'userMetricsSubtitle'.tr(),
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            ///
            /// GENDER
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: marginHorizontal,
                vertical: 8,
              ),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 3,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 18),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                    ScaleEffect(
                      begin: Offset(0.98, 0.98),
                      end: Offset(1, 1),
                      alignment: Alignment.topCenter,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Row(
                    children: [
                      ///
                      /// MALE
                      ///
                      Expanded(
                        child: UserMetricsGenderListTile(
                          isActive: activeGender == Gender.male,
                          primaryColor: context.colors.carbs,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            updateGender(Gender.male);
                          },
                          icon: PhosphorIconsBold.genderMale,
                          title: 'genderMale'.tr(),
                        ),
                      ),
                      const SizedBox(width: 16),

                      ///
                      /// FEMALE
                      ///
                      Expanded(
                        child: UserMetricsGenderListTile(
                          isActive: activeGender == Gender.female,
                          primaryColor: context.colors.fat,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            updateGender(Gender.female);
                          },
                          icon: PhosphorIconsBold.genderFemale,
                          title: 'genderFemale'.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 12),
            ),

            ///
            /// AGE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 4,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 12),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Material(
                    color: context.colors.listTileBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(listTileRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(listTileRadius),
                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(listTileRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///
                                  /// TITLE
                                  ///
                                  Text(
                                    'age'.tr().toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Epilogue',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: context.colors.text.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  ///
                                  /// AGE
                                  ///
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: AnimatedDigitWidget(
                                            value: currentAge,
                                            loop: false,
                                            duration: BokunSpizeDurations.animation,
                                            curve: Curves.easeIn,
                                            textStyle: TextStyle(
                                              fontFamily: 'Epilogue',
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: context.colors.text,
                                            ),
                                          ),
                                        ),
                                        const WidgetSpan(
                                          child: SizedBox(width: 4),
                                        ),
                                        TextSpan(
                                          text: 'years'.tr(),
                                          style: TextStyle(
                                            fontFamily: 'Epilogue',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: context.colors.text.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Epilogue',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: context.colors.text,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            ///
                            /// BUTTONS
                            ///
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: context.colors.scaffoldBackground,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ///
                                  /// INCREMENT
                                  ///
                                  Material(
                                    color: currentAge > 1 ? context.colors.listTileBackground.withValues(alpha: 0.5) : context.colors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: currentAge > 1 ? () {} : null,
                                      onTapDown: currentAge > 1 ? (_) => startAgeUpdate(-1) : null,
                                      onTapUp: currentAge > 1 ? (_) => stopAgeUpdate() : null,
                                      onTapCancel: stopAgeUpdate,
                                      borderRadius: BorderRadius.circular(12),
                                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                      splashColor: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: PhosphorIcon(
                                          PhosphorIconsBold.minus,
                                          size: 22,
                                          color: context.colors.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  ///
                                  /// DECREMENT
                                  ///
                                  Material(
                                    color: currentAge < 100 ? activeColor ?? context.colors.listTileBackground.withValues(alpha: 0.5) : context.colors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: currentAge < 100 ? () {} : null,
                                      onTapDown: currentAge < 100 ? (_) => startAgeUpdate(1) : null,
                                      onTapUp: currentAge < 100 ? (_) => stopAgeUpdate() : null,
                                      onTapCancel: stopAgeUpdate,
                                      borderRadius: BorderRadius.circular(12),
                                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                      splashColor: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: PhosphorIcon(
                                          PhosphorIconsBold.plus,
                                          size: 22,
                                          color: currentAge < 100 && activeColor != null ? context.colors.buttonText : context.colors.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            ///
            /// HEIGHT
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 5,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 12),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Material(
                    color: context.colors.listTileBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(listTileRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(listTileRadius),
                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(listTileRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///
                            /// TITLE
                            ///
                            Text(
                              'accountUserMetricsHeight'.tr().toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: context.colors.text.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),

                            ///
                            /// HEIGHT
                            ///
                            UserMetricsHeight(
                              initialHeight: currentHeight,
                              onHeightChanged: updateHeight,
                              primaryColor: activeColor ?? context.colors.text,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            ///
            /// WEIGHT
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 6,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 12),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Material(
                    color: context.colors.listTileBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(listTileRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(listTileRadius),
                      highlightColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(listTileRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///
                            /// TITLE
                            ///
                            Text(
                              'accountUserMetricsWeight'.tr().toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: context.colors.text.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),

                            ///
                            /// HEIGHT
                            ///
                            UserMetricsWeight(
                              initialWeight: currentWeight,
                              onWeightChanged: updateWeight,
                              primaryColor: activeColor ?? context.colors.text,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            ///
            /// SAVE BUTTON
            ///
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * 7,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 14),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: validated ? onSavePressed : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: activeColor ?? context.colors.listTileBackground.withValues(alpha: 0.5),
                        foregroundColor: context.colors.buttonText,
                        disabledBackgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                        disabledForegroundColor: activeColor ?? context.colors.listTileBackground.withValues(alpha: 0.5),
                      ),
                      child: Text(
                        'saveMeasurements'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            ///
            /// BOTTOM SPACING
            ///
            SliverToBoxAdapter(
              child: SizedBox(
                height: getBottomSpacing(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
