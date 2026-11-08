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
import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import '../../services/screen_service.dart';
import '../../services/theme_service.dart';
import '../../theme/extensions.dart';
import '../../util/app_version.dart';
import '../../util/dependencies.dart';
import '../../util/height.dart';
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
    await Future.wait([
      unRegisterIfNotDisposed<MealsController>(),
      unRegisterIfNotDisposed<WeightsController>(),
      unRegisterIfNotDisposed<WalksController>(),
      unRegisterIfNotDisposed<AccountController>(),
    ]);

    await getIt.get<FirebaseService>().logOut();

    /// Reset navigation only after authentication has removed the signed-in screens
    getIt.get<ScreenService>().changeNavigationBarItem(
      NavigationBarItem.meals,
    );
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

    /// Listens to the latest `weightTrack` from [Firebase]
    final lastWeightTrack = watchStream<FirebaseService, List<WeightTrack>?>(
      (firebaseService) => firebaseService.listenToLatestWeightTracks(
        pageSize: 1,
      ),
    ).data?.firstOrNull;

    final email = firebaseService.userEmail;
    final name = userMetrics?.name;
    final userPhoto = firebaseService.userPhoto;

    final hasUserMetrics = userMetrics?.age != null && userMetrics?.height != null && userMetrics?.weight != null && userMetrics?.gender != null;

    final hasMacroValues = userMetrics?.dailyCalories != null && userMetrics?.dailyProtein != null && userMetrics?.dailyCarbs != null && userMetrics?.dailyFat != null;

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
                onPressed: () {
                  if (userMetrics == null) {
                    return;
                  }

                  HapticFeedback.lightImpact();
                  accountController.openUserMetricsSheet(
                    context,
                    userMetrics: userMetrics,
                    lastWeightTrack: lastWeightTrack,
                  );
                },
                icon: PhosphorIconsBold.personSimple,
                iconBackgroundColor: context.colors.protein,
                title: 'accountUserMetricsTitle'.tr(),
                subtitle: 'accountUserMetricsSubtitle'.tr(),
                customSubtitle: hasUserMetrics
                    ? Text.rich(
                        ///
                        /// HEIGHT
                        ///
                        TextSpan(
                          children: [
                            TextSpan(
                              text: normalizedHeight(
                                userMetrics!.height!,
                              ).toStringAsFixed(0),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'centimeter'.tr(),
                            ),
                            WidgetSpan(
                              child: PhosphorIcon(
                                PhosphorIconsBold.dotOutline,
                                size: 16,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),

                            ///
                            /// WEIGHT
                            ///
                            TextSpan(
                              text: userMetrics.weight!.toStringAsFixed(1),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'kilogram'.tr(),
                            ),
                            WidgetSpan(
                              child: PhosphorIcon(
                                PhosphorIconsBold.dotOutline,
                                size: 16,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),

                            ///
                            /// AGE
                            ///
                            TextSpan(
                              text: userMetrics.age!.toStringAsFixed(0),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'yearUnit'.tr(),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.colors.text.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
              ),

              ///
              /// GOALS
              ///
              AccountListTile(
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 2,
                onPressed: () {
                  if (userMetrics == null) {
                    return;
                  }

                  HapticFeedback.lightImpact();

                  /// No user metrics, open [UserMetricsSheet]
                  if (!hasUserMetrics) {
                    accountController.openUserMetricsSheet(
                      context,
                      userMetrics: userMetrics,
                      lastWeightTrack: lastWeightTrack,
                    );

                    return;
                  }

                  /// User metrics exist, open [MacroGoalsSheet]
                  accountController.openMacroGoalsSheet(
                    context,
                    userMetrics: userMetrics,
                  );
                },
                icon: PhosphorIconsBold.target,
                iconBackgroundColor: context.colors.carbs,
                title: 'accountGoalsTitle'.tr(),
                subtitle: hasUserMetrics ? 'accountGoalsSubtitle'.tr() : 'accountGoalsMissingMetricsSubtitle'.tr(),
                customSubtitle: hasUserMetrics && hasMacroValues
                    ? Text.rich(
                        ///
                        /// CALORIES
                        ///
                        TextSpan(
                          children: [
                            TextSpan(
                              text: userMetrics!.dailyCalories!.toStringAsFixed(0),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'caloriesUnit'.tr(),
                            ),
                            WidgetSpan(
                              child: PhosphorIcon(
                                PhosphorIconsBold.dotOutline,
                                size: 16,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),

                            ///
                            /// PROTEIN
                            ///
                            TextSpan(
                              text: userMetrics.dailyProtein!.toStringAsFixed(0),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'gramUnit'.tr(),
                            ),
                            WidgetSpan(
                              child: PhosphorIcon(
                                PhosphorIconsBold.dotOutline,
                                size: 16,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),

                            ///
                            /// CARBS
                            ///
                            TextSpan(
                              text: userMetrics.dailyCarbs!.toStringAsFixed(0),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'gramUnit'.tr(),
                            ),
                            WidgetSpan(
                              child: PhosphorIcon(
                                PhosphorIconsBold.dotOutline,
                                size: 16,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),

                            ///
                            /// FAT
                            ///
                            TextSpan(
                              text: userMetrics.dailyFat!.toStringAsFixed(0),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.text.withValues(alpha: 0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'gramUnit'.tr(),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.colors.text.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
              ),

              ///
              /// THEME
              ///
              AccountListTile(
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 3,
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
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 4,
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
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 5,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  accountController.openContactSheet(context);
                },
                icon: PhosphorIconsBold.envelopeSimple,
                iconBackgroundColor: context.colors.carbs,
                title: 'accountContactMeTitle'.tr(),
                subtitle: 'accountContactMeSubtitle'.tr(),
              ),

              ///
              /// MESSAGES
              ///
              if (userMetrics?.isAdmin ?? false)
                AccountListTile(
                  animationDelay: BokunSpizeDurations.stateTransitionStagger * 6,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    accountController.openMessagesSheet(context);
                  },
                  icon: PhosphorIconsBold.chatCircleText,
                  iconBackgroundColor: context.colors.fat,
                  title: 'messages'.tr(),
                  subtitle: 'accountMessagesSubtitle'.tr(),
                ),

              ///
              /// LOGOUT
              ///
              AccountListTile(
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 7,
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
                animationDelay: BokunSpizeDurations.stateTransitionStagger * 8,
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
                iconBackgroundColor: context.colors.text,
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
                    delay: BokunSpizeDurations.stateTransitionStagger * 9,
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
