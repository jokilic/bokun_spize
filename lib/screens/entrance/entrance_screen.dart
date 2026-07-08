import 'package:flutter/material.dart';

import '../../theme/extensions.dart';

class EntranceScreen extends StatefulWidget {
  const EntranceScreen({
    required super.key,
  });

  @override
  State<EntranceScreen> createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: AutofillGroup(
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: BouncingScrollPhysics(),
        slivers: [
          ///
          /// ILLUSTRATION
          ///
          SliverToBoxAdapter(
            child: Placeholder(
              color: Colors.green,
              strokeWidth: 4,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          ///
          /// TITLE
          ///
          SliverPadding(
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
          SliverPadding(
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
          SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          ///
          /// USE ACCOUNT TEXT
          ///
          SliverPadding(
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
          SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          ///
          /// GOOGLE
          ///
          SliverToBoxAdapter(
            child: Placeholder(
              strokeWidth: 4,
              fallbackHeight: 40,
              color: Colors.red,
            ),
          ),

          ///
          /// APPLE
          ///
          SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          SliverToBoxAdapter(
            child: Placeholder(
              strokeWidth: 4,
              fallbackHeight: 40,
              color: Colors.blue,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          ///
          /// USE ANONYMOUSLY TEXT
          ///
          SliverPadding(
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
          SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          ///
          /// ANONYMOUS
          ///
          SliverToBoxAdapter(
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
