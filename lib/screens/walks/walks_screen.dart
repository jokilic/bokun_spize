import 'package:flutter/material.dart';

import '../../widgets/navigation_bar_widget.dart';

class WalksScreen extends StatefulWidget {
  @override
  State<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends State<WalksScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.blueAccent,
    bottomNavigationBar: NavigationBarWidget(),
  );
}
