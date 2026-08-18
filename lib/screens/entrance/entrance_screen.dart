import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import '../../util/snackbars.dart';
import '../../widgets/text_field_widget.dart';
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
      afterRegister: (controller) => controller.init(),
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

    final validated = state.emailValid && state.passwordValid;

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
                  'https://picsum.photos/400',
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Welcome back',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: 1,
                      color: BokunSpizeColors.neutralDark,
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Start your health journey with us.',
                    style: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: BokunSpizeColors.neutralDark,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              ///
              /// EMAIL TITLE
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Email address'.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: BokunSpizeColors.neutralDark.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 12),
              ),

              ///
              /// EMAIL TEXTFIELD
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: TextFieldWidget(
                    autocorrect: false,
                    controller: entranceController.emailTextEditingController,
                    hintText: 'name@example.com',
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.left,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              ///
              /// PASSWORD TITLE
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Password'.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: BokunSpizeColors.neutralDark.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 12),
              ),

              ///
              /// PASSWORD TEXTFIELD
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: TextFieldWidget(
                    autocorrect: false,
                    obscureText: true,
                    controller: entranceController.passwordTextEditingController,
                    hintText: '•' * 8,
                    onSubmitted: (_) {
                      if (!validated || emailIsLoading) {
                        return;
                      }

                      unawaited(
                        handleLogin(
                          context: context,
                          onLoginPressed: entranceController.emailSignInPressed,
                        ),
                      );
                    },
                    autofillHints: const [AutofillHints.password],
                    keyboardType: TextInputType.visiblePassword,
                    textAlign: TextAlign.left,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.go,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 36),
              ),

              ///
              /// SIGN IN BUTTON
              ///
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: validated
                          ? () => handleLogin(
                              context: context,
                              onLoginPressed: entranceController.emailSignInPressed,
                            )
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: BokunSpizeColors.primary,
                        foregroundColor: BokunSpizeColors.white,
                        disabledBackgroundColor: BokunSpizeColors.neutralLight,
                        disabledForegroundColor: BokunSpizeColors.neutralDark,
                      ),
                      child: const Text('Sign in'),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Or connect with'.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 1,
                      color: BokunSpizeColors.neutralDark.withValues(alpha: 0.5),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              : () => handleLogin(
                                  context: context,
                                  onLoginPressed: entranceController.googleSignInPressed,
                                ),
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.googleLogo,
                            color: BokunSpizeColors.neutralDark,
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
                              color: BokunSpizeColors.neutralLight,
                            ),
                            padding: const EdgeInsets.all(20),
                            backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                            foregroundColor: BokunSpizeColors.neutralDark,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      ///
                      /// APPLE
                      ///
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: appleIsLoading
                              ? null
                              : () => handleLogin(
                                  context: context,
                                  onLoginPressed: entranceController.appleSignInPressed,
                                ),
                          icon: const PhosphorIcon(
                            PhosphorIconsBold.appleLogo,
                            color: BokunSpizeColors.neutralDark,
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
                              color: BokunSpizeColors.neutralLight,
                            ),
                            padding: const EdgeInsets.all(20),
                            backgroundColor: BokunSpizeColors.white.withValues(alpha: 0.5),
                            foregroundColor: BokunSpizeColors.neutralDark,
                          ),
                        ),
                      ),
                    ],
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
