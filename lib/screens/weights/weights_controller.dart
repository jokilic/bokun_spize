import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import '../../util/null_state.dart';
import '../../util/snackbars.dart';
import '../../util/weight_track.dart';
import '../../widgets/blurred_modal_bottom_sheet.dart';
import 'widgets/weights_add_weight_sheet.dart';

class WeightsController extends ValueNotifier<({List<WeightTrack> weightTracks, bool isLoading, bool isLoadingMore, bool hasMore, String? error})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  WeightsController({
    required this.firebase,
  }) : super((
         weightTracks: const [],
         isLoading: false,
         isLoadingMore: false,
         hasMore: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  void init() => listenToLatestWeightTracks();

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    isDisposed = true;
    weightTracksSubscription?.cancel();
    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  StreamSubscription<List<WeightTrack>?>? weightTracksSubscription;

  WeightTrack? weightTracksCursor;
  List<WeightTrack> latestWeightTracks = const [];
  List<WeightTrack> additionalWeightTracks = const [];

  final graphCalendarDayOptions = [3, 7, 14, 30, 60, 90];

  static const initialWeightTracksPageSize = 10;
  static const additionalWeightTracksPageSize = 25;

  var isDisposed = false;
  var hasLoadedAdditionalWeightTracks = false;

  ///
  /// METHODS
  ///

  /// Listens to the latest weight tracks and resets older pagination
  Future<void> listenToLatestWeightTracks() async {
    if (isDisposed || value.isLoading) {
      return;
    }

    await weightTracksSubscription?.cancel();

    if (isDisposed) {
      return;
    }

    weightTracksCursor = null;
    latestWeightTracks = const [];
    additionalWeightTracks = const [];
    hasLoadedAdditionalWeightTracks = false;

    updateState(
      weightTracks: const [],
      isLoading: true,
      isLoadingMore: false,
      hasMore: false,
      error: null,
    );

    weightTracksSubscription = firebase
        .listenToLatestWeightTracks(
          pageSize: initialWeightTracksPageSize,
        )
        .listen(
          onLatestWeightTracksChanged,
          onError: onLatestWeightTracksError,
        );
  }

  /// Merges changes from the latest weight track listener with older loaded pages
  void onLatestWeightTracksChanged(List<WeightTrack>? weightTracks) {
    if (isDisposed) {
      return;
    }

    if (weightTracks == null) {
      latestWeightTracks = const [];
      additionalWeightTracks = const [];
      weightTracksCursor = null;
      hasLoadedAdditionalWeightTracks = false;

      updateState(
        weightTracks: const [],
        isLoading: false,
        isLoadingMore: false,
        hasMore: false,
        error: 'weightsErrorTracksCouldNotBeLoaded'.tr(),
      );
      return;
    }

    /// Retain entries displaced from the latest page when newer entries arrive
    additionalWeightTracks = mergeWeightTracks(
      [...additionalWeightTracks, ...latestWeightTracks],
    );
    latestWeightTracks = weightTracks;

    if (!hasLoadedAdditionalWeightTracks) {
      weightTracksCursor = latestWeightTracks.lastOrNull;
    }

    updateState(
      weightTracks: mergeWeightTracks(
        [...additionalWeightTracks, ...latestWeightTracks],
      ),
      isLoading: false,
      hasMore: hasLoadedAdditionalWeightTracks ? value.hasMore : latestWeightTracks.length == initialWeightTracksPageSize,
      error: null,
    );
  }

  /// Handles unexpected latest weight track listener errors
  void onLatestWeightTracksError(Object error, StackTrace stackTrace) {
    if (isDisposed) {
      return;
    }

    updateState(
      weightTracks: const [],
      isLoading: false,
      isLoadingMore: false,
      hasMore: false,
      error: 'weightsErrorTracksCouldNotBeLoaded'.tr(),
    );
  }

  /// Loads and appends the next page of older weight tracks
  Future<void> loadMoreWeightTracks() async {
    final cursor = weightTracksCursor;

    if (isDisposed || value.isLoading || value.isLoadingMore || !value.hasMore || cursor == null) {
      return;
    }

    updateState(
      isLoadingMore: true,
    );

    final page = await firebase.getWeightTracksPage(
      pageSize: additionalWeightTracksPageSize,
      startAfterWeightTrack: cursor,
    );

    if (isDisposed) {
      return;
    }

    if (page == null) {
      updateState(
        isLoadingMore: false,
      );
      return;
    }

    hasLoadedAdditionalWeightTracks = true;
    weightTracksCursor = page.cursor ?? weightTracksCursor;
    additionalWeightTracks = mergeWeightTracks(
      [...additionalWeightTracks, ...page.weightTracks],
    );

    updateState(
      weightTracks: mergeWeightTracks(
        [...additionalWeightTracks, ...latestWeightTracks],
      ),
      isLoadingMore: false,
      hasMore: page.hasMore && page.cursor != null,
    );
  }

  /// Restarts the initial page request after an error
  void retryWeightTracks() => listenToLatestWeightTracks();

  /// Adds [weightTrack] to Firebase
  Future<void> addWeightTrack({
    required String weightTrackId,
    required DateTime dateTime,
    required double weight,
    required BuildContext context,
  }) async {
    final newWeightTrack = WeightTrack(
      id: weightTrackId,
      dateTime: dateTime,
      weight: weight,
    );
    final success = await firebase.writeWeightTrack(
      newWeightTrack: newWeightTrack,
    );

    if (success) {
      additionalWeightTracks = mergeWeightTracks(
        [...additionalWeightTracks, newWeightTrack],
      );

      updateState(
        weightTracks: mergeWeightTracks(
          [...additionalWeightTracks, ...latestWeightTracks],
        ),
      );
    }

    /// Add failed, show error snackbar
    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: 'addFailed'.tr(),
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Deletes [weightTrack] from Firebase
  Future<void> deleteWeightTrack({
    required WeightTrack weightTrack,
    required BuildContext context,
  }) async {
    final success = await firebase.deleteWeightTrack(
      weightTrack: weightTrack,
    );

    if (success) {
      latestWeightTracks = latestWeightTracks
          .where(
            (entry) => entry.id != weightTrack.id,
          )
          .toList();
      additionalWeightTracks = additionalWeightTracks
          .where(
            (entry) => entry.id != weightTrack.id,
          )
          .toList();

      updateState(
        weightTracks: mergeWeightTracks(
          [...additionalWeightTracks, ...latestWeightTracks],
        ),
      );
    }

    /// Delete failed, show error snackbar
    if (!success && context.mounted) {
      showSnackbar(
        context,
        text: 'deleteFailed'.tr(),
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Opens [WeightsAddWeightSheet] and adds new `weight`
  Future<void> onAddWeightPressed({
    required BuildContext context,
    required double initialWeight,
    required String weightTrackId,
  }) async => showBlurredModalBottomSheet(
    context: context,
    builder: (sheetContext) => WeightsAddWeightSheet(
      key: ValueKey(weightTrackId),
      initialWeight: initialWeight,
      onSavePressed: ({required newWeight, required dateTime}) {
        HapticFeedback.lightImpact();
        addWeightTrack(
          weightTrackId: weightTrackId,
          dateTime: dateTime,
          weight: newWeight,
          context: context,
        );

        if (sheetContext.mounted) {
          Navigator.of(sheetContext).pop();
        }
      },
    ),
  );

  /// Updates `state`
  void updateState({
    List<WeightTrack>? weightTracks,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error = nullStateNoChange,
  }) {
    if (isDisposed) {
      return;
    }

    value = (
      weightTracks: weightTracks ?? value.weightTracks,
      isLoading: isLoading ?? value.isLoading,
      isLoadingMore: isLoadingMore ?? value.isLoadingMore,
      hasMore: hasMore ?? value.hasMore,
      error: identical(error, nullStateNoChange) ? value.error : error as String?,
    );
  }
}
