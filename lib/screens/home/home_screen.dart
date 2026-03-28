import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../services/ai_service.dart';
import '../../services/hive_service.dart';
import '../../services/logger_service.dart';
import '../../services/speech_to_text_service.dart';
import '../../theme/colors.dart';
import '../../theme/extensions.dart';
import '../../util/color.dart';
import '../../util/dependencies.dart';
import '../../widgets/bokun_spize_app_bar.dart';
import 'home_controller.dart';

class HomeScreen extends WatchingStatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<HomeController>(
      () => HomeController(
        logger: getIt.get<LoggerService>(),
        hive: getIt.get<HiveService>(),
        speechToText: getIt.get<SpeechToTextService>(),
        ai: getIt.get<AIService>(),
      ),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<HomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = getIt.get<HomeController>();

    final speechToTextState = watchIt<SpeechToTextService>().value;

    final available = speechToTextState.available;

    final meals = watchIt<HiveService>().value;
    final locale = context.locale.toLanguageTag();

    return Scaffold(
      backgroundColor: context.colors.scaffoldBackground,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        slivers: [
          ///
          /// APP BAR
          ///
          const BokunSpizeAppBar(
            smallTitle: 'Bokun spize 🥗',
            bigTitle: 'Bokun spize 🥗',
            bigSubtitle: 'Tvoj dnevnik prehrane',
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// MEALS
          ///
          if (meals.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              sliver: SliverList.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[meals.length - index - 1];
                  final nutrition = meal.nutrition;
                  final foods = meal.foods
                      .map(
                        (food) => '${food.name} (${food.quantity.toStringAsFixed(food.quantity % 1 == 0 ? 0 : 1)} ${food.unit})',
                      )
                      .join(', ');

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == meals.length - 1 ? 0 : 12,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.listTileBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          meal.name,
                          style: context.textStyles.homeTitleBold,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${DateFormat('d. M. y. HH:mm', locale).format(meal.postedAt)}\n'
                            '${nutrition.calories.toStringAsFixed(0)} kcal • '
                            'P ${nutrition.protein.toStringAsFixed(1)} g • '
                            'U ${nutrition.carbs.toStringAsFixed(1)} g • '
                            'M ${nutrition.fat.toStringAsFixed(1)} g'
                            '${foods.isNotEmpty ? '\n$foods' : ''}',
                            style: context.textStyles.homeTitle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ///
          /// NO MEALS
          ///
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.bowlFood(
                        PhosphorIconsStyle.duotone,
                      ),
                      color: context.colors.text,
                      size: 56,
                      duotoneSecondaryColor: context.colors.buttonPrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nema obroka',
                      textAlign: TextAlign.center,
                      style: context.textStyles.homeTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dodaj neki pritiskom na tipku ispod',
                      textAlign: TextAlign.center,
                      style: context.textStyles.homeTitle,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: available
                ? () async {
                    unawaited(
                      HapticFeedback.lightImpact(),
                    );

                    await homeController.onAddPressed(context);
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
                whiteColor: BokunSpizeColors.lightThemeWhiteBackground,
                blackColor: BokunSpizeColors.lightThemeBlackText,
              ),
              overlayColor: context.colors.buttonBackground,
              disabledBackgroundColor: context.colors.disabledBackground,
              disabledForegroundColor: context.colors.disabledText,
            ),
            child: Text(
              'Dodaj'.toUpperCase(),
            ),
          ),
        ),
      ),
    );
  }
}
