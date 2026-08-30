import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import '../../util/null_state.dart';
import '../../util/snackbars.dart';
import 'widgets/weights_add_weight_sheet.dart';

class WeightsController
    extends
        ValueNotifier<
          ({
            List<WeightTrack> weightTracks,
            bool isLoading,
            String? error,
          })
        >
    implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  WeightsController({
    required this.firebase,
  }) : super((
         weightTracks: const [],
         isLoading: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  void init() {
    updateState(
      isLoading: true,
      error: null,
    );

    weightTracksSubscription = firebase.listenToWeightTracks().listen(
      (weightTracks) {
        updateState(
          weightTracks: weightTracks ?? const [],
          isLoading: false,
          error: weightTracks == null ? 'Weight tracks could not be loaded.' : null,
        );
      },
    );
  }

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    weightTracksSubscription?.cancel();
    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  StreamSubscription<List<WeightTrack>?>? weightTracksSubscription;

  final graphCalendarDayOptions = [3, 7, 14, 30, 60, 90];

  ///
  /// METHODS
  ///

  /// Adds [weightTrack] to Firebase
  Future<void> addWeightTrack({
    required String weightTrackId,
    required DateTime dateTime,
    required double weight,
    required BuildContext context,
  }) async {
    final success = await firebase.writeWeightTrack(
      newWeightTrack: WeightTrack(
        id: weightTrackId,
        dateTime: dateTime,
        weight: weight,
      ),
    );

    /// Adding failed, show error snackbar
    if (!success) {
      showSnackbar(
        context,
        text: 'Add failed',
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

    /// Delete failed, show error snackbar
    if (!success) {
      showSnackbar(
        context,
        text: 'Delete failed',
        icon: PhosphorIconsBold.warningOctagon,
      );
    }
  }

  /// Opens [WeightsAddWeightSheet] and adds new `weight`
  Future<void> onAddWeightPressed({
    required BuildContext context,
    required double initialWeight,
    required String weightTrackId,
  }) async => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: BokunSpizeColors.white,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(listTileRadius),
      ),
    ),
    builder: (context) => WeightsAddWeightSheet(
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

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    ),
  );

  /// Updates `state`.
  void updateState({
    List<WeightTrack>? weightTracks,
    bool? isLoading,
    Object? error = nullStateNoChange,
  }) => value = (
    weightTracks: weightTracks ?? value.weightTracks,
    isLoading: isLoading ?? value.isLoading,
    error: identical(error, nullStateNoChange) ? value.error : error as String?,
  );
}
