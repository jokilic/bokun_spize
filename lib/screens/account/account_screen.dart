import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/durations.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/firebase_service.dart';
import '../../theme/extensions.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../widgets/navigation_bar_widget.dart';
import '../meals/meals_controller.dart';
import '../walks/walks_controller.dart';
import '../weights/weights_controller.dart';
import 'account_controller.dart';
import 'widgets/account_app_bar.dart';
import 'widgets/account_list_tile.dart';

// TODO: Staggered animation like other screens & sheets

class AccountScreen extends WatchingStatefulWidget {
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<AccountController>(
      () => AccountController(
        firebase: getIt.get<FirebaseService>(),
      ),
    );
  }

  @override
  void dispose() {
    // unRegisterIfNotDisposed<MealsController>();
    super.dispose();
  }

  /// Cancels user-specific listeners and signs-out
  Future<void> handleLogOut() async {
    unRegisterIfNotDisposed<MealsController>();
    unRegisterIfNotDisposed<WeightsController>();
    unRegisterIfNotDisposed<WalksController>();
    unRegisterIfNotDisposed<AccountController>();

    await getIt.get<FirebaseService>().logOut();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = getIt.get<FirebaseService>();
    final accountController = getIt.get<AccountController>();

    /// Listens to any changes in `userMetrics` from [Firebase]
    final userMetrics = watchStream<FirebaseService, UserMetrics?>(
      (firebaseService) => firebaseService.listenToUserMetrics(),
    ).data;

    final email = firebaseService.userEmail;
    final name = userMetrics?.name;
    // final userPhoto = firebaseService.userPhoto;
    const userPhoto = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/21/Danny_DeVito_by_Gage_Skidmore.jpg/250px-Danny_DeVito_by_Gage_Skidmore.jpg';

    return Scaffold(
      backgroundColor: context.colors.scaffoldBackground,
      bottomNavigationBar: NavigationBarWidget(),
      body: Animate(
        effects: const [
          FadeEffect(
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOut,
          ),
          MoveEffect(
            begin: Offset(0, 18),
            end: Offset.zero,
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOutCubic,
          ),
          ScaleEffect(
            begin: Offset(0.985, 0.985),
            end: Offset(1, 1),
            alignment: Alignment.topCenter,
            duration: BokunSpizeDurations.stateTransition,
            curve: Curves.easeOutCubic,
          ),
        ],
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            slivers: [
              ///
              /// APP BAR
              ///
              AccountAppBar(
                email: email,
                name: name,
                userPhoto: userPhoto,
              ),

              ///
              /// SPACING
              ///
              const SliverToBoxAdapter(
                child: SizedBox(height: 4),
              ),

              ///
              /// USER METRICS
              ///
              AccountListTile(
                onPressed: () {},
                icon: PhosphorIconsBold.personSimple,
                iconBackgroundColor: context.colors.carbs,
                title: 'User metrics',
                subtitle: 'Height, weight, etc.',
              ),

              ///
              /// THEME
              ///
              AccountListTile(
                onPressed: () => accountController.openThemeSheet(context),
                icon: PhosphorIconsBold.palette,
                iconBackgroundColor: context.colors.fat,
                title: 'Theme',
                subtitle: 'App-wide colors',
              ),

              ///
              /// LANGUAGE
              ///
              AccountListTile(
                onPressed: () {},
                icon: PhosphorIconsBold.globeStand,
                iconBackgroundColor: context.colors.protein,
                title: 'Language',
                subtitle: 'App-wide language',
              ),

              ///
              /// LOGOUT
              ///
              AccountListTile(
                onPressed: handleLogOut,
                icon: PhosphorIconsBold.signOut,
                iconBackgroundColor: context.colors.delete,
                title: 'Logout',
                subtitle: 'Sign out of the app',
              ),

              ///
              /// DELETE ACCOUNT
              ///
              AccountListTile(
                onPressed: () {},
                icon: PhosphorIconsBold.trash,
                iconBackgroundColor: context.colors.delete,
                title: 'Delete account',
                subtitle: 'Remove your account',
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
      ),
    );
  }
}
