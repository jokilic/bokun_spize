// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
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
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        sliver: SliverToBoxAdapter(
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
            controller: emailTextEditingController,
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
              color: BokunSpizeColors.neutralDark.withValues(alpha: 0.5),
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
            controller: passwordTextEditingController,
            hintText: '•' * 8,
            onSubmitted: (_) {
              if (!validated || emailIsLoading) {
                return;
              }

              onRegisterPressed();
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
                backgroundColor: BokunSpizeColors.primary,
                foregroundColor: BokunSpizeColors.white,
                disabledBackgroundColor: BokunSpizeColors.primary.withValues(alpha: 0.3),
                disabledForegroundColor: BokunSpizeColors.white,
              ),
              child: const Text('Sign in'),
            ),
          ),
        ),
      ),
    ],
  );
}
