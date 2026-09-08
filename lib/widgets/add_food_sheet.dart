import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';
import '../constants/durations.dart';
import '../models/meal/food.dart';
import '../models/meal/nutrition.dart';
import '../util/parse.dart';
import '../util/spacing.dart';
import 'text_field_title_widget.dart';

// TODO: Implement animations like in other sheet, e.g. [CalendarSheet] or [ManualAddMealScreen]

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

  // TODO: Also add FocusNodes and handle accordingly

  late final nameTextEditingController = TextEditingController();

  late final quantityTextEditingController = TextEditingController();
  late final unitTextEditingController = TextEditingController();

  late final caloriesTextEditingController = TextEditingController();

  late final proteinTextEditingController = TextEditingController();
  late final carbsTextEditingController = TextEditingController();
  late final fatsTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// Update [TextEditingController] text
    nameTextEditingController.text = widget.passedFood?.name ?? '';
    // TODO: `passedFood` can exist in the scenario of modifying that Food, can you fill out other [TextEditingControllers] with those values, like name is filled above

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

    quantityTextEditingController.dispose();
    unitTextEditingController.dispose();
    caloriesTextEditingController.dispose();
    proteinTextEditingController.dispose();
    carbsTextEditingController.dispose();
    fatsTextEditingController.dispose();

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
          child: SizedBox(height: 40),
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
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),

        ///
        /// TITLE
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
              child: TextFieldTitleWidget(
                textEditingController: nameTextEditingController,
                focusNode: FocusNode(),
                // focusNode: mealController.caloriesFocusNode,
                // onSubmitted: (_) => mealController.proteinFocusNode.requestFocus(),
                title: 'Food name',
                textColor: BokunSpizeColors.black,
                autocorrect: true,
                hintText: 'Chocolate',
                hintStyle: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: BokunSpizeColors.black.withValues(alpha: 0.5),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: BokunSpizeColors.black,
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 28),
        ),

        ///
        /// QUANTITY & UNIT TITLE
        ///
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: marginHorizontal),
          sliver: SliverToBoxAdapter(
            child: Text(
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
        const SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ),

        ///
        /// QUANTITY & UNIT
        ///
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
          sliver: SliverToBoxAdapter(
            child: Row(
              spacing: 20,
              children: [
                ///
                /// QUANTITY
                ///
                Expanded(
                  flex: 2,
                  child: TextFieldTitleWidget(
                    textEditingController: quantityTextEditingController,
                    focusNode: FocusNode(),
                    // focusNode: mealController.proteinFocusNode,
                    // onSubmitted: (_) => unit.requestFocus(),
                    title: 'Quantity',
                    hintText: '0',
                    textColor: BokunSpizeColors.black,
                    keyboardType: TextInputType.number,
                    hintStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BokunSpizeColors.black.withValues(alpha: 0.5),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BokunSpizeColors.black,
                    ),
                  ),
                ),

                ///
                /// UNIT
                ///
                Expanded(
                  flex: 3,
                  child: TextFieldTitleWidget(
                    textEditingController: unitTextEditingController,
                    focusNode: FocusNode(),
                    // focusNode: mealController.proteinFocusNode,
                    // onSubmitted: (_) => unit.requestFocus(),
                    title: 'Unit',
                    hintText: 'grams',
                    textColor: BokunSpizeColors.black,
                    hintStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BokunSpizeColors.black.withValues(alpha: 0.5),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BokunSpizeColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 28),
        ),

        ///
        /// NUTRITION TITLE
        ///
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: marginHorizontal),
          sliver: SliverToBoxAdapter(
            child: Text(
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
        const SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ),

        ///
        /// CALORIES
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
              child: TextFieldTitleWidget(
                textEditingController: caloriesTextEditingController,
                focusNode: FocusNode(),
                // focusNode: mealController.caloriesFocusNode,
                // onSubmitted: (_) => mealController.proteinFocusNode.requestFocus(),
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
                  /// PROTEIN
                  ///
                  Expanded(
                    child: TextFieldTitleWidget(
                      textEditingController: proteinTextEditingController,
                      focusNode: FocusNode(),
                      // focusNode: mealController.caloriesFocusNode,
                      // onSubmitted: (_) => mealController.proteinFocusNode.requestFocus(),
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
                      textEditingController: carbsTextEditingController,
                      focusNode: FocusNode(),
                      // focusNode: mealController.caloriesFocusNode,
                      // onSubmitted: (_) => mealController.proteinFocusNode.requestFocus(),
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
                      textEditingController: fatsTextEditingController,
                      focusNode: FocusNode(),
                      // focusNode: mealController.caloriesFocusNode,
                      // onSubmitted: (_) => mealController.proteinFocusNode.requestFocus(),
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
          child: SizedBox(height: 40),
        ),

        ///
        /// SAVE BUTTON
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
