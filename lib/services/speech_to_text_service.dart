import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../util/analytics.dart';
import 'analytics_service.dart';

class SpeechToTextService extends ValueNotifier<({SpeechToText? speechToText, bool available, bool isListening})> {
  ///
  /// CONSTRUCTOR
  ///

  final AnalyticsService analytics;
  VoiceInputSurface? activeAnalyticsSurface;
  bool hasRecognizedSpeech = false;

  SpeechToTextService({
    required this.analytics,
  }) : super((
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
          switch (status) {
            /// Speech recognition begins
            case SpeechToText.listeningStatus:
              updateState(
                isListening: true,
              );
              break;

            /// Speech recognition is no longer listening
            case SpeechToText.doneStatus:
              finishVoiceInput();
              continue stopped;
            stopped:
            case SpeechToText.notListeningStatus:
              updateState(
                isListening: false,
              );
              break;
          }
        },
        onError: (error) {
          finishVoiceInput(
            outcome: switch (error.errorMsg) {
              'error_no_match' || 'error_speech_timeout' => 'empty',
              'error_request_cancelled' => 'cancelled',
              _ => 'error',
            },
          );
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
    required VoiceInputSurface surface,
  }) async {
    final speech = value.speechToText;

    if (speech == null || !value.available) {
      unawaited(
        analytics.record(
          AnalyticsEvent.voiceInputFinished,
          parameters: {
            'surface': surface.eventValue,
            'outcome': 'unavailable',
          },
        ),
      );
      return;
    }

    finishVoiceInput();
    activeAnalyticsSurface = surface;
    hasRecognizedSpeech = false;

    try {
      await speech.listen(
        onResult: (result) {
          hasRecognizedSpeech |= result.recognizedWords.trim().isNotEmpty;
          onResult(
            result.recognizedWords,
          );
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 30),
          localeId: locale,
          listenMode: ListenMode.dictation,
        ),
      );

      updateState(
        isListening: speech.isListening,
      );
    } catch (error) {
      finishVoiceInput(
        outcome: 'error',
      );

      log(
        'Starting speech recognition failed',
        error: error is PlatformException ? error.code : error.runtimeType,
      );
    }
  }

  /// Records one recognition outcome without sending recognized speech
  void finishVoiceInput({String? outcome}) {
    final surface = activeAnalyticsSurface;
    if (surface == null) {
      return;
    }

    activeAnalyticsSurface = null;

    unawaited(
      analytics.record(
        AnalyticsEvent.voiceInputFinished,
        parameters: {
          'surface': surface.eventValue,
          'outcome': outcome ?? (hasRecognizedSpeech ? 'recognized' : 'empty'),
        },
      ),
    );
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
      finishVoiceInput(
        outcome: 'error',
      );

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
