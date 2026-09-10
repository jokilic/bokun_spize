import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';
import '../constants/durations.dart';
import '../models/meal/food.dart';
import '../models/meal/nutrition.dart';
import '../util/format.dart';
import '../util/parse.dart';
import '../util/spacing.dart';
import 'text_field_widget.dart';

class AddFoodSheet extends StatefulWidget {
  final Food? passedFood;

  const AddFoodSheet({
    this.passedFood,
  });

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  var validation = false;

  late final nameTextEditingController = TextEditingController();
  late final nameFocusNode = FocusNode();

  late final quantityTextEditingController = TextEditingController();
  late final quantityFocusNode = FocusNode();
  late final unitTextEditingController = TextEditingController();
  late final unitFocusNode = FocusNode();

  late final caloriesTextEditingController = TextEditingController();
  late final caloriesFocusNode = FocusNode();

  late final proteinTextEditingController = TextEditingController();
  late final proteinFocusNode = FocusNode();
  late final carbsTextEditingController = TextEditingController();
  late final carbsFocusNode = FocusNode();
  late final fatsTextEditingController = TextEditingController();
  late final fatsFocusNode = FocusNode();

  /// Initializes the food fields and registers validation listeners
  @override
  void initState() {
    super.initState();

    /// Update [TextEditingController] text
    nameTextEditingController.text = widget.passedFood?.name ?? '';

    if ((widget.passedFood?.quantity ?? 0) > 0) {
      quantityTextEditingController.text =
          formatNutritionValue(
            widget.passedFood?.quantity,
          ) ??
          '';
    }

    unitTextEditingController.text = widget.passedFood?.unit ?? '';

    if ((widget.passedFood?.nutrition.calories ?? 0) > 0) {
      caloriesTextEditingController.text =
          formatNutritionValue(
            widget.passedFood!.nutrition.calories,
          ) ??
          '';
    }

    if ((widget.passedFood?.nutrition.protein ?? 0) > 0) {
      proteinTextEditingController.text =
          formatNutritionValue(
            widget.passedFood?.nutrition.protein,
          ) ??
          '';
    }

    if ((widget.passedFood?.nutrition.carbs ?? 0) > 0) {
      carbsTextEditingController.text =
          formatNutritionValue(
            widget.passedFood?.nutrition.carbs,
          ) ??
          '';
    }

    if ((widget.passedFood?.nutrition.fat ?? 0) > 0) {
      fatsTextEditingController.text =
          formatNutritionValue(
            widget.passedFood?.nutrition.fat,
          ) ??
          '';
    }

    /// Add validation listener to [TextEditingController]
    nameTextEditingController.addListener(triggerValidation);

    /// Trigger validation
    triggerValidation();
  }

  @override
  void dispose() {
    nameTextEditingController
      ..removeListener(triggerValidation)
      ..dispose();

    /// Dispose [TextEditingControllers]
    quantityTextEditingController.dispose();
    unitTextEditingController.dispose();
    caloriesTextEditingController.dispose();
    proteinTextEditingController.dispose();
    carbsTextEditingController.dispose();
    fatsTextEditingController.dispose();

    /// Dispose [FocusNodes]
    nameFocusNode.dispose();
    quantityFocusNode.dispose();
    unitFocusNode.dispose();
    caloriesFocusNode.dispose();
    proteinFocusNode.dispose();
    carbsFocusNode.dispose();
    fatsFocusNode.dispose();

    super.dispose();
  }

  /// Checks if validation passed
  void triggerValidation() => setState(
    () => validation = nameTextEditingController.text.trim().isNotEmpty,
  );

  @override
  Widget build(BuildContext context) => ClipRRect(
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
                      'Add food',
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
                'Food in your new meal',
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
              child: TextFieldWidget(
                controller: nameTextEditingController,
                focusNode: nameFocusNode,
                onSubmitted: (_) => quantityFocusNode.requestFocus(),
                title: 'Food name',
                hintText: 'What was it?',
                textColor: BokunSpizeColors.black,
                autocorrect: true,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),

        ///
        /// QUANTITY & UNIT TITLE
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
              child: const Text(
                'Serving size',
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
        /// QUANTITY & UNIT
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
              child: Row(
                spacing: 20,
                children: [
                  ///
                  /// QUANTITY
                  ///
                  Expanded(
                    flex: 2,
                    child: TextFieldWidget(
                      controller: quantityTextEditingController,
                      focusNode: quantityFocusNode,
                      onSubmitted: (_) => unitFocusNode.requestFocus(),
                      title: 'Quantity',
                      hintText: '0',
                      textColor: BokunSpizeColors.black,
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  ///
                  /// UNIT
                  ///
                  Expanded(
                    flex: 3,
                    child: TextFieldWidget(
                      controller: unitTextEditingController,
                      focusNode: unitFocusNode,
                      onSubmitted: (_) => caloriesFocusNode.requestFocus(),
                      title: 'Unit',
                      hintText: 'grams',
                      textColor: BokunSpizeColors.black,
                      textCapitalization: TextCapitalization.none,
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
        /// NUTRITION TITLE
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
              child: TextFieldWidget(
                controller: caloriesTextEditingController,
                focusNode: caloriesFocusNode,
                onSubmitted: (_) => proteinFocusNode.requestFocus(),
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
              delay: BokunSpizeDurations.stateTransitionStagger * 8,
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
                      controller: proteinTextEditingController,
                      focusNode: proteinFocusNode,
                      onSubmitted: (_) => carbsFocusNode.requestFocus(),
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
                    child: TextFieldWidget(
                      controller: carbsTextEditingController,
                      focusNode: carbsFocusNode,
                      onSubmitted: (_) => fatsFocusNode.requestFocus(),
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
                    child: TextFieldWidget(
                      controller: fatsTextEditingController,
                      focusNode: fatsFocusNode,
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
        /// SAVE BUTTON
        ///
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
          sliver: SliverToBoxAdapter(
            child: Animate(
              delay: BokunSpizeDurations.stateTransitionStagger * 9,
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
                      ? () {
                          /// Generate instance of [Food]
                          final food = Food(
                            name: nameTextEditingController.text.trim(),
                            quantity: parseNumberForFood(
                              quantityTextEditingController.text.trim(),
                            ),
                            unit: unitTextEditingController.text.trim(),
                            nutrition: Nutrition(
                              calories: parseNumberForFood(
                                caloriesTextEditingController.text.trim(),
                              ),
                              protein: parseNumberForFood(
                                proteinTextEditingController.text.trim(),
                              ),
                              carbs: parseNumberForFood(
                                carbsTextEditingController.text.trim(),
                              ),
                              fat: parseNumberForFood(
                                fatsTextEditingController.text.trim(),
                              ),
                            ),
                          );

                          /// Dismiss sheet and return `food`
                          Navigator.of(context).pop(food);
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
                  ),
                  child: const Text(
                    'Add to meal',
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
