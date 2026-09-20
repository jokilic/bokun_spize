import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../models/meal/meal.dart';
import '../../services/firebase_service.dart';
import '../../services/speech_to_text_service.dart';
import '../../util/null_state.dart';
import '../../util/search.dart';

class SearchController extends ValueNotifier<({String query, List<Meal> meals, bool isLoading, String? error})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final FirebaseService firebase;
  final SpeechToTextService speechToText;

  SearchController({
    required this.firebase,
    required this.speechToText,
  }) : super((
         query: '',
         meals: const [],
         isLoading: false,
         error: null,
       ));

  ///
  /// INIT
  ///

  void init() {
    textEditingController.addListener(onSearchTextChanged);
    focusNode.addListener(stopSpeechToTextIfTextFieldFocused);
  }

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    isDisposed = true;
    searchVersion++;
    searchDebounce?.cancel();

    /// Stop listener & update `state`
    if (speechToText.value.isListening) {
      speechToText.stopListening();
    }

    speechToText.updateState(
      isListening: false,
    );

    /// Dispose [TextEditingController]
    textEditingController
      ..removeListener(onSearchTextChanged)
      ..dispose();

    /// Dispose [FocusNode]
    focusNode
      ..removeListener(stopSpeechToTextIfTextFieldFocused)
      ..dispose();

    super.dispose();
  }

  ///
  /// VARIABLES
  ///

  late final textEditingController = TextEditingController();
  late final focusNode = FocusNode();

  Timer? searchDebounce;
  Future<List<Meal>?>? mealsRequest;

  var searchVersion = 0;
  var isDisposed = false;

  ///
  /// METHODS
  ///

  /// Triggered when the user types something
  void onSearchTextChanged() {
    /// Calculate proper `query`
    final query =
        normalizeString(
          textEditingController.text,
        ).replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

    if (isDisposed || query == value.query) {
      return;
    }

    /// Cancel debounce
    searchDebounce?.cancel();
    searchVersion++;

    /// Check if search should happen
    final canSearch = query.characters.length >= minimumSearchLength;

    /// Update state
    updateState(
      query: query,
      meals: const [],
      isLoading: canSearch,
      error: null,
    );

    /// Restart debounce
    if (canSearch) {
      searchDebounce = Timer(
        BokunSpizeDurations.searchDelay,
        searchMeals,
      );
    }
  }

  /// Triggers search logic
  Future<void> searchMeals() async {
    /// Cancel debounce
    searchDebounce?.cancel();

    if (isDisposed || value.query.characters.length < minimumSearchLength) {
      return;
    }

    final query = value.query;
    final version = ++searchVersion;

    /// Update state
    updateState(
      query: query,
      meals: const [],
      isLoading: true,
      error: null,
    );

    try {
      /// Get `meals` from [Firebase]
      mealsRequest ??= firebase.getMeals();
      final meals = await mealsRequest;

      if (isDisposed || version != searchVersion) {
        return;
      }

      /// Error happened
      if (meals == null) {
        throw StateError(
          'Meals could not be loaded',
        );
      }

      final terms = tokenizeString(query);
      final matches = <({Meal meal, int score})>[];

      for (final meal in meals) {
        /// Ignore loading meals
        if (meal.isLoading || terms.isEmpty) {
          continue;
        }

        /// Include meal names, original texts and foods
        final searchableText = [
          meal.name ?? '',
          meal.originalText ?? '',
          ...?meal.foods?.map(
            (food) => food.name,
          ),
        ].join(' ');

        /// Calculate result scores
        final scores = terms
            .map(
              (term) => getFuzzyScore(
                term,
                searchableText,
              ),
            )
            .toList();

        /// Require every term to match so unrelated words cannot inflate the total score
        if (scores.every((score) => score >= minimumFuzzyScore)) {
          matches.add(
            (
              meal: meal,
              score: scores.fold<int>(
                0,
                (total, score) => total + score,
              ),
            ),
          );
        }
      }

      /// Show the strongest matches first and prefer recent meals when scores are equal
      matches.sort(
        (a, b) {
          final scoreOrder = b.score.compareTo(a.score);

          return scoreOrder != 0
              ? scoreOrder
              : b.meal.createdAt.compareTo(
                  a.meal.createdAt,
                );
        },
      );

      /// Generate `results`
      final results = matches
          .map(
            (match) => match.meal,
          )
          .toList();

      /// Update state with `results`
      updateState(
        query: query,
        meals: results,
        isLoading: false,
        error: null,
      );
    } catch (error) {
      if (isDisposed || version != searchVersion) {
        return;
      }

      mealsRequest = null;

      log(
        'Searching meals failed',
        error: error,
      );

      updateState(
        query: query,
        meals: const [],
        isLoading: false,
        error: 'Meals could not be loaded. Please try again.',
      );
    }
  }

  /// Stop speech recognition if [TextField] becomes active
  Future<void> stopSpeechToTextIfTextFieldFocused() async {
    if (!focusNode.hasFocus) {
      return;
    }

    await stopSpeechToTextIfListening();
  }

  /// Stop speech recognition when the user starts editing text manually
  Future<void> stopSpeechToTextIfListening() async {
    if (!speechToText.value.isListening) {
      return;
    }

    await speechToText.stopListening();
  }

  /// Triggered when the user presses [SpeechToText] button
  Future<void> onSpeechToTextPressed({
    required String locale,
    required bool speechToTextAvailable,
  }) async {
    if (!speechToTextAvailable) {
      await speechToText.loadSpeechToText();
    }

    if (isDisposed) {
      return;
    }

    /// Save current [TextEditingController] text
    final currentText = textEditingController.text;

    /// [SpeechToText] was disabled, start listening
    if (!speechToText.value.isListening) {
      await speechToText.startListening(
        onResult: (words) {
          if (isDisposed) {
            return;
          }

          /// Add new `words` to [TextEditingController]
          if (currentText.isNotEmpty) {
            textEditingController.text = '$currentText $words';
          } else {
            textEditingController.text = words;
          }
        },
        locale: locale,
      );
    }
    /// [SpeechToText] was enabled, stop listening
    else {
      await speechToText.stopListening();
    }
  }

  /// Updates `state`
  void updateState({
    String? query,
    List<Meal>? meals,
    bool? isLoading,
    Object? error = nullStateNoChange,
  }) => value = (
    query: query ?? value.query,
    meals: meals != null ? List<Meal>.unmodifiable(meals) : value.meals,
    isLoading: isLoading ?? value.isLoading,
    error: identical(error, nullStateNoChange) ? value.error : error as String?,
  );
}
