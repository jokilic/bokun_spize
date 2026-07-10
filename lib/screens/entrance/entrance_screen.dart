import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../services/firebase_service.dart';
import '../../services/hive_service.dart';
import '../../util/dependencies.dart';
import '../../util/snackbars.dart';
import 'entrance_controller.dart';

class EntranceScreen extends WatchingStatefulWidget {
  const EntranceScreen({
    required super.key,
  });

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
        hive: getIt.get<HiveService>(),
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
      body: AutofillGroup(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ///
            /// ILLUSTRATION
            ///
            const SliverToBoxAdapter(
              child: Placeholder(
                color: Colors.green,
                strokeWidth: 4,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
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
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    letterSpacing: 1,
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
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            ///
            /// USE ACCOUNT TEXT
            ///
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    'Use your account',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
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
                      color: BokunSpizeColors.white,
                      size: 28,
                    ),
                    label: const Text('Google'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: BokunSpizeColors.green,
                      foregroundColor: BokunSpizeColors.white,
                      disabledBackgroundColor: BokunSpizeColors.grey,
                      disabledForegroundColor: BokunSpizeColors.black,
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
                      color: BokunSpizeColors.white,
                      size: 28,
                    ),
                    label: const Text('Apple'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: BokunSpizeColors.green,
                      foregroundColor: BokunSpizeColors.white,
                      disabledBackgroundColor: BokunSpizeColors.grey,
                      disabledForegroundColor: BokunSpizeColors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            ///
            /// USE ANONYMOUSLY TEXT
            ///
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    'Use anonymously',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
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
                      color: BokunSpizeColors.green,
                      size: 28,
                    ),
                    label: const Text('Anonymous'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: BokunSpizeColors.white,
                      foregroundColor: BokunSpizeColors.green,
                      disabledBackgroundColor: BokunSpizeColors.grey,
                      disabledForegroundColor: BokunSpizeColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
