import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../models/meal/meal.dart';
import '../../models/meal/nutrition.dart';
import '../../services/speech_to_text_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/parse.dart';
import '../../util/spacing.dart';
import '../../util/typedefs.dart';
import '../../widgets/meal_image.dart';
import '../../widgets/text_field_title_widget.dart';
import 'manual_add_meal_controller.dart';
import 'widgets/manual_add_meal_food_list_tile.dart';

class ManualAddMealScreen extends WatchingStatefulWidget {
  final String mealId;
  final Meal? passedMeal;
  final bool isCopyingMeal;

  const ManualAddMealScreen({
    required this.mealId,
    required this.passedMeal,
    required this.isCopyingMeal,
  });

  @override
  State<ManualAddMealScreen> createState() => _ManualAddMealScreenState();
}

class _ManualAddMealScreenState extends State<ManualAddMealScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<ManualAddMealController>(
      () => ManualAddMealController(
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
    unRegisterIfNotDisposed<ManualAddMealController>(
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
    final mealController = getIt.get<ManualAddMealController>(
      instanceName: widget.mealId,
    );

    /// Reference to `state`
    final state = watchIt<ManualAddMealController>(
      instanceName: widget.mealId,
    ).value;
    final speechToTextState = watchIt<SpeechToTextService>().value;

    final available = speechToTextState.available;
    final isListening = speechToTextState.isListening;

    final imageFile = state.imageFile;
    final foods = state.foods;
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

    final isCopyingMeal = widget.isCopyingMeal;

    final showText = !isCopyingMeal || mealController.nameTextEditingController.text.trim().isNotEmpty;
    final showImage = !isCopyingMeal || widget.passedMeal?.imageStoragePath != null || imageFile != null;

    /// Keep the entrance sequence in layout order when optional sections are hidden
    final imageAnimationStep = showText ? 4 : 3;
    final nutritionAnimationStep = imageAnimationStep + (showImage ? 1 : 0);
    final foodListAnimationStep = nutritionAnimationStep + 4;

    /// Limit the food stagger to five steps so long lists keep later controls responsive
    final foodAnimationCount = (foods?.length ?? 0).clamp(0, 5);
    final addFoodAnimationStep = foodListAnimationStep + foodAnimationCount;
    final dateTimeAnimationStep = isCopyingMeal ? nutritionAnimationStep : addFoodAnimationStep + 1;

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
                    Expanded(
                      child: Text(
                        isCopyingMeal ? 'Copy meal' : 'Log meal',
                        style: const TextStyle(
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
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),

          ///
          /// TEXT FIELD
          ///
          if (showText) ...[
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
                    enabled: !isCopyingMeal,
                    textEditingController: mealController.nameTextEditingController,
                    focusNode: mealController.nameFocusNode,
                    onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                    onSubmitted: (_) => mealController.caloriesFocusNode.requestFocus(),
                    title: 'Meal name',
                    hintText: isCopyingMeal ? 'Meal has no text' : null,
                    textColor: BokunSpizeColors.black,
                    rightWidget: isCopyingMeal
                        ? null
                        : Animate(
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
            if (showImage)
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
          ],

          ///
          /// NETWORK IMAGE
          ///
          if (widget.passedMeal?.imageStoragePath != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  key: ValueKey('meal-image-${widget.passedMeal!.imageStoragePath}'),
                  delay: BokunSpizeDurations.stateTransitionStagger * imageAnimationStep,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(listTileRadius),
                    child: SizedBox(
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
              ),
            )
          ///
          /// LOCAL IMAGE
          ///
          else if (imageFile != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  key: ValueKey('meal-image-$imageFile'),
                  delay: BokunSpizeDurations.stateTransitionStagger * imageAnimationStep,
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
          else if (!isCopyingMeal)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  key: ValueKey('meal-image-empty-${widget.isCopyingMeal}'),
                  delay: BokunSpizeDurations.stateTransitionStagger * imageAnimationStep,
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
                      color: BokunSpizeColors.white.withValues(
                        alpha: isCopyingMeal ? 0.25 : 0.5,
                      ),
                    ),
                    height: 160,
                    width: double.infinity,
                    child: isCopyingMeal
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
                                  foregroundColor: BokunSpizeColors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Meal has no image',
                                style: TextStyle(
                                  fontFamily: 'Epilogue',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.6,
                                  color: BokunSpizeColors.black,
                                ),
                                textAlign: TextAlign.center,
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

          if (!isCopyingMeal) ...[
            ///
            /// NUTRITION TITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * nutritionAnimationStep,
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
                    'Nutritional values',
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
            /// CALORIES
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * (nutritionAnimationStep + 1),
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
                    enabled: !isCopyingMeal,
                    textEditingController: mealController.caloriesTextEditingController,
                    focusNode: mealController.caloriesFocusNode,
                    onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                    onSubmitted: (_) => mealController.proteinFocusNode.requestFocus(),
                    title: 'Calories',
                    hintText: '0',
                    rightText: 'kcal',
                    textColor: BokunSpizeColors.green,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            ///
            /// NUTRITION
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * (nutritionAnimationStep + 2),
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
                  child: Row(
                    spacing: 20,
                    children: [
                      ///
                      /// PROTEIN
                      ///
                      Expanded(
                        child: TextFieldTitleWidget(
                          enabled: !isCopyingMeal,
                          textEditingController: mealController.proteinTextEditingController,
                          focusNode: mealController.proteinFocusNode,
                          onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                          onSubmitted: (_) => mealController.carbsFocusNode.requestFocus(),
                          title: 'Protein',
                          hintText: '0',
                          rightText: 'g',
                          textColor: BokunSpizeColors.green,
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      ///
                      /// CARBS
                      ///
                      Expanded(
                        child: TextFieldTitleWidget(
                          enabled: !isCopyingMeal,
                          textEditingController: mealController.carbsTextEditingController,
                          focusNode: mealController.carbsFocusNode,
                          onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                          onSubmitted: (_) => mealController.fatsFocusNode.requestFocus(),
                          title: 'Carbs',
                          hintText: '0',
                          rightText: 'g',
                          textColor: BokunSpizeColors.blue,
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      ///
                      /// FAT
                      ///
                      Expanded(
                        child: TextFieldTitleWidget(
                          enabled: !isCopyingMeal,
                          textEditingController: mealController.fatsTextEditingController,
                          focusNode: mealController.fatsFocusNode,
                          title: 'Fats',
                          hintText: '0',
                          rightText: 'g',
                          textColor: BokunSpizeColors.bordeaux,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),

            ///
            /// FOODS TITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  delay: BokunSpizeDurations.stateTransitionStagger * (foodListAnimationStep - 1),
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
                    'Foods',
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
            /// FOODS
            ///
            if (foods?.isNotEmpty ?? false) ...[
              SliverList.builder(
                itemCount: foods!.length,
                findChildIndexCallback: (key) {
                  final index = foods.indexWhere(
                    (food) => ObjectKey(food) == key,
                  );
                  return index == -1 ? null : index;
                },
                itemBuilder: (context, index) {
                  final food = foods[index];

                  return Animate(
                    key: ObjectKey(food),
                    delay: BokunSpizeDurations.stateTransitionStagger * (foodListAnimationStep + index.clamp(0, 4)),
                    effects: const [
                      FadeEffect(
                        duration: BokunSpizeDurations.stateTransition,
                        curve: Curves.easeOut,
                      ),
                      MoveEffect(
                        begin: Offset(0, 18),
                        end: Offset.zero,
                        duration: BokunSpizeDurations.stateTransition,
                        curve: Curves.easeOutCubic,
                      ),
                    ],
                    child: ManualAddMealFoodListTile(
                      enabled: !isCopyingMeal,
                      onPressed: isCopyingMeal
                          ? () {}
                          : () => handleOnPressed(
                              onPressed: () => mealController.onAddFoodPressed(
                                context,
                                passedFood: food,
                              ),
                            ),
                      onDeletePressed: () {
                        HapticFeedback.lightImpact();
                        mealController.deleteFood(
                          index: index,
                        );
                      },
                      food: food,
                      index: index,
                    ),
                  );
                },
              ),
              if (!isCopyingMeal)
                const SliverToBoxAdapter(
                  child: SizedBox(height: 8),
                ),
            ],

            ///
            /// ADD FOOD BUTTON
            ///
            if (!isCopyingMeal)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
                sliver: SliverToBoxAdapter(
                  child: Animate(
                    delay: BokunSpizeDurations.stateTransitionStagger * addFoodAnimationStep,
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
                    child: ElevatedButton.icon(
                      onPressed: () => handleOnPressed(
                        onPressed: () => mealController.onAddFoodPressed(
                          context,
                          passedFood: null,
                        ),
                      ),
                      icon: const PhosphorIcon(
                        PhosphorIconsBold.plus,
                        color: BokunSpizeColors.black,
                        size: 20,
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                        foregroundColor: BokunSpizeColors.black,
                        disabledBackgroundColor: BokunSpizeColors.white.withValues(alpha: 0.25),
                        disabledForegroundColor: BokunSpizeColors.black.withValues(alpha: 0.5),
                      ),
                      label: const Text(
                        'Add food',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],

          ///
          /// DATE & TIME TITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            sliver: SliverToBoxAdapter(
              child: Animate(
                delay: BokunSpizeDurations.stateTransitionStagger * dateTimeAnimationStep,
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
                delay: BokunSpizeDurations.stateTransitionStagger * (dateTimeAnimationStep + 1),
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
                delay: BokunSpizeDurations.stateTransitionStagger * (dateTimeAnimationStep + 2),
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
                delay: BokunSpizeDurations.stateTransitionStagger * (dateTimeAnimationStep + 3),
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
                              /// Dismiss sheet with the complete manual meal result
                              Navigator.of(context).pop<ManualMealResult>(
                                (
                                  name: mealController.nameTextEditingController.text.trim(),
                                  dateTime: getMealDateTime(
                                    mealDate: mealDate,
                                    mealTime: mealTime,
                                  ),
                                  nutrition: Nutrition(
                                    calories: parseNumberForFood(
                                      mealController.caloriesTextEditingController.text.trim(),
                                    ),
                                    protein: parseNumberForFood(
                                      mealController.proteinTextEditingController.text.trim(),
                                    ),
                                    carbs: parseNumberForFood(
                                      mealController.carbsTextEditingController.text.trim(),
                                    ),
                                    fat: parseNumberForFood(
                                      mealController.fatsTextEditingController.text.trim(),
                                    ),
                                  ),
                                  foods: List.from(
                                    foods ?? [],
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
