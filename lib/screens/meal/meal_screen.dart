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
              'Write your',
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
              hintText: 'What did you eat?',
              onSubmitted: (_) {},
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              minLines: 4,
              maxLines: null,
              borderRadius: listTileRadius,
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: BokunSpizeColors.black.withValues(alpha: 0.5),
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
            Material(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {},
                highlightColor: Colors.yellow,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedSwitcher(
                    duration: BokunSpizeDurations.animation,
                    reverseDuration: BokunSpizeDurations.animation,
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeIn,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green,
                      ),
                      height: 160,
                      width: double.infinity,
                      child: PhosphorIcon(
                        PhosphorIcons.bowlFood(
                          PhosphorIconsStyle.duotone,
                        ),
                        size: 56,
                        color: Colors.cyan,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
