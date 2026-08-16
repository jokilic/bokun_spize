import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../main.dart';
import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';
import 'widgets/insights_add_weight_sheet.dart';

class InsightsController {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;

  InsightsController({
    required this.firebase,
  });

  ///
  /// INIT
  ///

  void init() => weightTracksStream = firebase.listenToWeightTracks();

  ///
  /// VARIABLES
  ///

  late Stream<List<WeightTrack>?> weightTracksStream;

  ///
  /// METHODS
  ///

  /// Deletes [weightTrack] from Firebase
  Future<void> deleteWeightTrack({required WeightTrack weightTrack}) async {
    final success = await firebase.deleteWeightTrack(weightTrack: weightTrack);
    // TODO: Show snackbar if it fails
  }

  /// Opens [InsightsAddWeightSheet] and adds new `weight`
  Future<void> onAddWeightPressed(BuildContext context) async => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: BokunSpizeColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(listTileRadius),
    ),
    builder: (context) => InsightsAddWeightSheet(
      currentDateTime: DateTime.now(),
      initialWeight: 77,
      onSavePressed: print,
    ),
  );
}
