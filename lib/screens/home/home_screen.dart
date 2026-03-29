import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../models/day_header.dart';
import '../../models/meal.dart';
import '../../services/ai_service.dart';
import '../../services/hive_service.dart';
import '../../services/logger_service.dart';
import '../../services/speech_to_text_service.dart';
import '../../theme/colors.dart';
import '../../theme/extensions.dart';
import '../../util/color.dart';
import '../../util/dependencies.dart';
import '../../widgets/bokun_spize_app_bar.dart';
import '../../widgets/bokun_spize_list_tile.dart';
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
    final hiveService = getIt.get<HiveService>();

    final items = watchIt<HiveService>().value;

    return Scaffold(
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
          /// ITEMS
          ///
          if (items.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(top: 2),
              sliver: SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  ///
                  /// DAY HEADER
                  ///
                  if (item is DayHeader) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(28, index == 0 ? 8 : 28, 28, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ///
                          /// DAY
                          ///
                          Expanded(
                            child: Text(
                              item.label,
                              style: context.textStyles.homeTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          ///
                          /// AMOUNT
                          ///
                          Text.rich(
                            TextSpan(
                              text: item.amountCalories.toStringAsFixed(0),
                              children: [
                                TextSpan(
                                  text: ' ',
                                  style: context.textStyles.homeMealKcal,
                                ),
                                TextSpan(
                                  text: 'kcal',
                                  style: context.textStyles.homeMealKcal,
                                ),
                              ],
                            ),
                            style: context.textStyles.homeTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }

                  ///
                  /// MEAL
                  ///
                  if (item is Meal) {
                    return BokunSpizeListTile(
                      key: ValueKey(item.id),
                      onLongPressed: () {},
                      onDeletePressed: () {
                        HapticFeedback.lightImpact();
                        hiveService.deleteMeal(meal: item);
                      },
                      meal: item,
                    );
                  }

                  return const SizedBox.shrink();
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
            onPressed: () async {
              unawaited(
                HapticFeedback.lightImpact(),
              );

              await homeController.onAddPressed(context);
            },
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
                whiteColor: BokunSpizeColors.whiteBackground,
                blackColor: BokunSpizeColors.black,
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
