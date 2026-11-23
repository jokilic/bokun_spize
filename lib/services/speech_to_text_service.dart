import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService extends ValueNotifier<({SpeechToText? speechToText, bool available, bool isListening})> {
  ///
  /// CONSTRUCTOR
  ///

  SpeechToTextService()
    : super((
        speechToText: null,
        available: false,
        isListening: false,
      ));

  ///
  /// METHODS
  ///

  /// Loads speech to text used throughout the app
  Future<void> loadSpeechToText() async {
    try {
      final speechToText = value.speechToText ?? SpeechToText();

      final available = await speechToText.initialize(
        debugLogging: kDebugMode,
        onStatus: (status) {
          switch (status.toLowerCase().trim()) {
            /// Speech recognition begins
            case 'listening':
              updateState(
                isListening: true,
              );
              break;

            /// Speech recognition is no longer listening
            case 'notListening':
            case 'done':
              updateState(
                isListening: false,
              );
              break;
          }
        },
        onError: (error) {
          if (error.errorMsg != 'error_no_match' && error.errorMsg != 'error_speech_timeout' && error.errorMsg != 'error_request_cancelled') {
            log(
              'Speech recognition failed',
              error: error.errorMsg,
            );
          }

          updateState(
            isListening: false,
          );
        },
      );

      updateState(
        speechToText: speechToText,
        available: available,
      );
    } catch (error) {
      log(
        'Initializing speech recognition failed',
        error: error is PlatformException ? error.code : error.runtimeType,
      );
    }
  }

  /// Starts a speech recognition session
  Future<void> startListening({
    required Function(String words) onResult,
    required String locale,
  }) async {
    if (value.speechToText == null) {
      return;
    }

    try {
      await value.speechToText!.listen(
        onResult: (result) => onResult(
          result.recognizedWords,
        ),
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 30),
          localeId: locale,
          listenMode: ListenMode.dictation,
        ),
      );

      updateState(
        isListening: true,
      );
    } catch (error) {
      log(
        'Starting speech recognition failed',
        error: error is PlatformException ? error.code : error.runtimeType,
      );
    }
  }

  /// Manually stop the speech recognition session
  Future<void> stopListening() async {
    if (value.speechToText == null) {
      return;
    }

    try {
      await value.speechToText!.stop();

      updateState(
        isListening: false,
      );
    } catch (error) {
      log(
        'Stopping speech recognition failed',
        error: error is PlatformException ? error.code : error.runtimeType,
      );
    }
  }

  /// Updates state
  void updateState({
    SpeechToText? speechToText,
    bool? available,
    bool? isListening,
  }) => value = (
    speechToText: speechToText ?? value.speechToText,
    available: available ?? value.available,
    isListening: isListening ?? value.isListening,
  );
}
