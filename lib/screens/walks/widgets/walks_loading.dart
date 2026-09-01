import 'package:flutter/material.dart';

import 'walks_list_tile_loading.dart';

class WalksLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: 8,
    itemBuilder: (context, index) => WalksListTileLoading(),
  );
}
