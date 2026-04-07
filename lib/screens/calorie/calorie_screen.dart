import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../theme/extensions.dart';
import '../../constants/durations.dart';
import '../../models/activity_level.dart';
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
    final hiveService = getIt.get<HiveService>();

    final userMetrics = watchIt<HiveService>().value.userMetrics;

    return Scaffold(
      body: CustomScrollView(
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
                    final isActive = userMetrics?.sex == sex;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: isActive ? context.colors.buttonPrimary : context.colors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(100),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              hiveService.updateUserMetrics(
                                newSex: sex,
                              );
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
                textInputAction: TextInputAction.next,
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aktivnost',
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
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ActivityLevel.values
                    .map(
                      (activityLevel) => Material(
                        color: context.colors.listTileBackground,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            hiveService.updateUserMetrics(
                              newActivity: activityLevel,
                            );
                          },
                          highlightColor: context.colors.listTileBackground,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                ///
                                /// CHECKBOX
                                ///
                                Material(
                                  color: context.colors.buttonPrimary,
                                  borderRadius: BorderRadius.circular(100),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: PhosphorIcon(
                                      PhosphorIcons.check(
                                        PhosphorIconsStyle.duotone,
                                      ),
                                      color: getWhiteOrBlackColor(
                                        backgroundColor: context.colors.buttonPrimary,
                                        whiteColor: BokunSpizeColors.darkThemeText,
                                        blackColor: BokunSpizeColors.lightThemeText,
                                      ),
                                      duotoneSecondaryColor: context.colors.buttonPrimary,
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
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),
        ],
      ),
    );
  }
}
