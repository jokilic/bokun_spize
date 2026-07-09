import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class EntranceScreen extends StatefulWidget {
  const EntranceScreen({
    required super.key,
  });

  @override
  State<EntranceScreen> createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
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
          ///
          /// GOOGLE SIGN IN
          ///
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  // onPressed: googleIsLoading
                  //     ? null
                  //     : () => handleLogin(
                  //         context: context,
                  //         onLoginPressed: entranceController.googleSignInPressed,
                  //         useColorfulIcons: useColorfulIcons,
                  //       ),
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          ///
          /// APPLE
          ///
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          const SliverToBoxAdapter(
            child: Placeholder(
              strokeWidth: 4,
              fallbackHeight: 40,
              color: Colors.blue,
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
          const SliverToBoxAdapter(
            child: Placeholder(
              strokeWidth: 4,
              fallbackHeight: 40,
              color: Colors.yellow,
            ),
          ),
        ],
      ),
    ),
  );
}
