import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../services/speech_to_text_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../widgets/text_field_title_widget.dart';
import 'ai_add_meal_controller.dart';

class AIAddMealScreen extends WatchingStatefulWidget {
  final String mealId;

  const AIAddMealScreen({
    required this.mealId,
  });

  @override
  State<AIAddMealScreen> createState() => _AIAddMealScreenState();
}

class _AIAddMealScreenState extends State<AIAddMealScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<AIAddMealController>(
      () => AIAddMealController(
        speechToText: getIt.get<SpeechToTextService>(),
      ),
      instanceName: widget.mealId,
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<AIAddMealController>(
      instanceName: widget.mealId,
    );
    super.dispose();
  }

  void handleOnPressed({
    required Function() onPressed,
  }) {
    /// Hide snackbars & keyboard
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    FocusManager.instance.primaryFocus?.unfocus();

    HapticFeedback.lightImpact();

    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final mealController = getIt.get<AIAddMealController>(
      instanceName: widget.mealId,
    );

    /// Reference to `state`
    final state = watchIt<AIAddMealController>(
      instanceName: widget.mealId,
    ).value;
    final speechToTextState = watchIt<SpeechToTextService>().value;

    final available = speechToTextState.available;
    final isListening = speechToTextState.isListening;

    final imageFile = state.imageFile;
    final mealDate = state.mealDate;
    final mealTime = state.mealTime;
    final validation = state.validation;

    final date = getDateString(
      date: mealDate,
      dateFormat: 'dd.MM.yyyy.',
    );

    final time = getDateString(
      date: mealTime,
      dateFormat: 'HH:mm',
      useTodayYesterdayTomorrow: false,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
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
                    /// PLACEHOLDER BUTTON
                    ///
                    Opacity(
                      opacity: 0,
                      child: IgnorePointer(
                        child: IconButton(
                          onPressed: null,
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.x,
                            size: 22,
                          ),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                            foregroundColor: BokunSpizeColors.black,
                          ),
                        ),
                      ),
                    ),

                    ///
                    /// TITLE
                    ///
                    const Expanded(
                      child: Text(
                        'Log meal',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 0.6,
                          color: BokunSpizeColors.black,
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
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                        foregroundColor: BokunSpizeColors.black,
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
                child: const Text(
                  'New meal in your journal',
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: BokunSpizeColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),

          ///
          /// TEXT FIELD
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 3,
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
                child: TextFieldTitleWidget(
                  minLines: 3,
                  maxLines: 3,
                  controller: mealController.textEditingController,
                  focusNode: mealController.textFocusNode,
                  onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                  title: 'Describe your meal',
                  textColor: BokunSpizeColors.black,
                  rightWidget: Animate(
                    onPlay: (controller) {
                      if (isListening) {
                        controller.loop(
                          reverse: true,
                          min: 0.6,
                        );
                      }
                    },
                    effects: [
                      if (isListening)
                        const FadeEffect(
                          duration: BokunSpizeDurations.speechToTextShimmer,
                          curve: Curves.easeIn,
                        ),
                    ],
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        mealController.onSpeechToTextPressed(
                          // TODO: Replace hardcoded 'en' with `context.locale.languageCode`
                          locale: 'en',
                          speechToTextAvailable: available,
                        );
                      },
                      icon: const PhosphorIcon(
                        PhosphorIconsBold.microphone,
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        backgroundColor: isListening ? BokunSpizeColors.red : BokunSpizeColors.white.withValues(alpha: 0.5),
                        foregroundColor: isListening ? BokunSpizeColors.white : BokunSpizeColors.red,
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
          /// LOCAL IMAGE
          ///
          if (imageFile != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  key: ValueKey('meal-image-$imageFile'),
                  delay: BokunSpizeDurations.stateTransitionStagger * 4,
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
                    ScaleEffect(
                      begin: Offset(0.98, 0.98),
                      end: Offset(1, 1),
                      alignment: Alignment.topCenter,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Stack(
                    children: [
                      ///
                      /// IMAGE
                      ///
                      ClipRRect(
                        borderRadius: BorderRadius.circular(listTileRadius),
                        child: Image.file(
                          imageFile,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(listTileRadius),
                            ),
                            height: 160,
                            width: double.infinity,
                            child: const PhosphorIcon(
                              PhosphorIconsBold.warningOctagon,
                              size: 56,
                              color: BokunSpizeColors.red,
                            ),
                          ),
                        ),
                      ),

                      ///
                      /// DELETE
                      ///
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          onPressed: () => handleOnPressed(
                            onPressed: () => mealController
                              ..updateState(
                                imageFile: null,
                              )
                              ..triggerValidation(),
                          ),
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.trash,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            backgroundColor: BokunSpizeColors.white,
                            foregroundColor: BokunSpizeColors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ///
          /// EMPTY IMAGE
          ///
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  key: const ValueKey('meal-image-empty'),
                  delay: BokunSpizeDurations.stateTransitionStagger * 4,
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
                    ScaleEffect(
                      begin: Offset(0.98, 0.98),
                      end: Offset(1, 1),
                      alignment: Alignment.topCenter,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(listTileRadius),
                      color: BokunSpizeColors.white.withValues(alpha: 0.5),
                    ),
                    height: 160,
                    width: double.infinity,
                    child: Row(
                      spacing: 56,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ///
                        /// CAMERA
                        ///
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => handleOnPressed(
                                  onPressed: mealController.onCameraPressed,
                                ),
                                icon: const PhosphorIcon(
                                  PhosphorIconsBold.cameraPlus,
                                  size: 32,
                                ),
                                style: IconButton.styleFrom(
                                  elevation: 0,
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                                  foregroundColor: BokunSpizeColors.green,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Camera',
                                style: TextStyle(
                                  fontFamily: 'Epilogue',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: BokunSpizeColors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        ///
                        /// GALLERY
                        ///
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () => handleOnPressed(
                                  onPressed: mealController.onGalleryPressed,
                                ),
                                icon: const PhosphorIcon(
                                  PhosphorIconsBold.images,
                                  size: 32,
                                ),
                                style: IconButton.styleFrom(
                                  elevation: 0,
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                                  foregroundColor: BokunSpizeColors.green,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Gallery',
                                style: TextStyle(
                                  fontFamily: 'Epilogue',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: BokunSpizeColors.black,
                                ),
                                textAlign: TextAlign.center,
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),

          ///
          /// DATE & TIME TITLE
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
                    begin: Offset(0, 8),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: const Text(
                  'Date & Time',
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: BokunSpizeColors.black,
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          ///
          /// DATE
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
                  color: BokunSpizeColors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(listTileRadius),
                  child: InkWell(
                    onTap: () => handleOnPressed(
                      onPressed: () => mealController.updateDateViaPicker(context),
                    ),
                    borderRadius: BorderRadius.circular(listTileRadius),
                    highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
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
                                  'Date'.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: BokunSpizeColors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                ///
                                /// DATE
                                ///
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: BokunSpizeColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///
                          /// ICON
                          ///
                          const PhosphorIcon(
                            PhosphorIconsBold.calendarPlus,
                            size: 28,
                            color: BokunSpizeColors.green,
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
          /// TIME
          ///
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
                    begin: Offset(0, 12),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Material(
                  color: BokunSpizeColors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(listTileRadius),
                  child: InkWell(
                    onTap: () => handleOnPressed(
                      onPressed: () => mealController.updateTimeViaPicker(context),
                    ),
                    borderRadius: BorderRadius.circular(listTileRadius),
                    highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
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
                                  'Time'.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: BokunSpizeColors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                ///
                                /// TIME
                                ///
                                Text(
                                  time,
                                  style: const TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: BokunSpizeColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///
                          /// ICON
                          ///
                          const PhosphorIcon(
                            PhosphorIconsBold.clock,
                            size: 28,
                            color: BokunSpizeColors.green,
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
            child: SizedBox(height: 32),
          ),

          ///
          /// SAVE BUTTON
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * 8,
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
                    onPressed: validation
                        ? () => handleOnPressed(
                            onPressed: () {
                              /// Get `words` from [TextEditingController]
                              final words = mealController.textEditingController.text.trim();

                              /// Dismiss sheet
                              Navigator.of(context).pop(
                                (
                                  words: words,
                                  dateTime: getMealDateTime(
                                    mealDate: mealDate,
                                    mealTime: mealTime,
                                  ),
                                  imageFile: imageFile,
                                ),
                              );
                            },
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      padding: const EdgeInsets.all(22),
                      backgroundColor: BokunSpizeColors.green,
                      foregroundColor: BokunSpizeColors.white,
                      disabledBackgroundColor: BokunSpizeColors.green.withValues(alpha: 0.25),
                      disabledForegroundColor: BokunSpizeColors.white.withValues(alpha: 0.75),
                    ),
                    child: const Text(
                      'Log meal',
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
    );
  }
}
