import 'package:flutter/material.dart';

import '../../widgets/bokun_spize_navigation_bar.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.blueAccent,
    bottomNavigationBar: BokunSpizeNavigationBar(),
  );
}
