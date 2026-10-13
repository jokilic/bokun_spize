import 'dart:async';
import 'dart:developer';

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

class WeightsController extends ValueNotifier<({List<WeightTrack> weightTracks, bool isLoading, bool isHistoryLoading, bool isLoadingMore, bool hasMore, String? error})>
    implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;
  final int graphCalendarDays;

  WeightsController({
    required this.firebase,
    required this.graphCalendarDays,
  }) : super((
         weightTracks: const [],
         isLoading: false,
         isHistoryLoading: false,
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

  static const initialWeightTracksPageSize = 5;
  static const additionalWeightTracksPageSize = 25;

  var isDisposed = false;
  var hasStartedWeightHistory = false;
  var weightTracksRequestId = 0;

  ///
  /// METHODS
  ///

  /// Listens to the latest weight tracks and resets older pagination
  Future<void> listenToLatestWeightTracks() async {
    if (isDisposed || value.isLoading) {
      return;
    }

    /// Invalidate previous requests and reset loaded entries and pagination
    final requestId = ++weightTracksRequestId;
    weightTracksCursor = null;
    latestWeightTracks = const [];
    additionalWeightTracks = const [];
    hasStartedWeightHistory = false;

    /// Enable both the list and graph loaders
    updateState(
      weightTracks: const [],
      isLoading: true,
      isHistoryLoading: true,
      isLoadingMore: false,
      hasMore: false,
      error: null,
    );

    /// Cancel the previous listener before subscribing again
    await weightTracksSubscription?.cancel();

    if (isDisposed || requestId != weightTracksRequestId) {
      return;
    }

    /// Listen to the latest five weight entries
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
      hasStartedWeightHistory = false;
      weightTracksRequestId++;

      updateState(
        weightTracks: const [],
        isLoading: false,
        isHistoryLoading: false,
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

    final shouldLoadHistory = !hasStartedWeightHistory;
    hasStartedWeightHistory = true;

    /// Set the initial pagination cursor and retain it during later listener updates
    if (shouldLoadHistory) {
      weightTracksCursor = latestWeightTracks.lastOrNull;
    }

    /// Show the first results while keeping isHistoryLoading enabled for the graph fetch
    updateState(
      weightTracks: mergeWeightTracks(
        [...additionalWeightTracks, ...latestWeightTracks],
      ),
      isLoading: false,
      isHistoryLoading: shouldLoadHistory ? true : null,
      hasMore: shouldLoadHistory ? latestWeightTracks.length == initialWeightTracksPageSize : value.hasMore,
      error: null,
    );

    /// Start the graph history fetch once without awaiting it
    if (shouldLoadHistory) {
      unawaited(
        fetchGraphWeightTracks(),
      );
    }
  }

  /// Handles unexpected latest weight track listener errors
  void onLatestWeightTracksError(Object error, StackTrace stackTrace) => onLatestWeightTracksChanged(null);

  /// Fetches, merges, and publishes the next page for the active request
  Future<bool> fetchNextWeightTracksPage({
    required int requestId,
  }) async {
    final cursor = weightTracksCursor;

    if (isDisposed || requestId != weightTracksRequestId || cursor == null) {
      return false;
    }

    final page = await firebase.getWeightTracksPage(
      pageSize: additionalWeightTracksPageSize,
      startAfterWeightTrack: cursor,
    );

    if (isDisposed || requestId != weightTracksRequestId || page == null) {
      return false;
    }

    weightTracksCursor = page.cursor ?? weightTracksCursor;
    additionalWeightTracks = mergeWeightTracks(
      [...additionalWeightTracks, ...page.weightTracks],
    );

    updateState(
      weightTracks: mergeWeightTracks(
        [...additionalWeightTracks, ...latestWeightTracks],
      ),
      hasMore: page.hasMore && page.cursor != null,
    );

    return true;
  }

  /// Completes the inclusive graph date range before prefetching one page of older entries
  Future<void> fetchGraphWeightTracks() async {
    if (isDisposed || !value.isHistoryLoading) {
      return;
    }

    final requestId = weightTracksRequestId;

    try {
      /// Continue until the cursor passes the graph's oldest calendar day or history is exhausted
      while (!isDisposed && requestId == weightTracksRequestId && value.hasMore) {
        final cursor = weightTracksCursor;
        final latestWeightTrack = value.weightTracks.firstOrNull;

        if (cursor == null || latestWeightTrack == null) {
          break;
        }

        /// Match the graph's inclusive date range anchored to the latest measurement
        final latestDate = latestWeightTrack.dateTime;
        final graphHistoryStart = DateTime(
          latestDate.year,
          latestDate.month,
          latestDate.day - graphCalendarDays,
        );

        /// Entries on the boundary day can span multiple pages, so fetch until strictly before it
        if (DateUtils.dateOnly(cursor.dateTime).isBefore(graphHistoryStart)) {
          break;
        }

        if (!await fetchNextWeightTracksPage(requestId: requestId)) {
          return;
        }
      }

      /// Reveal the loaded graph by disabling isHistoryLoading
      if (isDisposed || requestId != weightTracksRequestId) {
        return;
      }

      updateState(
        isHistoryLoading: false,
      );

      /// Prefetch one older page without awaiting it, then load subsequent pages on scroll
      unawaited(
        loadMoreWeightTracks(),
      );
    } catch (error) {
      log(
        'Fetching graph weight tracks failed',
        error: error,
      );
    } finally {
      if (requestId == weightTracksRequestId) {
        updateState(
          isHistoryLoading: false,
        );
      }
    }
  }

  /// Loads and appends the next page of older weight tracks
  Future<void> loadMoreWeightTracks() async {
    if (isDisposed || value.isLoading || value.isHistoryLoading || value.isLoadingMore || !value.hasMore || weightTracksCursor == null) {
      return;
    }

    final requestId = weightTracksRequestId;

    /// Show the pagination loader while keeping the graph visible
    updateState(
      isLoadingMore: true,
    );

    try {
      await fetchNextWeightTracksPage(
        requestId: requestId,
      );
    } catch (error) {
      log(
        'Loading more weight tracks failed',
        error: error,
      );
    } finally {
      if (requestId == weightTracksRequestId) {
        updateState(
          isLoadingMore: false,
        );
      }
    }
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
    bool? isHistoryLoading,
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
      isHistoryLoading: isHistoryLoading ?? value.isHistoryLoading,
      isLoadingMore: isLoadingMore ?? value.isLoadingMore,
      hasMore: hasMore ?? value.hasMore,
      error: identical(error, nullStateNoChange) ? value.error : error as String?,
    );
  }
}
