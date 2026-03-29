import 'package:firebase_ai/firebase_ai.dart';
import 'package:get_it/get_it.dart';

import '../services/ai_service.dart';
import '../services/hive_service.dart';
import '../services/speech_to_text_service.dart';

final getIt = GetIt.instance;

/// Registers a class if it's not already initialized
/// Optionally runs a function with newly registered class
T registerIfNotInitialized<T extends Object>(
  T Function() factoryFunc, {
  String? instanceName,
  void Function(T controller)? afterRegister,
}) {
  if (!getIt.isRegistered<T>(instanceName: instanceName)) {
    getIt.registerLazySingleton<T>(
      factoryFunc,
      instanceName: instanceName,
      onCreated: afterRegister != null ? (instance) => afterRegister(instance) : null,
    );
  }

  return getIt.get<T>(instanceName: instanceName);
}

/// Unregisters a class if it's not already disposed
/// Optionally runs a function with newly unregistered class
void unRegisterIfNotDisposed<T extends Object>({
  String? instanceName,
  void Function(T controller)? afterUnregister,
}) {
  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    getIt.unregister<T>(
      disposingFunction: afterUnregister,
      instanceName: instanceName,
    );
  }
}

Future<void> initializeServices() async {
  if (!getIt.isRegistered<HiveService>()) {
    getIt.registerSingletonAsync(
      () async {
        final hive = HiveService();
        await hive.init();
        return hive;
      },
    );
  }

  if (!getIt.isRegistered<SpeechToTextService>()) {
    getIt.registerSingletonAsync(
      () async => SpeechToTextService(),
      dependsOn: [HiveService],
    );
  }

  if (!getIt.isRegistered<AIService>()) {
    getIt.registerSingletonAsync(
      () async => AIService(
        hive: getIt.get<HiveService>(),
        ai: FirebaseAI.googleAI(),
      )..init(),
      dependsOn: [HiveService],
    );
  }

  /// Wait for initialization to finish
  await getIt.allReady();
}
