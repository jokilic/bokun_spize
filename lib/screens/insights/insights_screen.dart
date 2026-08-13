import 'package:flutter/material.dart';

import '../../widgets/bokun_spize_navigation_bar.dart';

class InsightsScreen extends StatefulWidget {
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.greenAccent,
    bottomNavigationBar: BokunSpizeNavigationBar(),
  );
}
