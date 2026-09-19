import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../services/firebase_service.dart';
import '../../services/speech_to_text_service.dart';
import '../../theme/extensions.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../widgets/text_field_widget.dart';
import 'search_controller.dart';
import 'widgets/search_error.dart';

class SearchScreen extends WatchingStatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<SearchController>(
      () => SearchController(
        firebase: getIt.get<FirebaseService>(),
        speechToText: getIt.get<SpeechToTextService>(),
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

    /// Reference to `state`
    final state = watchIt<SearchController>().value;
    final speechToTextState = watchIt<SpeechToTextService>().value;

    final available = speechToTextState.available;
    final isListening = speechToTextState.isListening;

    return ClipRRect(
      borderRadius: BorderRadius.circular(listTileRadius),
      child: ColoredBox(
        color: context.colors.scaffoldBackground,
        child: CustomScrollView(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
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
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                          'Search meals',
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
                      /// CLOSE BUTTON
                      ///
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.x,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          backgroundColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                          foregroundColor: context.colors.text,
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
                  delay: BokunSpizeDurations.stateTransitionStagger * 2,
                  effects: const [
                    FadeEffect(
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOut,
                    ),
                    MoveEffect(
                      begin: Offset(0, 8),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Text(
                    'Find anything from your journal',
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
            /// TEXT FIELD & SPEECH TO TEXT
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
                      begin: Offset(0, 12),
                      end: Offset.zero,
                      duration: BokunSpizeDurations.animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Stack(
                    children: [
                      ///
                      /// TEXT FIELD
                      ///
                      TextFieldWidget(
                        controller: searchController.textEditingController,
                        focusNode: searchController.focusNode,
                        onChanged: (_) => searchController.stopSpeechToTextIfListening(),
                        onSubmitted: (_) => searchController.searchMeals(),
                        textInputAction: TextInputAction.search,
                        title: 'Search terms',
                        hintText: 'What you need?',
                        textColor: context.colors.text,
                      ),

                      ///
                      /// SPEECH TO TEXT ICON
                      ///
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Animate(
                          onPlay: (controller) {
                            if (isListening) {
                              controller.loop(
                                reverse: true,
                                min: 0.6,
                              );
                            }
                          },
                          effects: [
                            if (isListening)
                              const FadeEffect(
                                duration: BokunSpizeDurations.speechToTextShimmer,
                                curve: Curves.easeIn,
                              ),
                          ],
                          child: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              searchController.onSpeechToTextPressed(
                                locale: 'en',
                                speechToTextAvailable: available,
                              );
                            },
                            icon: const PhosphorIcon(
                              PhosphorIconsBold.microphone,
                              size: 22,
                            ),
                            style: IconButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              backgroundColor: isListening ? context.colors.delete : context.colors.listTileBackground.withValues(alpha: 0.5),
                              foregroundColor: isListening ? context.colors.listTileBackground : context.colors.delete,
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
            /// RESULTS
            ///
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            if (state.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.colors.text,
                    ),
                  ),
                ),
              )
            else if (state.error != null) ...[
              SearchError(error: state.error!),
              SliverToBoxAdapter(
                child: Center(
                  child: TextButton(
                    onPressed: searchController.searchMeals,
                    child: const Text('Try again'),
                  ),
                ),
              ),
            ] else if (state.meals.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(marginHorizontal),
                  child: Text(
                    state.query.characters.length < SearchController.minimumSearchLength ? 'Enter at least 3 characters to search' : 'No meals found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 14,
                      color: context.colors.text.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: state.meals.length,
                itemBuilder: (context, index) {
                  final meal = state.meals[index];

                  return Padding(
                    key: ValueKey(meal.id),
                    padding: const EdgeInsets.symmetric(horizontal: marginHorizontal, vertical: 6),
                    child: ListTile(
                      tileColor: context.colors.listTileBackground.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(listTileRadius),
                      ),
                      leading: Text(meal.emoji ?? '🍽️', style: const TextStyle(fontSize: 28)),
                      title: Text(
                        meal.name ?? meal.originalText ?? 'Meal',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Epilogue', color: context.colors.text),
                      ),
                      subtitle: Text(
                        getDateString(
                          date: meal.createdAt,
                          dateFormat: 'dd MMM yyyy, HH:mm',
                          useTodayYesterdayTomorrow: false,
                        ),
                        style: TextStyle(color: context.colors.text.withValues(alpha: 0.75)),
                      ),
                    ),
                  );
                },
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
    );
  }
}
