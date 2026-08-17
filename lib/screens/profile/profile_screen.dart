import 'package:flutter/material.dart';

import '../../widgets/navigation_bar_widget.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.redAccent,
    bottomNavigationBar: NavigationBarWidget(),
  );
}
