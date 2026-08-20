// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../widgets/text_field_widget.dart';

class EntranceLogin extends StatelessWidget {
  final TextEditingController emailTextEditingController;
  final TextEditingController passwordTextEditingController;
  final bool validated;
  final bool emailIsLoading;
  final Function onLoginPressed;

  const EntranceLogin({
    required this.emailTextEditingController,
    required this.passwordTextEditingController,
    required this.validated,
    required this.emailIsLoading,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ///
      /// EMAIL TITLE
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Text(
          'Email address'.toUpperCase(),
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.neutralDark.withValues(alpha: 0.5),
          ),
        ),
      ),
      const SizedBox(height: 12),

      ///
      /// EMAIL TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFieldWidget(
          autocorrect: false,
          controller: emailTextEditingController,
          hintText: 'name@example.com',
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.left,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
        ),
      ),
      const SizedBox(height: 32),

      ///
      /// PASSWORD TITLE
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Text(
          'Password'.toUpperCase(),
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: BokunSpizeColors.neutralDark.withValues(alpha: 0.5),
          ),
        ),
      ),
      const SizedBox(height: 12),

      ///
      /// PASSWORD TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFieldWidget(
          autocorrect: false,
          obscureText: true,
          controller: passwordTextEditingController,
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
              backgroundColor: BokunSpizeColors.primary,
              foregroundColor: BokunSpizeColors.white,
              disabledBackgroundColor: BokunSpizeColors.primary.withValues(alpha: 0.3),
              disabledForegroundColor: BokunSpizeColors.white,
            ),
            child: const Text('Sign in'),
          ),
        ),
      ),
    ],
  );
}
