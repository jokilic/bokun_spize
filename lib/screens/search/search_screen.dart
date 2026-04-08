import 'dart:async';

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../models/day_header.dart';
import '../../models/meal.dart';
import '../../services/hive_service.dart';
import '../../theme/extensions.dart';
import '../../util/dependencies.dart';
import '../../util/formatting.dart';
import '../../widgets/bokun_spize_app_bar.dart';
import '../../widgets/bokun_spize_list_tile.dart';
import '../../widgets/bokun_spize_text_field.dart';
import 'search_controller.dart';

class SearchScreen extends WatchingStatefulWidget {
  final Future Function(
    BuildContext context, {
    required Meal? passedMeal,
    required bool isCopyingMeal,
  })
  onMealPressed;

  const SearchScreen({
    required this.onMealPressed,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<SearchController>(
      () => SearchController(
        hive: getIt.get<HiveService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<SearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchController = getIt.get<SearchController>();
    final hiveService = getIt.get<HiveService>();

    final state = watchIt<SearchController>().value;

    final items = state.items;
    final isTextFieldEmpty = state.isTextFieldEmpty;

    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        slivers: [
          ///
          /// APP BAR
          ///
          BokunSpizeAppBar(
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
            smallTitle: 'Pretraga',
            bigTitle: 'Pretraga',
            bigSubtitle: 'Pronađi svoje obroke',
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          ///
          /// SEARCH TEXT FIELD
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: BokunSpizeTextField(
                autofocus: true,
                controller: searchController.searchTextEditingController,
                labelText: 'Pretraži',
                keyboardType: TextInputType.text,
                textAlign: TextAlign.left,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 28),
          ),

          ///
          /// MEALS
          ///
          if (items.isNotEmpty)
            SliverList.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
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
                            text: formatNutritionValue(
                              item.amountCalories,
                            ),
                            children: [
                              TextSpan(
                                text: 'kcal',
                                style: context.textStyles.homeDayKcal,
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
                    onLongPressed: () async {
                      /// Trigger [MealScreen]
                      await widget.onMealPressed(
                        context,
                        passedMeal: item,
                        isCopyingMeal: false,
                      );

                      /// Update `state`
                      searchController.updateState();
                    },
                    onDeletePressed: () async {
                      unawaited(
                        HapticFeedback.lightImpact(),
                      );

                      await hiveService.deleteMeal(meal: item);

                      searchController.updateState();
                    },
                    onCopyPressed: () async {
                      unawaited(
                        HapticFeedback.lightImpact(),
                      );

                      /// Trigger [MealScreen]
                      await widget.onMealPressed(
                        context,
                        passedMeal: item,
                        isCopyingMeal: true,
                      );

                      /// Update `state`
                      searchController.updateState();
                    },
                    meal: item,
                  );
                }

                return const SizedBox.shrink();
              },
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.magnifyingGlass(
                        PhosphorIconsStyle.duotone,
                      ),
                      color: context.colors.text,
                      duotoneSecondaryColor: context.colors.buttonPrimary,
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isTextFieldEmpty ? 'Pronađi ono što te zanima' : 'Nije nađen niti jedan obrok',
                      textAlign: TextAlign.center,
                      style: context.textStyles.homeTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTextFieldEmpty ? 'Obroci će se ovdje prikazati' : 'Probaj tražiti nešto drugo',
                      textAlign: TextAlign.center,
                      style: context.textStyles.homeTitle,
                    ),
                  ],
                ),
              ),
            ),

          ///
          /// BOTTOM SPACING
          ///
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }
}
