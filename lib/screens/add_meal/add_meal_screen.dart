import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../models/meal/meal.dart';
import '../../services/speech_to_text_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../widgets/meal_image.dart';
import '../../widgets/text_field_widget.dart';
import 'add_meal_controller.dart';

class AddMealScreen extends WatchingStatefulWidget {
  final String mealId;
  final Meal? passedMeal;
  final bool isCopyingMeal;

  const AddMealScreen({
    required this.mealId,
    required this.passedMeal,
    required this.isCopyingMeal,
  });

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<AddMealController>(
      () => AddMealController(
        speechToText: getIt.get<SpeechToTextService>(),
        passedMeal: widget.passedMeal,
        isCopyingMeal: widget.isCopyingMeal,
      ),
      instanceName: widget.mealId,
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<AddMealController>(
      instanceName: widget.mealId,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealController = getIt.get<AddMealController>(
      instanceName: widget.mealId,
    );

    /// Reference to `state`
    final state = watchIt<AddMealController>(
      instanceName: widget.mealId,
    ).value;
    final speechToTextState = watchIt<SpeechToTextService>().value;

    final available = speechToTextState.available;
    final isListening = speechToTextState.isListening;

    final imageFile = state.imageFile;
    final mealDate = state.mealDate;
    final mealTime = state.mealTime;
    final textImageValid = state.textImageValid;

    final copyingMealWithoutText = widget.isCopyingMeal && (widget.passedMeal?.originalText?.isEmpty ?? false);

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
            child: SizedBox(height: 40),
          ),

          ///
          /// TITLE & CLOSE BUTTON
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
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

          ///
          /// SUBTITLE
          ///
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Add meal to your journal',
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          ///
          /// TEXT FIELD & TITLE & ICON
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Stack(
                children: [
                  ///
                  /// TEXT FIELD
                  ///
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(listTileRadius),
                    child: InkWell(
                      onLongPress: widget.isCopyingMeal
                          ? () {
                              HapticFeedback.lightImpact();

                              /// Get text from [TextEditingController]
                              final text = mealController.textEditingController.text.trim();

                              /// No text, return
                              if (text.isEmpty) {
                                return;
                              }

                              /// Copy text to clipboard
                              Clipboard.setData(
                                ClipboardData(
                                  text: text,
                                ),
                              );
                            }
                          : null,
                      highlightColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(listTileRadius),
                      child: TextFieldWidget(
                        enabled: !widget.isCopyingMeal,
                        controller: mealController.textEditingController,
                        focusNode: mealController.textFocusNode,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 40,
                        ),
                        onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                        keyboardType: TextInputType.multiline,
                        textAlign: TextAlign.left,
                        textAlignVertical: TextAlignVertical.top,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        minLines: 3,
                        maxLines: 3,
                        borderRadius: listTileRadius,
                        hintText: copyingMealWithoutText ? null : 'What did you eat?',
                        hintWidget: copyingMealWithoutText
                            ? SizedBox(
                                height: 104,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: HapticFeedback.lightImpact,
                                      icon: const PhosphorIcon(
                                        PhosphorIconsBold.pencilSlash,
                                        size: 32,
                                      ),
                                      style: IconButton.styleFrom(
                                        elevation: 0,
                                        padding: const EdgeInsets.all(16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.25),
                                        foregroundColor: BokunSpizeColors.black.withValues(alpha: 0.75),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Meal has no text',
                                      style: TextStyle(
                                        fontFamily: 'Epilogue',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.6,
                                        color: BokunSpizeColors.black.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                        hintStyle: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: BokunSpizeColors.black.withValues(alpha: 0.5),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: BokunSpizeColors.black,
                        ),
                      ),
                    ),
                  ),

                  ///
                  /// TEXT FIELD TITLE
                  ///
                  if (!copyingMealWithoutText)
                    Positioned(
                      top: 16,
                      left: 20,
                      child: IgnorePointer(
                        child: Text(
                          'Describe your meal'.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: BokunSpizeColors.green,
                          ),
                        ),
                      ),
                    ),

                  ///
                  /// SPEECH TO TEXT ICON
                  ///
                  if (!copyingMealWithoutText && !widget.isCopyingMeal)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Animate(
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
                              locale: 'hr',
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
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          ///
          /// NETWORK IMAGE
          ///
          if (widget.passedMeal?.imageStoragePath != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(listTileRadius),
                  child: SizedBox(
                    key: ValueKey(widget.passedMeal!.imageStoragePath),
                    height: 160,
                    width: double.infinity,
                    child: MealImage(
                      imageStoragePath: widget.passedMeal!.imageStoragePath!,
                      height: 160,
                      width: double.infinity,
                      errorWidget: Container(
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
                ),
              ),
            )
          ///
          /// LOCAL IMAGE
          ///
          else if (imageFile != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Stack(
                  children: [
                    ///
                    /// IMAGE
                    ///
                    ClipRRect(
                      borderRadius: BorderRadius.circular(listTileRadius),
                      child: Image.file(
                        key: ValueKey(imageFile),
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
                        onPressed: () {
                          HapticFeedback.lightImpact();

                          /// Update `state` + trigger validation
                          mealController
                            ..updateState(
                              imageFile: null,
                            )
                            ..triggerValidation();
                        },
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
            )
          ///
          /// EMPTY IMAGE
          ///
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(listTileRadius),
                    color: BokunSpizeColors.white.withValues(
                      alpha: widget.isCopyingMeal ? 0.25 : 0.5,
                    ),
                  ),
                  height: 160,
                  width: double.infinity,
                  child: widget.isCopyingMeal
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: HapticFeedback.lightImpact,
                              icon: const PhosphorIcon(
                                PhosphorIconsBold.cameraSlash,
                                size: 32,
                              ),
                              style: IconButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.25),
                                foregroundColor: BokunSpizeColors.black.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Meal has no image',
                              style: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.6,
                                color: BokunSpizeColors.black.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          spacing: 56,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ///
                            /// CAMERA
                            ///
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    mealController.onCameraPressed();
                                  },
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
                                ),
                              ],
                            ),

                            ///
                            /// GALLERY
                            ///
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    mealController.onGalleryPressed();
                                  },
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
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          ///
          /// DATE
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Material(
                color: BokunSpizeColors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(listTileRadius),
                child: InkWell(
                  onTap: () => mealController.updateDateViaPicker(context),
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
                        Column(
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          ///
          /// TIME
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Material(
                color: BokunSpizeColors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(listTileRadius),
                child: InkWell(
                  onTap: () => mealController.updateTimeViaPicker(context),
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
                        Column(
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

          const SliverToBoxAdapter(
            child: SizedBox(height: 28),
          ),

          ///
          /// SAVE BUTTON
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: textImageValid
                      ? () {
                          HapticFeedback.lightImpact();

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
                              deleteMeal: false,
                            ),
                          );
                        }
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
                  child: const Text('Log meal'),
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
