import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../util/dependencies.dart';
import 'home_controller.dart';
import 'widgets/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<HomeController>(
      HomeController.new,
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<HomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = getIt.get<HomeController>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ///
            /// APP BAR
            ///
            HomeAppBar(
              smallTitle: 'yo',
              bigTitle: 'aaa',
              bigSubtitle: 'ooo',
            ),

            SliverToBoxAdapter(
              child: Container(
                height: 300,
                width: 200,
                color: Colors.green,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                width: 200,
                color: Colors.red,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                width: 200,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
