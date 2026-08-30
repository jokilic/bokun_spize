// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
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
      /// EMAIL TITLE
      ///
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal + 16,
        ),
        child: Text(
          'Email address'.toUpperCase(),
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.black.withValues(alpha: 0.5),
          ),
        ),
      ),
      const SizedBox(height: 12),

      ///
      /// EMAIL TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
        child: TextFieldWidget(
          autocorrect: false,
          controller: emailTextEditingController,
          hintText: 'name@example.com',
          onSubmitted: (_) => passwordFocusNode.requestFocus(),
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.left,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
        ),
      ),
      const SizedBox(height: 32),

      ///
      /// PASSWORD TITLE & FORGET PASSWORD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal + 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ///
            /// PASSWORD TITLE
            ///
            Expanded(
              child: Text(
                'Password'.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: BokunSpizeColors.black.withValues(alpha: 0.5),
                ),
              ),
            ),

            ///
            /// FORGET PASSWORD
            ///
            Expanded(
              child: TextButton(
                onPressed: emailValidated ? onForgetPasswordPressed : null,
                style: TextButton.styleFrom(
                  alignment: Alignment.centerRight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  foregroundColor: BokunSpizeColors.green,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: BokunSpizeColors.black.withValues(alpha: 0.5),
                ),
                child: Text(
                  'Forgot?'.toUpperCase(),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      ///
      /// PASSWORD TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
        child: TextFieldWidget(
          autocorrect: false,
          obscureText: true,
          controller: passwordTextEditingController,
          focusNode: passwordFocusNode,
          hintText: '•' * 8,
          onSubmitted: (_) {
            if (!validated || emailIsLoading) {
              return;
            }

            onLoginPressed();
          },
          autofillHints: const [AutofillHints.password],
          keyboardType: TextInputType.visiblePassword,
          textAlign: TextAlign.left,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.go,
        ),
      ),
      const SizedBox(height: 36),

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
              backgroundColor: BokunSpizeColors.green,
              foregroundColor: BokunSpizeColors.white,
              disabledBackgroundColor: BokunSpizeColors.green.withValues(alpha: 0.25),
              disabledForegroundColor: BokunSpizeColors.white.withValues(alpha: 0.75),
            ),
            child: const Text('Sign in'),
          ),
        ),
      ),
    ],
  );
}
