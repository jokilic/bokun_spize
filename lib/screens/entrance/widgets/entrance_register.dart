// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../theme/extensions.dart';
import '../../../widgets/text_field_widget.dart';

class EntranceRegister extends StatelessWidget {
  final TextEditingController emailTextEditingController;
  final TextEditingController passwordTextEditingController;
  final TextEditingController nameTextEditingController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode nameFocusNode;
  final bool validated;
  final bool emailIsLoading;
  final Function onRegisterPressed;

  const EntranceRegister({
    required this.emailTextEditingController,
    required this.passwordTextEditingController,
    required this.nameTextEditingController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.nameFocusNode,
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
        child: TextFieldWidget(
          controller: emailTextEditingController,
          focusNode: emailFocusNode,
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
          onSubmitted: (_) => nameFocusNode.requestFocus(),
          textColor: context.colors.text,
          autofillHints: const [AutofillHints.password],
          keyboardType: TextInputType.visiblePassword,
          textCapitalization: TextCapitalization.none,
          textFieldFontSize: 18,
        ),
      ),
      const SizedBox(height: 20),

      ///
      /// NAME TEXTFIELD
      ///
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
        child: TextFieldWidget(
          controller: nameTextEditingController,
          focusNode: nameFocusNode,
          title: 'Name',
          hintText: 'Jack',
          onSubmitted: (_) {
            if (!validated || emailIsLoading) {
              return;
            }

            onRegisterPressed();
          },
          textColor: context.colors.text,
          autofillHints: const [AutofillHints.name],
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.go,
          textFieldFontSize: 18,
        ),
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
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.listTileBackground,
              disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.25),
              disabledForegroundColor: context.colors.listTileBackground.withValues(alpha: 0.75),
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
