import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import 'widgets/weights_add_weight_sheet.dart';

class WeightsController extends ValueNotifier<({bool isLoading, String? error})> {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  WeightsController({
    required this.firebase,
  }) : super((
         isLoading: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  void init() {
    updateState(
      isLoading: true,
      clearError: true,
    );

    weightTracksStream = firebase.listenToWeightTracks().map(
      (weightTracks) {
        updateState(
          isLoading: false,
          error: weightTracks == null ? 'Weight tracks could not be loaded.' : null,
          clearError: weightTracks != null,
        );

        return weightTracks;
      },
    );
  }

  ///
  /// VARIABLES
  ///

  late Stream<List<WeightTrack>?> weightTracksStream;

  ///
  /// METHODS
  ///

  /// Adds [weightTrack] to Firebase
  Future<void> addWeightTrack({
    required DateTime dateTime,
    required double weight,
  }) async {
    final success = await firebase.writeWeightTrack(
      newWeightTrack: WeightTrack(
        id: const Uuid().v1(),
        dateTime: dateTime,
        weight: weight,
      ),
    );
    // TODO: Show snackbar if it fails
  }

  /// Deletes [weightTrack] from Firebase
  Future<void> deleteWeightTrack({required WeightTrack weightTrack}) async {
    final success = await firebase.deleteWeightTrack(
      weightTrack: weightTrack,
    );
    // TODO: Show snackbar if it fails
  }

  /// Opens [WeightsAddWeightSheet] and adds new `weight`
  Future<void> onAddWeightPressed({
    required BuildContext context,
    required double initialWeight,
  }) async => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: BokunSpizeColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(listTileRadius),
    ),
    builder: (context) => WeightsAddWeightSheet(
      initialWeight: initialWeight,
      onSavePressed: ({required newWeight, required dateTime}) {
        unawaited(
          HapticFeedback.lightImpact(),
        );
        unawaited(
          addWeightTrack(
            dateTime: dateTime,
            weight: newWeight,
          ),
        );

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    ),
  );

  /// Updates `state`.
  void updateState({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => value = (
    isLoading: isLoading ?? value.isLoading,
    error: clearError ? null : error ?? value.error,
  );
}
