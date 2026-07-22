import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import '../../util/snackbars.dart';
import 'entrance_controller.dart';

class EntranceScreen extends WatchingStatefulWidget {
  @override
  State<EntranceScreen> createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<EntranceController>(
      () => EntranceController(
        firebase: getIt.get<FirebaseService>(),
      ),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<EntranceController>();
    super.dispose();
  }

  Future<void> handleLogin({
    required BuildContext context,
    required Future<({User? user, String? error})> Function() onLoginPressed,
  }) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    unawaited(
      HapticFeedback.lightImpact(),
    );

    final loginResult = await onLoginPressed();

    /// Successful login
    if (loginResult.user != null && loginResult.error == null) {
      // openHome(context);
      return;
    }

    /// Non-successful login
    showSnackbar(
      context,
      text: loginResult.error ?? 'errorUnknown',
      icon: Icons.error_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entranceController = getIt.get<EntranceController>();

    final state = watchIt<EntranceController>().value;

    final googleIsLoading = state.googleIsLoading;
    final appleIsLoading = state.appleIsLoading;
    final anonymousIsLoading = state.anonymousIsLoading;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: AutofillGroup(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            slivers: [
              ///
              /// ILLUSTRATION
              ///
              SliverToBoxAdapter(
                child: Image.network(
                  'https://picsum.photos/400',
                  fit: BoxFit.cover,
                  height: 400,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),

              ///
              /// TITLE
              ///
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Welcome to',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: 1,
                      color: BokunSpizeColors.neutralDark,
                    ),
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Bokun spize',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: 1,
                      color: BokunSpizeColors.neutralDark,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 28),
              ),

              ///
              /// USE ACCOUNT TEXT
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: BokunSpizeColors.neutralDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Use your account'.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 1,
                            color: BokunSpizeColors.neutralDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: BokunSpizeColors.neutralDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),

              ///
              /// GOOGLE
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: googleIsLoading
                          ? null
                          : () => handleLogin(
                              context: context,
                              onLoginPressed: entranceController.googleSignInPressed,
                            ),
                      icon: const Icon(
                        Icons.login_rounded,
                        size: 24,
                      ),
                      label: const Text('Google'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: BokunSpizeColors.neutralLight,
                        ),
                        padding: const EdgeInsets.all(14),
                        backgroundColor: BokunSpizeColors.primary,
                        foregroundColor: BokunSpizeColors.neutralLight,
                        disabledBackgroundColor: BokunSpizeColors.neutralLight,
                        disabledForegroundColor: BokunSpizeColors.neutralDark,
                      ),
                    ),
                  ),
                ),
              ),

              ///
              /// APPLE
              ///
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: appleIsLoading
                          ? null
                          : () => handleLogin(
                              context: context,
                              onLoginPressed: entranceController.appleSignInPressed,
                            ),
                      icon: const Icon(
                        Icons.apple_rounded,
                        size: 24,
                      ),
                      label: const Text('Apple'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: BokunSpizeColors.neutralLight,
                        ),
                        padding: const EdgeInsets.all(14),
                        backgroundColor: BokunSpizeColors.tertiary,
                        foregroundColor: BokunSpizeColors.neutralLight,
                        disabledBackgroundColor: BokunSpizeColors.neutralLight,
                        disabledForegroundColor: BokunSpizeColors.neutralDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 28),
              ),

              ///
              /// USE ANONYMOUSLY TEXT
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: BokunSpizeColors.neutralDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Use anonymously'.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 1,
                            color: BokunSpizeColors.neutralDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: BokunSpizeColors.neutralDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),

              ///
              /// ANONYMOUS
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: anonymousIsLoading
                          ? null
                          : () => handleLogin(
                              context: context,
                              onLoginPressed: entranceController.anonymousSignInPressed,
                            ),
                      icon: const Icon(
                        Icons.verified_user_rounded,
                        color: BokunSpizeColors.primary,
                        size: 24,
                      ),
                      label: const Text('Anonymous'),
                      style: OutlinedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.all(14),
                        backgroundColor: BokunSpizeColors.neutralLight,
                        foregroundColor: BokunSpizeColors.primary,
                        disabledBackgroundColor: BokunSpizeColors.secondary,
                        disabledForegroundColor: BokunSpizeColors.neutralDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
