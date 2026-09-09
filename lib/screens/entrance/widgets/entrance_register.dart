// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../widgets/text_field_title_widget.dart';
import '../../../widgets/text_field_widget.dart';

// TODO: `FocusNodes` here and logic, like in `EntranceRegister`

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
      /// EMAIL TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
        child: TextFieldTitleWidget(
          controller: emailTextEditingController,
          focusNode: FocusNode(),
          title: 'Email address',
          hintText: 'name@example.com',
          textColor: BokunSpizeColors.black,
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textFieldFontSize: 14,
        ),
      ),
      const SizedBox(height: 20),

      ///
      /// PASSWORD TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
        child: TextFieldTitleWidget(
          controller: passwordTextEditingController,
          focusNode: FocusNode(),
          title: 'Password',
          hintText: '•' * 8,
          textColor: BokunSpizeColors.black,
          autofillHints: const [AutofillHints.password],
          keyboardType: TextInputType.visiblePassword,
          textCapitalization: TextCapitalization.none,
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
