import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../theme/extensions.dart';
import '../../services/hive_service.dart';
import '../../util/dependencies.dart';
import '../../widgets/bokun_spize_app_bar.dart';
import 'calorie_controller.dart';

class CalorieScreen extends WatchingStatefulWidget {
  @override
  State<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends State<CalorieScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<CalorieController>(
      () => CalorieController(
        hive: getIt.get<HiveService>(),
      ),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<CalorieController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calorieController = getIt.get<CalorieController>();

    final userMetrics = watchIt<HiveService>().value.userMetrics;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          ///
          /// APP BAR
          ///
          BokunSpizeAppBar(
            smallTitle: 'Izračun kalorija',
            bigTitle: 'Izračun kalorija',
            bigSubtitle: 'Dnevna potrošnja energije',
            leadingWidget: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                highlightColor: context.colors.buttonBackground,
              ),
              icon: PhosphorIcon(
                PhosphorIcons.arrowLeft(
                  PhosphorIconsStyle.duotone,
                ),
                color: context.colors.text,
                duotoneSecondaryColor: context.colors.buttonPrimary,
                size: 28,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),
        ],
      ),
    );
  }
}
