import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/meal.dart';
import '../../services/hive_service.dart';
import '../../util/group_meals.dart';
import '../../util/search.dart';

class SearchController extends ValueNotifier<({List<Object> items, bool isTextFieldEmpty})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final HiveService hive;

  SearchController({
    required this.hive,
  }) : super((
         items: [],
         isTextFieldEmpty: true,
       ));

  ///
  /// VARIABLES
  ///

  late final searchTextEditingController = TextEditingController();

  ///
  /// INIT
  ///

  void init() {
    searchTextEditingController.addListener(updateState);
  }

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    searchTextEditingController
      ..removeListener(updateState)
      ..dispose();
  }

  ///
  /// METHODS
  ///

  /// Updates `state`, depending on passed [List<Meal>]
  void updateState() {
    /// Get `query`
    final searchText = searchTextEditingController.text.trim();

    /// Get all `meals`
    final all = hive.getMeals();

    /// Search all `meals`
    final items = searchMeals(
      items: all,
      query: searchText,
    );

    /// Sort `meals`
    final sortedItems = items
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

    /// Update `state`
    value = (
      items: searchText.isEmpty
          ? []
          : getGroupedMealsByDate(
              sortedItems,
            ),
      isTextFieldEmpty: searchText.isEmpty,
    );
  }

  /// Searches meals using passed `query`
  List<Meal> searchMeals({
    required List<Meal> items,
    required String query,
    // Higher to be stricter, lower to be fuzzier
    int threshold = 80,
  }) {
    final q = query.trim();
    if (q.isEmpty) {
      return items;
    }

    /// Short queries: only literal contains to avoid noise
    if (q.length <= 3) {
      final nq = normalizeString(q);

      return items
          .where(
            (m) => (m.name != null && normalizeString(m.name!).contains(nq)) || (m.originalText != null && normalizeString(m.originalText!).contains(nq)),
          )
          .toList();
    }

    final scored = <({Meal m, int score})>[];

    for (final m in items) {
      final fields = [
        if ((m.name ?? '').isNotEmpty) m.name!,
        if ((m.originalText ?? '').isNotEmpty) m.originalText!,
      ];

      /// Require trigram overlap with at least one field unless literal contains
      final passesGuard = fields.any((f) {
        final nf = normalizeString(f);
        return nf.contains(normalizeString(q)) || sharesTrigram(q, f);
      });

      if (!passesGuard) {
        continue;
      }

      final score = fields
          .map((f) => getFuzzyScore(q, f))
          .fold<int>(
            0,
            (mx, v) => v > mx ? v : mx,
          );

      if (score >= threshold) {
        scored.add((m: m, score: score));
      }
    }

    scored.sort((a, b) {
      final s = b.score.compareTo(a.score);
      return s != 0 ? s : (a.m.name ?? '').compareTo(b.m.name ?? '');
    });

    return [for (final e in scored) e.m];
  }

  /// Triggered when the user deletes meal
  Future<void> deleteMeal({
    required Meal meal,
  }) async {
    await hive.deleteMeal(
      meal: meal,
    );

    updateState();
  }
}
