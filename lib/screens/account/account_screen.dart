import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../models/user_metrics/user_metrics.dart';
import '../../services/firebase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/extensions.dart';
import '../../util/app_version.dart';
import '../../util/dependencies.dart';
import '../../util/snackbars.dart';
import '../../util/spacing.dart';
import '../../widgets/navigation_bar_widget.dart';
import '../meals/meals_controller.dart';
import '../walks/walks_controller.dart';
import '../weights/weights_controller.dart';
import 'account_controller.dart';
import 'widgets/account_app_bar.dart';
import 'widgets/account_list_tile.dart';

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
        theme: getIt.get<ThemeService>(),
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

    final state = watchIt<AccountController>().value;

    final theme = state.theme;

    /// Listens to any changes in `userMetrics` from [Firebase]
    final userMetrics = watchStream<FirebaseService, UserMetrics?>(
      (firebaseService) => firebaseService.listenToUserMetrics(),
    ).data;

    final email = firebaseService.userEmail;
    final name = userMetrics?.name;
    final userPhoto = firebaseService.userPhoto;

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
                onEditPressed: () {
                  HapticFeedback.lightImpact();
                  accountController.onEditNamePressed(
                    context,
                    initialName: name,
                  );
                },
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
                animationDelay: BokunSpizeDurations.stateTransitionStagger,
                onPressed: () {},
                icon: PhosphorIconsBold.personSimple,
                iconBackgroundColor: context.colors.carbs,
                title: 'accountUserMetricsTitle'.tr(),
                subtitle: 'accountUserMetricsSubtitle'.tr(),
              ),

              ///
              /// THEME
              ///
              AccountListTile(
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 2,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  accountController.openThemeSheet(
                    context,
                    initialTheme: theme,
                  );
                },
                icon: PhosphorIconsBold.palette,
                iconBackgroundColor: context.colors.fat,
                title: 'theme'.tr(),
                subtitle: 'accountThemeSubtitle'.tr(),
              ),

              ///
              /// LANGUAGE
              ///
              AccountListTile(
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 3,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  accountController.openLanguageSheet(
                    context,
                    initialLanguage: context.locale,
                  );
                },
                icon: PhosphorIconsBold.globeStand,
                iconBackgroundColor: context.colors.protein,
                title: 'language'.tr(),
                subtitle: 'accountLanguageSubtitle'.tr(),
              ),

              ///
              /// CONTACT
              ///
              AccountListTile(
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 4,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // accountController.openContactSheet(context);
                },
                icon: PhosphorIconsBold.globeStand,
                iconBackgroundColor: context.colors.protein,
                title: 'language'.tr(),
                subtitle: 'accountLanguageSubtitle'.tr(),
              ),

              ///
              /// LOGOUT
              ///
              AccountListTile(
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 5,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  handleLogOut();
                },
                icon: PhosphorIconsBold.signOut,
                iconBackgroundColor: context.colors.delete,
                title: 'accountLogoutTitle'.tr(),
                subtitle: 'accountLogoutSubtitle'.tr(),
              ),

              ///
              /// DELETE ACCOUNT
              ///
              AccountListTile(
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 6,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  accountController.openDeleteAccountSheet(
                    context,
                    requiresPassword: firebaseService.authProvider == AuthProvider.email,
                    onHandleDelete: (isDeleted) {
                      if (isDeleted) {
                        handleLogOut();
                      } else if (mounted) {
                        showSnackbar(
                          context,
                          text: 'entranceErrorUnknown'.tr(),
                          icon: PhosphorIconsBold.warningCircle,
                        );
                      }
                    },
                  );
                },
                icon: PhosphorIconsBold.trash,
                iconBackgroundColor: context.colors.delete,
                title: 'accountDeleteAccountTitle'.tr(),
                subtitle: 'accountDeleteAccountSubtitle'.tr(),
              ),

              ///
              /// SPACING
              ///
              const SliverToBoxAdapter(
                child: SizedBox(height: 6),
              ),

              ///
              /// APP NAME & VERSION
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: marginHorizontal,
                  vertical: 8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Animate(
                    delay: BokunSpizeDurations.stateTransitionStagger * 7,
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
                        begin: Offset(0.98, 0.98),
                        end: Offset(1, 1),
                        alignment: Alignment.topCenter,
                        duration: BokunSpizeDurations.stateTransition,
                        curve: Curves.easeOutCubic,
                      ),
                    ],
                    child: FutureBuilder(
                      future: getAppVersion(),
                      builder: (_, snapshot) {
                        final version = snapshot.data;

                        if (version != null) {
                          return Text.rich(
                            TextSpan(
                              text: 'appName'.tr(),
                              children: [
                                WidgetSpan(
                                  child: PhosphorIcon(
                                    PhosphorIconsBold.dotOutline,
                                    size: 16,
                                    color: context.colors.text.withValues(alpha: 0.7),
                                  ),
                                ),
                                TextSpan(
                                  text: 'v$version',
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: context.colors.text.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
      ),
    );
  }
}
