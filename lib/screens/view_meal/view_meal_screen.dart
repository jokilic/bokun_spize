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
import '../../util/spacing.dart';
import '../../widgets/meal_image.dart';
import 'view_meal_controller.dart';

// TODO: Implement proper staggered animations, like in other screens

class ViewMealScreen extends WatchingStatefulWidget {
  final Meal passedMeal;

  const ViewMealScreen({
    required this.passedMeal,
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
    final emoji = widget.passedMeal.emoji;
    final imageStoragePath = widget.passedMeal.imageStoragePath;
    final createdAt = widget.passedMeal.createdAt;
    final nutrition = widget.passedMeal.nutrition;

    final hasError = widget.passedMeal.errors?.isNotEmpty ?? false;

    final primaryColor = getCalorieValueColor(
      nutrition: widget.passedMeal.nutrition,
      context: context,
    );

    final imageBackgroundColor = hasError ? context.colors.delete : widget.passedMeal.color ?? primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: ColoredBox(
        color: context.colors.scaffoldBackground,
        child: Animate(
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
            ScaleEffect(
              begin: Offset(0.985, 0.985),
              end: Offset(1, 1),
              alignment: Alignment.topCenter,
              duration: BokunSpizeDurations.stateTransition,
              curve: Curves.easeOutCubic,
            ),
          ],
          child: Scaffold(
            body: SafeArea(
              top: false,
              bottom: false,
              child: AutofillGroup(
                child: CustomScrollView(
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
                            child: imageStoragePath != null && showImageMealListTile
                                ? MealImage(
                                    imageStoragePath: imageStoragePath,
                                    height: 400,
                                    width: double.infinity,
                                    errorWidget: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(listTileRadius),
                                      ),
                                      height: 400,
                                      width: double.infinity,
                                      child: PhosphorIcon(
                                        PhosphorIconsBold.warningOctagon,
                                        size: 56,
                                        color: context.colors.delete,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 400,
                                    width: double.infinity,
                                    color: imageBackgroundColor,
                                    child: hasError
                                        ? PhosphorIcon(
                                            PhosphorIconsBold.warningOctagon,
                                            color: context.colors.listTileBackground,
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
                    /// CALORIES
                    ///
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
                      sliver: SliverToBoxAdapter(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            ///
                            /// VALUE
                            ///
                            // TODO: Handle if null
                            AnimatedDigitWidget(
                              value: nutrition?.calories.round(),
                              loop: false,
                              curve: Curves.easeIn,
                              duration: BokunSpizeDurations.animation,
                              textStyle: TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 56,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                  color: context.colors.text,
                                ),
                              ),
                            ),
                          ],
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
            ),
          ),
        ),
      ),
    );
  }
}
