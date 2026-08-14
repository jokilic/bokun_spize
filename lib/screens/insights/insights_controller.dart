import 'dart:async';

import '../../models/weight_track/weight_track.dart';
import '../../services/firebase_service.dart';

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
}
