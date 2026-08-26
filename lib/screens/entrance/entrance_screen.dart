import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import '../../util/snackbars.dart';
import 'entrance_controller.dart';
import 'widgets/entrance_login.dart';
import 'widgets/entrance_register.dart';

class EntranceScreen extends WatchingStatefulWidget {
  @override
  State<EntranceScreen> createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  var showLogin = true;

  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<EntranceController>(
      () => EntranceController(
        firebase: getIt.get<FirebaseService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<EntranceController>();
    super.dispose();
  }

  void toggleLoginRegister() => setState(
    () => showLogin = !showLogin,
  );

  Future<void> handleOnPressed({
    required BuildContext context,
    required Future<({User? user, String? error})> Function() onPressed,
  }) async {
    /// Hide snackbars & keyboard
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    FocusManager.instance.primaryFocus?.unfocus();

    unawaited(
      HapticFeedback.lightImpact(),
    );

    final result = await onPressed();

    /// Successful logic
    if (result.user != null && result.error == null) {
      return;
    }

    /// Non-successful logic
    showSnackbar(
      context,
      text: result.error ?? 'errorUnknown',
      icon: PhosphorIconsBold.warningOctagon,
    );
  }

  Future<void> handleOnPressedForgetPassword({
    required BuildContext context,
    required Future<({bool success, String? error})> Function() onPressed,
  }) async {
    /// Hide snackbars & keyboard
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    FocusManager.instance.primaryFocus?.unfocus();

    unawaited(
      HapticFeedback.lightImpact(),
    );

    final result = await onPressed();

    /// Successful logic
    if (result.success && result.error == null) {
      return;
    }

    /// Non-successful logic
    showSnackbar(
      context,
      text: result.error ?? 'errorUnknown',
      icon: PhosphorIconsBold.warningOctagon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entranceController = getIt.get<EntranceController>();

    final state = watchIt<EntranceController>().value;

    final loginValidated = state.loginEmailValid && state.loginPasswordValid;
    final registerValidated = state.registerEmailValid && state.registerPasswordValid && state.registerNameValid;

    final emailIsLoading = state.emailIsLoading;
    final googleIsLoading = state.googleIsLoading;
    final appleIsLoading = state.appleIsLoading;

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
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRT25eEKqXY3z-LPhiaLBeZ222wKUARuyg_vkBmdKegriFUgGicOnoj-aM&s=10',
                  fit: BoxFit.cover,
                  height: 400,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              ///
              /// TITLE
              ///
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: marginHorizontal),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: 1,
                      color: BokunSpizeColors.black,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 4),
              ),

              ///
              /// SUBTITLE
              ///
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: marginHorizontal),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Track your everyday meals, weight & walks',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: BokunSpizeColors.black,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              ///
              /// LOGIN / REGISTER
              ///
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: BokunSpizeDurations.animation,
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeIn,
                  child: showLogin
                      ? EntranceLogin(
                          emailTextEditingController: entranceController.loginEmailTextEditingController,
                          passwordTextEditingController: entranceController.loginPasswordTextEditingController,
                          validated: loginValidated,
                          emailValidated: state.loginEmailValid,
                          emailIsLoading: emailIsLoading,
                          onLoginPressed: () => handleOnPressed(
                            context: context,
                            onPressed: entranceController.emailSignInPressed,
                          ),
                          onForgetPasswordPressed: () => handleOnPressedForgetPassword(
                            context: context,
                            onPressed: entranceController.forgetPasswordPressed,
                          ),
                        )
                      : EntranceRegister(
                          emailTextEditingController: entranceController.registerEmailTextEditingController,
                          passwordTextEditingController: entranceController.registerPasswordTextEditingController,
                          nameTextEditingController: entranceController.registerNameTextEditingController,
                          validated: registerValidated,
                          emailIsLoading: emailIsLoading,
                          onRegisterPressed: () => handleOnPressed(
                            context: context,
                            onPressed: entranceController.emailRegisterPressed,
                          ),
                        ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              ///
              /// OR CONNECT WITH TEXT
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Or connect with'.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 1,
                      color: BokunSpizeColors.black.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              ///
              /// BUTTONS
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      ///
                      /// GOOGLE
                      ///
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: googleIsLoading
                              ? null
                              : () => handleOnPressed(
                                  context: context,
                                  onPressed: entranceController.googleSignInPressed,
                                ),
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.googleLogo,
                            color: BokunSpizeColors.black,
                            size: 24,
                          ),
                          label: const Text('Google'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 16,
                              height: 1.6,
                              fontWeight: FontWeight.w800,
                              color: BokunSpizeColors.grey,
                            ),
                            padding: const EdgeInsets.all(18),
                            backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                            foregroundColor: BokunSpizeColors.black,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      ///
                      /// APPLE
                      ///
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: appleIsLoading
                              ? null
                              : () => handleOnPressed(
                                  context: context,
                                  onPressed: entranceController.appleSignInPressed,
                                ),
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.appleLogo,
                            color: BokunSpizeColors.black,
                            size: 24,
                          ),
                          label: const Text('Apple'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 16,
                              height: 1.6,
                              fontWeight: FontWeight.w800,
                              color: BokunSpizeColors.grey,
                            ),
                            padding: const EdgeInsets.all(18),
                            backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                            foregroundColor: BokunSpizeColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),

              ///
              /// CREATE ACCOUNT / SIGN IN
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
                sliver: SliverToBoxAdapter(
                  child: Text.rich(
                    TextSpan(
                      text: showLogin ? 'New to Bokun spize?' : 'You have an account?',
                      children: [
                        const WidgetSpan(
                          child: SizedBox(width: 4),
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = toggleLoginRegister,
                          text: showLogin ? 'Create an account' : 'Sign in',
                          style: const TextStyle(
                            fontFamily: 'Epilogue',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: BokunSpizeColors.green,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: BokunSpizeColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
      ),
    );
  }
}
