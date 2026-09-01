import 'package:flutter/widgets.dart';

import 'meals_list_tile_loading.dart';

class MealsLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: 8,
    itemBuilder: (context, index) => MealsListTileLoading(),
  );
}
