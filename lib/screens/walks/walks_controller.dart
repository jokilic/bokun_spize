import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class WalksController extends ValueNotifier<({StepCount? stepCount, PedestrianStatus? pedestrianStatus, dynamic stepCountError, dynamic pedestrianStatusError})> {
  ///
  /// CONSTRUCTOR
  ///

  WalksController()
    : super((
        stepCount: null,
        pedestrianStatus: null,
        stepCountError: null,
        pedestrianStatusError: null,
      ));

  ///
  /// INIT
  ///

  Future<void> init() async {
    /// Init streams
    pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    stepCountStream = Pedometer.stepCountStream;

    /// Listen to streams and handle errors
    stepCountStream.listen(onStepCount).onError(onStepCountError);
    pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);
  }

  ///
  /// VARIABLES
  ///

  late Stream<StepCount> stepCountStream;
  late Stream<PedestrianStatus> pedestrianStatusStream;

  ///
  /// METHODS
  ///

  /// Handle step count changed
  void onStepCount(StepCount event) => updateState(
    stepCount: event,
  );

  /// Handle status changed
  void onPedestrianStatusChanged(PedestrianStatus event) => updateState(
    pedestrianStatus: event,
  );

  /// Handle the error
  void onStepCountError(error) => updateState(
    stepCountError: error,
  );

  /// Handle the error
  void onPedestrianStatusError(error) => updateState(
    pedestrianStatusError: error,
  );

  /// Updates `state`
  void updateState({
    StepCount? stepCount,
    PedestrianStatus? pedestrianStatus,
    stepCountError,
    pedestrianStatusError,
  }) => value = (
    stepCount: stepCount ?? value.stepCount,
    pedestrianStatus: pedestrianStatus ?? value.pedestrianStatus,
    stepCountError: stepCountError ?? value.stepCountError,
    pedestrianStatusError: pedestrianStatusError ?? value.pedestrianStatusError,
  );
}
