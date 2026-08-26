import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../models/meal/meal.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import '../../widgets/text_field_widget.dart';
import 'meal_controller.dart';

class MealScreen extends WatchingStatefulWidget {
  final String mealId;
  final Meal? passedMeal;
  final bool isCopyingMeal;

  const MealScreen({
    required this.mealId,
    required this.passedMeal,
    required this.isCopyingMeal,
  });

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<MealController>(
      () => MealController(),
      instanceName: widget.mealId,
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<MealController>(
      instanceName: widget.mealId,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final mealController = getIt.get<MealController>(
      instanceName: widget.mealId,
    );

    /// User data from `Firebase`
    final userName = firebaseService.userName;

    /// Reference to `state`
    final state = watchIt<MealController>(
      instanceName: widget.mealId,
    ).value;

    // final activeDate = state.activeDate;
    // final error = state.error;
    // final isLoading = state.isLoading;
    // final meals = state.meals;

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///
                /// TITLE
                ///
                const Expanded(
                  child: Text(
                    'Log meal',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: 1,
                      color: BokunSpizeColors.black,
                    ),
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
                    disabledBackgroundColor: BokunSpizeColors.grey,
                    disabledForegroundColor: BokunSpizeColors.black,
                  ),
                ),
              ],
            ),

            ///
            /// SUBTITLE
            ///
            const Text(
              'Write details about your meal',
              style: TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: BokunSpizeColors.black,
              ),
            ),
            const SizedBox(height: 20),

            ///
            /// TEXT FIELD
            ///
            TextFieldWidget(
              controller: TextEditingController(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              onSubmitted: (_) {},
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              minLines: 5,
              maxLines: null,
              borderRadius: listTileRadius,
              hintWidget: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Describe your meal'.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: BokunSpizeColors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What did you eat?',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: BokunSpizeColors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              textStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: BokunSpizeColors.black,
              ),
            ),
            const SizedBox(height: 20),

            ///
            /// IMAGE
            ///
            Container(
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Trigger camera
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
                          disabledBackgroundColor: BokunSpizeColors.grey,
                          disabledForegroundColor: BokunSpizeColors.black,
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
                          // TODO: Trigger gallery
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
                          disabledBackgroundColor: BokunSpizeColors.grey,
                          disabledForegroundColor: BokunSpizeColors.black,
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
            const SizedBox(height: 20),

            ///
            /// DATE
            ///
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(listTileRadius),
                color: BokunSpizeColors.white.withValues(alpha: 0.5),
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
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
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
            const SizedBox(height: 20),

            ///
            /// TIME
            ///
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(listTileRadius),
                color: BokunSpizeColors.white.withValues(alpha: 0.5),
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
                      const Text(
                        '12:30',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
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

            const SizedBox(height: 28),

            ///
            /// SAVE BUTTON
            ///
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save meal
                  Navigator.of(context).pop();
                },
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
                child: const Text('Log meal'),
              ),
            ),

            ///
            /// BOTTOM SPACING
            ///
            SizedBox(
              height: MediaQuery.paddingOf(context).bottom + 16,
            ),
          ],
        ),
      ),
    );
  }
}
