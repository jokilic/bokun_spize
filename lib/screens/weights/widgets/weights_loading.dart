import 'package:flutter/material.dart';

import 'weights_list_tile_loading.dart';

class WeightsLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: 8,
    itemBuilder: (context, index) => WeightsListTileLoading(),
  );
}
