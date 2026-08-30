// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../widgets/text_field_widget.dart';

class EntranceRegister extends StatelessWidget {
  final TextEditingController emailTextEditingController;
  final TextEditingController passwordTextEditingController;
  final TextEditingController nameTextEditingController;
  final bool validated;
  final bool emailIsLoading;
  final Function onRegisterPressed;

  const EntranceRegister({
    required this.emailTextEditingController,
    required this.passwordTextEditingController,
    required this.nameTextEditingController,
    required this.validated,
    required this.emailIsLoading,
    required this.onRegisterPressed,
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
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal + 16,
        ),
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
          hintText: '•' * 8,
          autofillHints: const [AutofillHints.password],
          keyboardType: TextInputType.visiblePassword,
          textAlign: TextAlign.left,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
        ),
      ),
      const SizedBox(height: 32),

      ///
      /// NAME TITLE
      ///
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: marginHorizontal + 16,
        ),
        child: Text(
          'Name'.toUpperCase(),
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
      /// NAME TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
        child: TextFieldWidget(
          controller: nameTextEditingController,
          hintText: 'Danny',
          onSubmitted: (_) {
            if (!validated || emailIsLoading) {
              return;
            }

            onRegisterPressed();
          },
          autofillHints: const [AutofillHints.name],
          keyboardType: TextInputType.name,
          textAlign: TextAlign.left,
          textCapitalization: TextCapitalization.words,
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
            onPressed: validated && !emailIsLoading ? () => onRegisterPressed() : null,
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
            child: const Text(
              'Register',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ],
  );
}
