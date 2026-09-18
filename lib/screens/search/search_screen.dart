import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../services/firebase_service.dart';
import '../../theme/extensions.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import 'search_controller.dart';
import 'widgets/search_error.dart';

class SearchScreen extends StatefulWidget {
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
      ),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<SearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
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

          // TODO: Content here
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: marginHorizontal * 4,
              vertical: 12,
            ),
            sliver: SliverToBoxAdapter(
              child: Animate(
                effects: const [
                  FadeEffect(
                    duration: BokunSpizeDurations.stateTransition,
                    curve: Curves.easeOut,
                  ),
                  MoveEffect(
                    begin: Offset(0, 24),
                    end: Offset.zero,
                    duration: BokunSpizeDurations.stateTransition,
                    curve: Curves.easeOutCubic,
                  ),
                  ScaleEffect(
                    begin: Offset(0.96, 0.96),
                    end: Offset(1, 1),
                    alignment: Alignment.topCenter,
                    duration: BokunSpizeDurations.stateTransition,
                    curve: Curves.easeOutBack,
                  ),
                ],
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    PhosphorIcon(
                      PhosphorIconsBold.hammer,
                      color: context.colors.fat,
                      size: 88,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Worko in progresso',
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: context.colors.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Be patiento',
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.6,
                        color: context.colors.text.withValues(alpha: 0.75),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
  );
}
