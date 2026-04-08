import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../constants/durations.dart';
import '../../models/activity_level.dart';
import '../../models/calorie_goal.dart';
import '../../models/sex.dart';
import '../../models/user_metrics.dart';
import '../../services/hive_service.dart';
import '../../util/null_state.dart';

class CalorieController extends ValueNotifier<({bool validationPassed, ActivityLevel? activityLevel, Sex? sex, CalorieGoal? calorieGoal})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final HiveService hive;

  CalorieController({
    required this.hive,
  }) : super(
         (
           validationPassed: false,
           activityLevel: null,
           sex: null,
           calorieGoal: null,
         ),
       );

  ///
  /// VARIABLES
  ///

  late final scrollController = ScrollController();

  late final ageTextEditingController = TextEditingController();

  late final heightTextEditingController = TextEditingController();
  late final weightTextEditingController = TextEditingController();

  ///
  /// INIT
  ///

  void init() {
    /// Get `userMetrics` from [HiveService]
    final userMetrics = hive.getUserMetrics();

    /// Update `state` & [TextEditingControllers] with `userMetrics`
    if (userMetrics != null) {
      updateState(
        activityLevel: userMetrics.activity,
        sex: userMetrics.sex,
        calorieGoal: userMetrics.calorieGoal,
      );

      ageTextEditingController.text = userMetrics.age.toStringAsFixed(0);
      heightTextEditingController.text = userMetrics.height.toStringAsFixed(0);
      weightTextEditingController.text = userMetrics.weight.toStringAsFixed(0);
    }

    /// Add listeners to [TextEditingControllers]
    ageTextEditingController.addListener(triggerValidation);
    heightTextEditingController.addListener(triggerValidation);
    weightTextEditingController.addListener(triggerValidation);

    /// Trigger validation
    triggerValidation();
  }

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    /// Dispose [ScrollController]
    scrollController.dispose();

    /// Dispose [TextEditingControllers]
    ageTextEditingController
      ..removeListener(triggerValidation)
      ..dispose();
    heightTextEditingController
      ..removeListener(triggerValidation)
      ..dispose();
    weightTextEditingController
      ..removeListener(triggerValidation)
      ..dispose();
  }

  ///
  /// METHODS
  ///

  /// Checks if validation passed
  void triggerValidation() {
    final isAgeValidated = int.tryParse(ageTextEditingController.text.trim()) != null;
    final isHeightValidated = double.tryParse(heightTextEditingController.text.trim()) != null;
    final isWeightValidated = double.tryParse(weightTextEditingController.text.trim()) != null;

    final isActivityLevelValidated = value.activityLevel != null;
    final isSexValidated = value.sex != null;
    final isCalorieGoalValidated = value.calorieGoal != null;

    updateState(
      validationPassed: isAgeValidated && isHeightValidated && isWeightValidated && isActivityLevelValidated && isSexValidated && isCalorieGoalValidated,
    );
  }

  /// Triggered when the user presses `Delete` button
  Future<void> onDeletePressed(BuildContext context) async {
    ageTextEditingController.clear();
    heightTextEditingController.clear();
    weightTextEditingController.clear();

    updateState(
      activityLevel: null,
      sex: null,
      calorieGoal: null,
    );

    /// Trigger validation
    triggerValidation();

    /// Delete `userMetrics` from [Hive]
    await hive.deleteUserMetrics();

    /// Dismiss keyboard
    FocusScope.of(context).unfocus();
  }

  /// Triggered when the user presses `Save` button
  Future<void> onSavePressed(BuildContext context) async {
    final age = int.parse(ageTextEditingController.text.trim());
    final height = double.parse(heightTextEditingController.text.trim());
    final weight = double.parse(weightTextEditingController.text.trim());

    /// Generate new `userMetrics`
    final userMetrics = UserMetrics(
      age: age,
      height: height,
      weight: weight,
      activity: value.activityLevel!,
      sex: value.sex!,
      calorieGoal: value.calorieGoal!,
    );

    /// Save `userMetrics` in [Hive]
    await hive.writeUserMetrics(
      newUserMetrics: userMetrics,
    );

    /// Dismiss keyboard
    FocusScope.of(context).unfocus();

    /// Scroll to top
    await scrollController.animateTo(
      0,
      duration: BokunSpizeDurations.animation,
      curve: Curves.easeIn,
    );
  }

  /// Updates `state`
  void updateState({
    bool? validationPassed,
    Object? activityLevel = nullStateNoChange,
    Object? sex = nullStateNoChange,
    Object? calorieGoal = nullStateNoChange,
  }) => value = (
    validationPassed: validationPassed ?? value.validationPassed,
    activityLevel: identical(activityLevel, nullStateNoChange) ? value.activityLevel : activityLevel as ActivityLevel?,
    sex: identical(sex, nullStateNoChange) ? value.sex : sex as Sex?,
    calorieGoal: identical(calorieGoal, nullStateNoChange) ? value.calorieGoal : calorieGoal as CalorieGoal?,
  );
}
