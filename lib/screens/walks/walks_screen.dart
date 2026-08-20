import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../services/firebase_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../widgets/navigation_bar_widget.dart';
import 'walks_controller.dart';
import 'widgets/walks_app_bar.dart';

class WalksScreen extends WatchingStatefulWidget {
  @override
  State<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends State<WalksScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<WalksController>(
      () => WalksController(
        health: Health(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<WalksController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final walksController = getIt.get<WalksController>();

    /// User name
    final userName = firebaseService.userName;

    /// Reference to `state`
    final state = watchIt<WalksController>().value;

    final steps = state.steps ?? 0;
    final stepsTimestamp = state.stepsFetchedAt;

    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(),
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          heroTag: const ValueKey('walks-fab'),
          elevation: 0,
          backgroundColor: BokunSpizeColors.primary,
          foregroundColor: BokunSpizeColors.white,
          splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          shape: const CircleBorder(),
          onPressed: () {
            unawaited(
              HapticFeedback.lightImpact(),
            );
          },
          child: const PhosphorIcon(
            PhosphorIconsBold.plus,
            color: BokunSpizeColors.white,
            size: 32,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ///
            /// APP BAR
            ///
            WalksAppBar(
              title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
              timeString: stepsTimestamp != null
                  ? getDateString(
                      date: stepsTimestamp,
                      dateFormat: 'EEEE, dd.MM.yyyy.',
                    )
                  : 'Vrijeme ne postoji',
              currentSteps: steps,
            ),

            ///
            /// BOTTOM SPACING
            ///
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom + 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
