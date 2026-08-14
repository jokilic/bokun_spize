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
}
