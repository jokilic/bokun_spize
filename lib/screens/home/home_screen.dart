import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final isListening = speechToTextState.isListening;

    final isGenerating = watchIt<AIService>().value.isGenerating;

    final meals = watchIt<HiveService>().value;

    final state = watchIt<HomeController>().value;

    final userWords = state.userWords;
    final aiError = state.aiError;

    return Scaffold(
      backgroundColor: context.colors.scaffoldBackground,
      body: const CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: BouncingScrollPhysics(),
        slivers: [
          ///
          /// APP BAR
          ///
          BokunSpizeAppBar(
            smallTitle: 'Bokun spize 🥗',
            bigTitle: 'Bokun spize 🥗',
            bigSubtitle: 'Tvoj dnevnik prehrane',
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),

          // TODO: List of ListTile meals from Hive
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
