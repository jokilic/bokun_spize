import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../models/meal/meal.dart';
import '../../models/meal/nutrition.dart';
import '../../services/speech_to_text_service.dart';
import '../../theme/extensions.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/parse.dart';
import '../../util/spacing.dart';
import '../../util/typedefs.dart';
import '../../widgets/meal_image.dart';
import '../../widgets/text_field_widget.dart';
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
    final imageStoragePath = state.imageStoragePath;
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
    final isEditingMeal = widget.passedMeal != null && !isCopyingMeal;

    final showText = !isCopyingMeal || mealController.nameTextEditingController.text.trim().isNotEmpty;
    final showImage = !isCopyingMeal || imageStoragePath != null || imageFile != null;

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
                            backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                            foregroundColor: context.colors.text,
                          ),
                        ),
                      ),
                    ),

                    ///
                    /// TITLE
                    ///
                    Expanded(
                      child: Text(
                        isCopyingMeal ? 'Copy meal' : (isEditingMeal ? 'Edit meal' : 'Log meal'),
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 26,
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
                  isEditingMeal ? 'Update meal in your journal' : 'New meal in your journal',
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.colors.text,
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
          /// TEXT FIELD & SPEECH TO TEXT
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
                  child: Stack(
                    children: [
                      ///
                      /// TEXT FIELD
                      ///
                      TextFieldWidget(
                        enabled: !isCopyingMeal,
                        controller: mealController.nameTextEditingController,
                        focusNode: mealController.nameFocusNode,
                        onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                        onSubmitted: (_) => mealController.caloriesFocusNode.requestFocus(),
                        title: 'Meal name',
                        hintText: isCopyingMeal ? 'Meal has no name' : 'What was it?',
                        textColor: context.colors.text,
                      ),

                      ///
                      /// SPEECH TO TEXT ICON
                      ///
                      if (!isCopyingMeal)
                        Positioned(
                          bottom: 8,
                          right: 8,
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
                                backgroundColor: isListening ? context.colors.delete : context.colors.listTileBackground.withValues(alpha: 0.5),
                                foregroundColor: isListening ? context.colors.listTileBackground : context.colors.delete,
                              ),
                            ),
                          ),
                        ),
                    ],
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
          if (imageStoragePath != null && imageFile == null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              sliver: SliverToBoxAdapter(
                child: Animate(
                  key: ValueKey('meal-image-$imageStoragePath'),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(listTileRadius),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: MealImage(
                            imageStoragePath: imageStoragePath,
                            height: 160,
                            width: double.infinity,
                            errorWidget: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(listTileRadius),
                              ),
                              height: 160,
                              width: double.infinity,
                              child: PhosphorIcon(
                                PhosphorIconsBold.warningOctagon,
                                size: 56,
                                color: context.colors.delete,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isCopyingMeal)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            onPressed: () => handleOnPressed(
                              onPressed: mealController.removeImage,
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
                              backgroundColor: context.colors.listTileBackground,
                              foregroundColor: context.colors.delete,
                            ),
                          ),
                        ),
                    ],
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
                            child: PhosphorIcon(
                              PhosphorIconsBold.warningOctagon,
                              size: 56,
                              color: context.colors.delete,
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
                            onPressed: mealController.removeImage,
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
                            backgroundColor: context.colors.listTileBackground,
                            foregroundColor: context.colors.delete,
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
                      color: context.colors.listTileBackground.withValues(
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
                                  backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.25),
                                  foregroundColor: context.colors.text,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Meal has no image',
                                style: TextStyle(
                                  fontFamily: 'Epilogue',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.6,
                                  color: context.colors.text,
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
                                        backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                        foregroundColor: context.colors.protein,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        fontFamily: 'Epilogue',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.6,
                                        color: context.colors.text,
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
                                        backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                                        foregroundColor: context.colors.protein,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Gallery',
                                      style: TextStyle(
                                        fontFamily: 'Epilogue',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.6,
                                        color: context.colors.text,
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
                  child: Text(
                    'Nutritional values',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: context.colors.text,
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
                  child: TextFieldWidget(
                    enabled: !isCopyingMeal,
                    controller: mealController.caloriesTextEditingController,
                    focusNode: mealController.caloriesFocusNode,
                    onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                    onSubmitted: (_) => mealController.proteinFocusNode.requestFocus(),
                    title: 'Calories',
                    hintText: '0',
                    rightText: 'kcal',
                    textColor: context.colors.protein,
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
                        child: TextFieldWidget(
                          enabled: !isCopyingMeal,
                          controller: mealController.proteinTextEditingController,
                          focusNode: mealController.proteinFocusNode,
                          onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                          onSubmitted: (_) => mealController.carbsFocusNode.requestFocus(),
                          title: 'Protein',
                          hintText: '0',
                          rightText: 'g',
                          textColor: context.colors.protein,
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      ///
                      /// CARBS
                      ///
                      Expanded(
                        child: TextFieldWidget(
                          enabled: !isCopyingMeal,
                          controller: mealController.carbsTextEditingController,
                          focusNode: mealController.carbsFocusNode,
                          onChanged: (_) => mealController.stopSpeechToTextIfListening(),
                          onSubmitted: (_) => mealController.fatsFocusNode.requestFocus(),
                          title: 'Carbs',
                          hintText: '0',
                          rightText: 'g',
                          textColor: context.colors.carbs,
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      ///
                      /// FAT
                      ///
                      Expanded(
                        child: TextFieldWidget(
                          enabled: !isCopyingMeal,
                          controller: mealController.fatsTextEditingController,
                          focusNode: mealController.fatsFocusNode,
                          title: 'Fats',
                          hintText: '0',
                          rightText: 'g',
                          textColor: context.colors.fat,
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
                  child: Text(
                    'Foods',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: context.colors.text,
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
                      icon: PhosphorIcon(
                        PhosphorIconsBold.plus,
                        color: context.colors.text,
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
                        shadowColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        surfaceTintColor: context.colors.text.withValues(alpha: 0.5),
                        backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                        foregroundColor: context.colors.text,
                        disabledBackgroundColor: context.colors.listTileBackground.withValues(alpha: 0.25),
                        disabledForegroundColor: context.colors.text.withValues(alpha: 0.5),
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
                child: Text(
                  'Date & time',
                  style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: context.colors.text,
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
                  color: context.colors.listTileBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(listTileRadius),
                  child: InkWell(
                    onTap: () => handleOnPressed(
                      onPressed: () => mealController.updateDateViaPicker(context),
                    ),
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
                                  'Date'.toUpperCase(),
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
                                /// DATE
                                ///
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: context.colors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///
                          /// ICON
                          ///
                          PhosphorIcon(
                            PhosphorIconsBold.calendarPlus,
                            size: 28,
                            color: context.colors.protein,
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
                  color: context.colors.listTileBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(listTileRadius),
                  child: InkWell(
                    onTap: () => handleOnPressed(
                      onPressed: () => mealController.updateTimeViaPicker(context),
                    ),
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
                                  'Time'.toUpperCase(),
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
                                /// TIME
                                ///
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: context.colors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///
                          /// ICON
                          ///
                          PhosphorIcon(
                            PhosphorIconsBold.clock,
                            size: 28,
                            color: context.colors.protein,
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
                                  imageStoragePath: imageStoragePath,
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
                      backgroundColor: context.colors.protein,
                      foregroundColor: context.colors.listTileBackground,
                      disabledBackgroundColor: context.colors.protein.withValues(alpha: 0.25),
                      disabledForegroundColor: context.colors.listTileBackground.withValues(alpha: 0.75),
                    ),
                    child: Text(
                      isEditingMeal ? 'Save changes' : 'Log meal',
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
