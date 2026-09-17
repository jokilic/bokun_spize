import 'package:flutter/material.dart' hide SearchController;

import '../../constants/constants.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import 'search_controller.dart';
import 'widgets/search_error.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<SearchController>(
      () => SearchController(
        firebase: getIt.get<FirebaseService>(),
      ),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<SearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(listTileRadius),
    child: CustomScrollView(
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),

        // TODO: Content here
        const SearchError(
          error: 'Worko in progresso',
        ),

        ///
        /// BOTTOM SPACING
        ///
        SliverToBoxAdapter(
          child: SizedBox(
            height: getBottomSpacing(context),
          ),
        ),
      ],
    ),
  );
}
