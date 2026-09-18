import 'dart:ui';

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../models/meal/meal.dart';
import '../../theme/extensions.dart';
import '../../util/color.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/format.dart';
import '../../util/spacing.dart';
import '../../widgets/animated_nutrition_bar.dart';
import '../../widgets/meal_image.dart';
import 'view_meal_controller.dart';
import 'widgets/view_meal_food_list_tile.dart';

class ViewMealScreen extends WatchingStatefulWidget {
  final Meal passedMeal;
  final Function() onCopyPressed;
  final Function() onEditPressed;
  final Function() onDeletePressed;

  const ViewMealScreen({
    required this.passedMeal,
    required this.onCopyPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  State<ViewMealScreen> createState() => _ViewMealScreenState();
}

class _ViewMealScreenState extends State<ViewMealScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<ViewMealController>(
      ViewMealController.new,
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<ViewMealController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealName = widget.passedMeal.name ?? widget.passedMeal.originalText ?? '--';
    final createdAt = widget.passedMeal.createdAt;

    final emoji = widget.passedMeal.emoji;
    final imageStoragePath = widget.passedMeal.imageStoragePath;

    final nutrition = widget.passedMeal.nutrition;
    final foods = widget.passedMeal.foods;

    final protein = nutrition?.protein ?? 0.0;
    final carbs = nutrition?.carbs ?? 0.0;
    final fat = nutrition?.fat ?? 0.0;

    final proteinBarWeight = protein.round() > 0 ? protein.round() : 1;
    final carbsBarWeight = carbs.round() > 0 ? carbs.round() : 1;
    final fatBarWeight = fat.round() > 0 ? fat.round() : 1;

    final totalBarWeight = proteinBarWeight + carbsBarWeight + fatBarWeight;

    final hasError = widget.passedMeal.errors?.isNotEmpty ?? false;

    final primaryColor =
        widget.passedMeal.color ??
        getCalorieValueColor(
          nutrition: widget.passedMeal.nutrition,
          context: context,
        );

    final imageBackgroundColor = hasError ? context.colors.delete : primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: CustomScrollView(
        shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        slivers: [
          ///
          /// IMAGE & ROUNDED TOP
          ///
          SliverToBoxAdapter(
            child: Stack(
              children: [
                ///
                /// IMAGE OR EMOJI
                ///
                Animate(
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
                  child: imageStoragePath != null
                      ? MealImage(
                          imageStoragePath: imageStoragePath,
                          height: 240,
                          width: double.infinity,
                          errorWidget: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(listTileRadius),
                            ),
                            height: 240,
                            width: double.infinity,
                            child: PhosphorIcon(
                              PhosphorIconsBold.warningOctagon,
                              size: 56,
                              color: context.colors.delete,
                            ),
                          ),
                        )
                      : Container(
                          height: 240,
                          width: double.infinity,
                          color: imageBackgroundColor,
                          child: hasError
                              ? PhosphorIcon(
                                  PhosphorIconsBold.warningOctagon,
                                  color: context.colors.buttonText,
                                  size: 80,
                                )
                              : emoji != null
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 80,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                )
                              : PhosphorIcon(
                                  PhosphorIconsBold.bowlFood,
                                  color: context.colors.buttonText,
                                  size: 80,
                                ),
                        ),
                ),

                ///
                /// ROUNDED TOP
                ///
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.scaffoldBackground,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(listTileRadius),
                      ),
                    ),
                  ),
                ),

                ///
                /// BUTTONS
                ///
                Positioned(
                  left: 0,
                  right: 0,
                  top: 24,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ///
                        /// MORE BUTTON
                        ///
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 16,
                              sigmaY: 16,
                            ),
                            child: ColoredBox(
                              color: context.colors.listTileBackground.withValues(alpha: 0.5),
                              child: PopupMenuButton<VoidCallback>(
                                menuPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                position: PopupMenuPosition.under,
                                offset: const Offset(0, 8),
                                elevation: 0,
                                color: context.colors.listTileBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                onSelected: (action) => action(),
                                itemBuilder: (context) => [
                                  ///
                                  /// COPY
                                  ///
                                  PopupMenuItem<VoidCallback>(
                                    value: () {
                                      Navigator.of(context).pop();
                                      widget.onCopyPressed();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PhosphorIcon(
                                          PhosphorIconsBold.copy,
                                          color: context.colors.protein,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Copy',
                                            style: TextStyle(
                                              fontFamily: 'Epilogue',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.text,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ///
                                  /// EDIT
                                  ///
                                  PopupMenuItem<VoidCallback>(
                                    value: () {
                                      Navigator.of(context).pop();
                                      widget.onEditPressed();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PhosphorIcon(
                                          PhosphorIconsBold.pencilSimple,
                                          color: context.colors.carbs,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Edit',
                                            style: TextStyle(
                                              fontFamily: 'Epilogue',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.text,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ///
                                  /// DELETE
                                  ///
                                  PopupMenuItem<VoidCallback>(
                                    value: () {
                                      Navigator.of(context).pop();
                                      widget.onDeletePressed();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PhosphorIcon(
                                          PhosphorIconsBold.trash,
                                          color: context.colors.delete,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontFamily: 'Epilogue',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.text,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                icon: const PhosphorIcon(
                                  PhosphorIconsBold.dotsThreeOutline,
                                  size: 22,
                                ),
                                style: IconButton.styleFrom(
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: context.colors.text,
                                ),
                              ),
                            ),
                          ),
                        ),

                        ///
                        /// CLOSE BUTTON
                        ///
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 16,
                              sigmaY: 16,
                            ),
                            child: ColoredBox(
                              color: context.colors.listTileBackground.withValues(alpha: 0.5),
                              child: IconButton(
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
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: context.colors.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          ///
          /// TITLE
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
                    begin: Offset(0, 10),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    mealName,
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
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          ///
          /// SUBTITLE
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
                    begin: Offset(0, 10),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.animation,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: Text.rich(
                  TextSpan(
                    text: getDateString(
                      date: createdAt,
                      dateFormat: 'EEEE, dd MMM',
                    ),
                    children: [
                      WidgetSpan(
                        child: PhosphorIcon(
                          PhosphorIconsBold.dotOutline,
                          size: 16,
                          color: context.colors.text,
                        ),
                      ),
                      TextSpan(
                        text: getDateString(
                          date: createdAt,
                          dateFormat: 'HH:mm',
                          useTodayYesterdayTomorrow: false,
                        ),
                      ),
                    ],
                  ),
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
          /// NUTRITION TITLE
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
          /// CALORIES & NUTRITION
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(listTileRadius),
                    color: context.colors.listTileBackground.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      /// CALORIES
                      ///
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          ///
                          /// VALUE
                          ///
                          AnimatedDigitWidget(
                            value: nutrition?.calories != null ? nutrition?.calories.round() : 0,
                            loop: false,
                            duration: BokunSpizeDurations.animation,
                            curve: Curves.easeIn,
                            textStyle: TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 40 * 1.5,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: 1.2,
                              color: context.colors.protein,
                            ),
                          ),

                          ///
                          /// UNIT
                          ///
                          Transform.translate(
                            offset: const Offset(0, 8),
                            child: Text(
                              'kcal',
                              style: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 12 * 1.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                                color: context.colors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      ///
                      /// NUTRITION VALUES
                      ///
                      SizedBox(
                        height: nutritionValuesHeight * 1.5,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = 12.0 * 1.5;
                            final availableWidth = (constraints.maxWidth - (spacing * 2)).clamp(0.0, constraints.maxWidth).toDouble();

                            return Row(
                              spacing: spacing,
                              children: [
                                ///
                                /// PROTEIN
                                ///
                                AnimatedNutritionBar(
                                  height: nutritionValuesHeight * 1.5,
                                  width: availableWidth * proteinBarWeight / totalBarWeight,
                                  progress: protein > 0 ? 1.0 : 0.0,
                                  color: context.colors.protein,
                                ),

                                ///
                                /// CARBS
                                ///
                                AnimatedNutritionBar(
                                  height: nutritionValuesHeight * 1.5,
                                  width: availableWidth * carbsBarWeight / totalBarWeight,
                                  progress: carbs > 0 ? 1.0 : 0.0,
                                  color: context.colors.carbs,
                                ),

                                ///
                                /// FATS
                                ///
                                AnimatedNutritionBar(
                                  height: nutritionValuesHeight * 1.5,
                                  width: availableWidth * fatBarWeight / totalBarWeight,
                                  progress: fat > 0 ? 1.0 : 0.0,
                                  color: context.colors.fat,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 6 * 1.5),

                      ///
                      /// NUTRITION TEXT
                      ///
                      Row(
                        children: [
                          ///
                          /// PROTEIN
                          ///
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 7 * 1.5,
                                  width: 7 * 1.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colors.protein,
                                  ),
                                ),
                                const SizedBox(width: 4 * 1.5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///
                                    /// TITLE
                                    ///
                                    Text(
                                      'Protein'.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 8 * 1.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        letterSpacing: 0.4,
                                        color: context.colors.text,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),

                                    ///
                                    /// VALUE
                                    ///
                                    AnimatedOpacity(
                                      opacity: protein == 0 ? 0 : 1,
                                      duration: BokunSpizeDurations.animation,
                                      curve: Curves.easeIn,
                                      child: buildNutritionValue(
                                        context,
                                        value: protein,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          ///
                          /// CARBS
                          ///
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 7 * 1.5,
                                  width: 7 * 1.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colors.carbs,
                                  ),
                                ),
                                const SizedBox(width: 4 * 1.5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///
                                    /// TITLE
                                    ///
                                    Text(
                                      'Carbs'.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 8 * 1.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        letterSpacing: 0.4,
                                        color: context.colors.text,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),

                                    ///
                                    /// VALUE
                                    ///
                                    AnimatedOpacity(
                                      opacity: carbs == 0 ? 0 : 1,
                                      duration: BokunSpizeDurations.animation,
                                      curve: Curves.easeIn,
                                      child: buildNutritionValue(
                                        context,
                                        value: carbs,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          ///
                          /// FATS
                          ///
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 7 * 1.5,
                                  width: 7 * 1.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colors.fat,
                                  ),
                                ),
                                const SizedBox(width: 4 * 1.5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///
                                    /// TITLE
                                    ///
                                    Text(
                                      'Fats'.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 8 * 1.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        letterSpacing: 0.4,
                                        color: context.colors.text,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),

                                    ///
                                    /// VALUE
                                    ///
                                    AnimatedOpacity(
                                      opacity: fat == 0 ? 0 : 1,
                                      duration: BokunSpizeDurations.animation,
                                      curve: Curves.easeIn,
                                      child: buildNutritionValue(
                                        context,
                                        value: fat,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

          if (foods?.isNotEmpty ?? false) ...[
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
                  delay: BokunSpizeDurations.stateTransitionStagger * 6,
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
                  delay: BokunSpizeDurations.stateTransitionStagger * (7 + index.clamp(0, 4)),
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
                  child: ViewMealFoodListTile(
                    food: food,
                  ),
                );
              },
            ),
          ],

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

  Widget buildNutritionValue(
    BuildContext context, {
    required double value,
  }) {
    final formattedValue = formatNutritionValue(value)!;
    final decimalIndex = formattedValue.indexOf('.');

    return AnimatedDigitWidget(
      value: num.parse(formattedValue),
      fractionDigits: decimalIndex < 0 ? 0 : formattedValue.length - decimalIndex - 1,
      suffix: 'g',
      loop: false,
      duration: BokunSpizeDurations.animation,
      curve: Curves.easeIn,
      textStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 8 * 1.5,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.4,
        color: context.colors.text,
      ),
    );
  }
}
