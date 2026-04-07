import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/hive_service.dart';

class CalorieController implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final HiveService hive;

  CalorieController({
    required this.hive,
  });

  ///
  /// VARIABLES
  ///

  late final ageTextEditingController = TextEditingController();

  late final heightTextEditingController = TextEditingController();
  late final weightTextEditingController = TextEditingController();

  ///
  /// INIT
  ///

  void init() {}

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    /// Dispose [TextEditingControllers]
    ageTextEditingController.dispose();
    heightTextEditingController.dispose();
    weightTextEditingController.dispose();
  }

  ///
  /// METHODS
  ///
}
