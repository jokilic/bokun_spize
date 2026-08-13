import 'package:flutter/material.dart';

import '../../widgets/bokun_spize_navigation_bar.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.redAccent,
    bottomNavigationBar: BokunSpizeNavigationBar(),
  );
}
