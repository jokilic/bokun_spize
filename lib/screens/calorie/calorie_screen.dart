import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../theme/extensions.dart';
import '../../constants/durations.dart';
import '../../models/activity_level.dart';
import '../../models/calorie_goal.dart';
import '../../models/sex.dart';
import '../../services/hive_service.dart';
import '../../theme/colors.dart';
import '../../util/color.dart';
import '../../util/dependencies.dart';
import '../../widgets/bokun_spize_app_bar.dart';
import '../../widgets/bokun_spize_text_field.dart';
import 'calorie_controller.dart';

class CalorieScreen extends WatchingStatefulWidget {
  @override
  State<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends State<CalorieScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<CalorieController>(
      () => CalorieController(
        hive: getIt.get<HiveService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<CalorieController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calorieController = getIt.get<CalorieController>();

    final calorieState = watchIt<CalorieController>().value;
    final userMetrics = watchIt<HiveService>().value.userMetrics;

    return Scaffold(
      body: CustomScrollView(
        controller: calorieController.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          ///
          /// APP BAR
          ///
          BokunSpizeAppBar(
            smallTitle: 'Izračun kalorija',
            bigTitle: 'Izračun kalorija',
            bigSubtitle: 'Dnevna potrošnja energije',
            leadingWidget: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                highlightColor: context.colors.buttonBackground,
              ),
              icon: PhosphorIcon(
                PhosphorIcons.arrowLeft(
                  PhosphorIconsStyle.duotone,
                ),
                color: context.colors.text,
                duotoneSecondaryColor: context.colors.buttonPrimary,
                size: 28,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// MAINTENANCE CALORIES
          ///
          if (userMetrics != null) ...[
            ///
            /// MAINTENANCE CALORIES TITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Dnevni unos kalorija',
                    style: context.textStyles.homeTitle,
                  ),
                ),
              ),
            ),

            ///
            /// MAINTENANCE CALORIES
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              sliver: SliverToBoxAdapter(
                child: Text.rich(
                  TextSpan(
                    text: userMetrics.dailyCalorieGoal.toStringAsFixed(0),
                    children: [
                      TextSpan(
                        text: 'kcal',
                        style: context.textStyles.maintenanceCaloriesKcal,
                      ),
                    ],
                  ),
                  style: context.textStyles.maintenanceCaloriesValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            ///
            /// MAINTENANCE CALORIES SUBTITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Broj kalorija koje bi trebao dnevno unositi za odabrani kalorijski plan.',
                  style: context.textStyles.homeMealNote,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            ///
            /// TDEE TITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2),
                  child: Text(
                    'Dnevna potrošnja',
                    style: context.textStyles.homeTitle,
                  ),
                ),
              ),
            ),

            ///
            /// TDEE CALORIES
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              sliver: SliverToBoxAdapter(
                child: Text.rich(
                  TextSpan(
                    text: userMetrics.tdee.toStringAsFixed(0),
                    children: [
                      TextSpan(
                        text: 'kcal',
                        style: context.textStyles.maintenanceCaloriesKcalSmall,
                      ),
                    ],
                  ),
                  style: context.textStyles.maintenanceCaloriesValueSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 2),
            ),

            ///
            /// TDEE SUBTITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Broj kalorija koje potrošiš dnevno, ovisno o tvojim mjerama i aktivnostima.',
                  style: context.textStyles.homeMealNote,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            ///
            /// BMR TITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2),
                  child: Text(
                    'Bazalna potrošnja',
                    style: context.textStyles.homeTitle,
                  ),
                ),
              ),
            ),

            ///
            /// BMR CALORIES
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              sliver: SliverToBoxAdapter(
                child: Text.rich(
                  TextSpan(
                    text: userMetrics.bmr.toStringAsFixed(0),
                    children: [
                      TextSpan(
                        text: 'kcal',
                        style: context.textStyles.maintenanceCaloriesKcalSmall,
                      ),
                    ],
                  ),
                  style: context.textStyles.maintenanceCaloriesValueSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 2),
            ),

            ///
            /// BMR SUBTITLE
            ///
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Broj kalorija koje potrošiš dnevno u mirovanju, poput disanja, rada srca, održavanja temperature i slično.',
                  style: context.textStyles.homeMealNote,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],

          ///
          /// SEX TITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Spol',
                  style: context.textStyles.homeTitle,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// SEX VALUES
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                spacing: 28,
                children: Sex.values.map(
                  (sex) {
                    final isActive = calorieState.sex == sex;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: isActive ? context.colors.buttonPrimary : context.colors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(100),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              calorieController
                                ..updateState(
                                  sex: sex,
                                )
                                ..triggerValidation();
                            },
                            highlightColor: context.colors.listTileBackground,
                            borderRadius: BorderRadius.circular(100),
                            child: AnimatedContainer(
                              duration: BokunSpizeDurations.animation,
                              curve: Curves.easeIn,
                              decoration: BoxDecoration(
                                color: isActive ? context.colors.buttonPrimary : context.colors.scaffoldBackground,
                                border: Border.all(
                                  color: isActive ? context.colors.buttonPrimary : context.colors.text,
                                  width: 1.5,
                                ),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: PhosphorIcon(
                                sex.icon,
                                color: getWhiteOrBlackColor(
                                  backgroundColor: isActive ? context.colors.buttonPrimary : context.colors.scaffoldBackground,
                                  whiteColor: BokunSpizeColors.darkThemeText,
                                  blackColor: BokunSpizeColors.lightThemeText,
                                ),
                                duotoneSecondaryColor: context.colors.buttonPrimary,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sex.name,
                          style: context.textStyles.homeMealNote,
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          ///
          /// AGE TITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Godine',
                  style: context.textStyles.homeTitle,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// TEXT FIELD
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: BokunSpizeTextField(
                controller: calorieController.ageTextEditingController,
                labelText: 'Koliko imaš godina?',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          ///
          /// HEIGHT TITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Visina',
                  style: context.textStyles.homeTitle,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// TEXT FIELD
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: BokunSpizeTextField(
                controller: calorieController.heightTextEditingController,
                labelText: 'Koliko si visok?',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                suffixText: 'cm',
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          ///
          /// WEIGHT TITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Težina',
                  style: context.textStyles.homeTitle,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// TEXT FIELD
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: BokunSpizeTextField(
                controller: calorieController.weightTextEditingController,
                labelText: 'Koliko si težak?',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                suffixText: 'kg',
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          ///
          /// ACTIVITY TITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'Tjelesna aktivnost',
                  style: context.textStyles.homeTitle,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// ACTIVITIES
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ActivityLevel.values.map(
                  (activityLevel) {
                    final isActive = calorieState.activityLevel == activityLevel;

                    return Material(
                      color: isActive ? context.colors.listTileBackground : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          calorieController
                            ..updateState(
                              activityLevel: activityLevel,
                            )
                            ..triggerValidation();
                        },
                        highlightColor: context.colors.listTileBackground,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ///
                              /// CHECKBOX
                              ///
                              Material(
                                color: context.colors.buttonPrimary,
                                borderRadius: BorderRadius.circular(100),
                                child: AnimatedContainer(
                                  duration: BokunSpizeDurations.animation,
                                  curve: Curves.easeIn,
                                  decoration: BoxDecoration(
                                    color: isActive ? context.colors.buttonPrimary : context.colors.scaffoldBackground,
                                    border: Border.all(
                                      color: isActive ? context.colors.buttonPrimary : context.colors.text,
                                      width: 1.5,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: PhosphorIcon(
                                    PhosphorIcons.check(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    color: isActive
                                        ? getWhiteOrBlackColor(
                                            backgroundColor: isActive ? context.colors.buttonPrimary : context.colors.scaffoldBackground,
                                            whiteColor: BokunSpizeColors.darkThemeText,
                                            blackColor: BokunSpizeColors.lightThemeText,
                                          )
                                        : Colors.transparent,
                                    duotoneSecondaryColor: isActive ? context.colors.buttonPrimary : Colors.transparent,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              ///
                              /// TEXT
                              ///
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///
                                  /// NAME
                                  ///
                                  Text(
                                    activityLevel.name,
                                    style: context.textStyles.homeTitleBold,
                                  ),
                                  const SizedBox(height: 4),

                                  ///
                                  /// DESCRIPTION
                                  ///
                                  Text(
                                    activityLevel.description,
                                    style: context.textStyles.homeMealNote,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          ///
          /// CALORIE GOAL TITLE
          ///
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 2, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'Kalorijski plan',
                  style: context.textStyles.homeTitle,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// CALORIE GOAL
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: CalorieGoal.values.map(
                  (calorieGoal) {
                    final isActive = calorieState.calorieGoal == calorieGoal;

                    return Material(
                      color: isActive ? context.colors.listTileBackground : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          calorieController
                            ..updateState(
                              calorieGoal: calorieGoal,
                            )
                            ..triggerValidation();
                        },
                        highlightColor: context.colors.listTileBackground,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ///
                              /// CHECKBOX
                              ///
                              Material(
                                color: context.colors.buttonPrimary,
                                borderRadius: BorderRadius.circular(100),
                                child: AnimatedContainer(
                                  duration: BokunSpizeDurations.animation,
                                  curve: Curves.easeIn,
                                  decoration: BoxDecoration(
                                    color: isActive ? context.colors.buttonPrimary : context.colors.scaffoldBackground,
                                    border: Border.all(
                                      color: isActive ? context.colors.buttonPrimary : context.colors.text,
                                      width: 1.5,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: PhosphorIcon(
                                    PhosphorIcons.check(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    color: isActive
                                        ? getWhiteOrBlackColor(
                                            backgroundColor: isActive ? context.colors.buttonPrimary : context.colors.scaffoldBackground,
                                            whiteColor: BokunSpizeColors.darkThemeText,
                                            blackColor: BokunSpizeColors.lightThemeText,
                                          )
                                        : Colors.transparent,
                                    duotoneSecondaryColor: isActive ? context.colors.buttonPrimary : Colors.transparent,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              ///
                              /// TEXT
                              ///
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///
                                  /// NAME
                                  ///
                                  Text(
                                    calorieGoal.name,
                                    style: context.textStyles.homeTitleBold,
                                  ),
                                  const SizedBox(height: 4),

                                  ///
                                  /// DESCRIPTION
                                  ///
                                  Text(
                                    calorieGoal.description,
                                    style: context.textStyles.homeMealNote,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),

      ///
      /// SAVE BUTTON
      ///
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: calorieState.validationPassed
                ? () {
                    HapticFeedback.lightImpact();

                    /// Save new `userMetrics` in [Hive]
                    calorieController.onSavePressed(context);
                  }
                : null,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.fromLTRB(
                24,
                28,
                24,
                MediaQuery.paddingOf(context).bottom + 12,
              ),
              backgroundColor: context.colors.buttonPrimary,
              foregroundColor: getWhiteOrBlackColor(
                backgroundColor: context.colors.buttonPrimary,
                whiteColor: BokunSpizeColors.darkThemeText,
                blackColor: BokunSpizeColors.lightThemeText,
              ),
              overlayColor: context.colors.listTileBackground,
              disabledBackgroundColor: context.colors.disabledBackground,
              disabledForegroundColor: context.colors.disabledText,
            ),
            child: Text(
              'Spremi'.toUpperCase(),
            ),
          ),
        ),
      ),
    );
  }
}
