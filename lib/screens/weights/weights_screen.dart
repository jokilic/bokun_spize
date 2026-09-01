import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import '../../util/date_time.dart';
import '../../util/dependencies.dart';
import '../../util/spacing.dart';
import '../../util/weight_track.dart';
import '../../widgets/navigation_bar_widget.dart';
import 'weights_controller.dart';
import 'widgets/weights_app_bar.dart';
import 'widgets/weights_empty.dart';
import 'widgets/weights_error.dart';
import 'widgets/weights_graph.dart';
import 'widgets/weights_loading.dart';
import 'widgets/weights_success.dart';

class WeightsScreen extends WatchingStatefulWidget {
  @override
  State<WeightsScreen> createState() => _WeightsScreenState();
}

class _WeightsScreenState extends State<WeightsScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<WeightsController>(
      () => WeightsController(
        firebase: getIt.get<FirebaseService>(),
      ),
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    // unRegisterIfNotDisposed<WeightsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// References to services & controllers
    final firebaseService = getIt.get<FirebaseService>();
    final storageService = getIt.get<StorageService>();
    final weightsController = getIt.get<WeightsController>();

    /// User name
    final userName = firebaseService.userName;

    /// Reference to `state`
    final state = watchIt<WeightsController>().value;

    final error = state.error;
    final isLoading = state.isLoading;
    final weightTracks = state.weightTracks;

    final graphCalendarDays = watchIt<StorageService>().value.weightsCalendarDays;

    /// Store last `weightTrack`
    final lastWeightTrack = weightTracks.firstOrNull;

    /// Calculate `weightChange`
    final weightChange = getWeightChange(
      weightTracks: weightTracks,
      lastWeight: lastWeightTrack?.weight,
      calendarDays: graphCalendarDays,
    );

    /// Calculate `weightChangeWithinDays`
    final weightChangeWithinDays = getWeightChangeWithinDays(
      weightTracks: weightTracks,
      calendarDays: graphCalendarDays,
    );

    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(),
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          heroTag: const ValueKey('weights-fab'),
          elevation: 0,
          backgroundColor: BokunSpizeColors.blue,
          foregroundColor: BokunSpizeColors.white,
          splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          shape: const CircleBorder(),
          onPressed: () {
            HapticFeedback.lightImpact();
            weightsController.onAddWeightPressed(
              context: context,
              initialWeight: lastWeightTrack?.weight ?? 75.0,
              weightTrackId: const Uuid().v1(),
            );
          },
          child: const PhosphorIcon(
            PhosphorIconsBold.plus,
            color: BokunSpizeColors.white,
            size: 32,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          slivers: [
            ///
            /// APP BAR
            ///
            WeightsAppBar(
              title: userName?.isNotEmpty ?? false ? 'Hello, $userName' : 'Bokun spize',
              dayString: lastWeightTrack != null
                  ? getDateString(
                      date: lastWeightTrack.dateTime,
                      dateFormat: 'EEEE, dd.MM.yyyy.',
                    )
                  : 'Unesi težinu',
              currentWeight: lastWeightTrack?.weight,
              weightChange: weightChange,
              weightChangeWithinDays: weightChangeWithinDays,
            ),

            ///
            /// GRAPH
            ///
            if (weightTracks.length >= 2)
              WeightsGraph(
                onSelectedDays: (newWeightsCalendarDays) {
                  HapticFeedback.lightImpact();
                  storageService.setWeightsCalendarDays(newWeightsCalendarDays);
                },
                dayEntries: weightsController.graphCalendarDayOptions,
                weightTracks: weightTracks,
                calendarDays: graphCalendarDays,
              ),

            ///
            /// SUCCESS
            ///
            if (weightTracks.isNotEmpty)
              WeightsSuccess(
                weightTracks: weightTracks,
                calendarDays: graphCalendarDays,
                onDeletePressed: (weightTrack) {
                  HapticFeedback.lightImpact();
                  weightsController.deleteWeightTrack(
                    weightTrack: weightTrack,
                    context: context,
                  );
                },
              ),

            ///
            /// EMPTY
            ///
            if (!isLoading && weightTracks.isEmpty && error == null) WeightsEmpty(),

            ///
            /// LOADING
            ///
            if (isLoading) WeightsLoading(),

            ///
            /// ERROR
            ///
            if (!isLoading && error != null)
              WeightsError(
                error: error,
                onRetryPressed: weightsController.retryWeightTracks,
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
      ),
    );
  }
}
