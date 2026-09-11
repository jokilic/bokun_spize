// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';
import '../../../theme/extensions.dart';
import '../../../widgets/text_field_widget.dart';

class EntranceLogin extends StatelessWidget {
  final TextEditingController emailTextEditingController;
  final TextEditingController passwordTextEditingController;
  final FocusNode passwordFocusNode;
  final bool validated;
  final bool emailValidated;
  final bool emailIsLoading;
  final Function() onLoginPressed;
  final Function() onForgetPasswordPressed;

  const EntranceLogin({
    required this.emailTextEditingController,
    required this.passwordTextEditingController,
    required this.passwordFocusNode,
    required this.validated,
    required this.emailValidated,
    required this.emailIsLoading,
    required this.onLoginPressed,
    required this.onForgetPasswordPressed,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ///
      /// EMAIL TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
        child: TextFieldWidget(
          controller: emailTextEditingController,
          title: 'Email address',
          hintText: 'name@example.com',
          onSubmitted: (_) => passwordFocusNode.requestFocus(),
          textColor: context.colors.text,
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textFieldFontSize: 18,
        ),
      ),
      const SizedBox(height: 20),

      ///
      /// PASSWORD TEXTFIELD & FORGOT PASSWORD
      ///
      Stack(
        children: [
          ///
          /// PASSWORD TEXTFIELD
          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            child: TextFieldWidget(
              obscureText: true,
              controller: passwordTextEditingController,
              focusNode: passwordFocusNode,
              title: 'Password',
              hintText: '•' * 8,
              onSubmitted: (_) {
                if (!validated || emailIsLoading) {
                  return;
                }

                onLoginPressed();
              },
              textColor: context.colors.text,
              autofillHints: const [AutofillHints.password],
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.go,
              textFieldFontSize: 18,
            ),
          ),

          ///
          /// FORGET PASSWORD
          ///
          Positioned(
            right: 3,
            top: 19,
            child: AnimatedOpacity(
              opacity: emailValidated ? 1 : 0,
              duration: BokunSpizeDurations.animation,
              curve: Curves.easeIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: marginHorizontal + 16,
                ),
                child: TextButton(
                  onPressed: emailValidated ? onForgetPasswordPressed : null,
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerRight,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: context.colors.text.withValues(alpha: 0.5),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    foregroundColor: context.colors.protein,
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: context.colors.text.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    'Forgot?'.toUpperCase(),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 32),

      ///
      /// SIGN IN BUTTON
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: validated && !emailIsLoading ? () => onLoginPressed() : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontFamily: 'Epilogue',
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              padding: const EdgeInsets.all(22),
              backgroundColor: context.colors.protein,
              foregroundColor: context.colors.buttonText,
              disabledBackgroundColor: context.colors.protein.withValues(alpha: 0.25),
              disabledForegroundColor: context.colors.buttonText.withValues(alpha: 0.75),
            ),
            child: const Text(
              'Sign in',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ],
  );
}
