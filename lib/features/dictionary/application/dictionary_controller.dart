import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/settings/settings_notifier.dart';
import '../../../data/dictionary/lexicon.dart';

class DictionaryUiState {
  const DictionaryUiState({
    this.query = '',
    this.result,
    this.suggestions = const [],
    this.recent = const [],
    this.favorites = const {},
  });

  final String query;
  final WordLookupResult? result;
  final List<String> suggestions;
  final List<RecentWord> recent;
  final Set<String> favorites;

  DictionaryUiState copyWith({
    String? query,
    WordLookupResult? result,
    bool clearResult = false,
    List<String>? suggestions,
    List<RecentWord>? recent,
    Set<String>? favorites,
  }) {
    return DictionaryUiState(
      query: query ?? this.query,
      result: clearResult ? null : (result ?? this.result),
      suggestions: suggestions ?? this.suggestions,
      recent: recent ?? this.recent,
      favorites: favorites ?? this.favorites,
    );
  }
}

class WordLookupResult {
  const WordLookupResult({
    required this.word,
    required this.valid,
    required this.points,
    this.definition = '',
    this.partOfSpeech = '',
  });

  final String word;
  final bool valid;
  final int points;
  final String definition;
  final String partOfSpeech;
}

class RecentWord {
  const RecentWord({required this.word, required this.valid});

  final String word;
  final bool valid;
}

final dictionaryControllerProvider =
    NotifierProvider<DictionaryController, DictionaryUiState>(
      DictionaryController.new,
    );

class DictionaryController extends Notifier<DictionaryUiState> {
  Timer? _debounce;

  @override
  DictionaryUiState build() {
    ref.onDispose(() => _debounce?.cancel());
    Future.microtask(_hydrateHistory);
    return const DictionaryUiState();
  }

  Future<void> _hydrateHistory() async {
    final history = await ref.read(lookupHistoryRepositoryProvider).recent();
    final favs = await ref.read(favoritesRepositoryProvider).allWords();
    state = state.copyWith(
      recent: history
          .map((e) => RecentWord(word: e.word, valid: e.valid))
          .toList(),
      favorites: favs,
    );
  }

  void setQuery(String raw) {
    final query = raw.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    state = state.copyWith(
      query: query,
      clearResult: state.result?.word != query,
      suggestions: const [],
    );
    _debounce?.cancel();
    if (query.isEmpty) {
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 80), () {
      _updateSuggestions(query);
    });
  }

  void clearQuery() {
    _debounce?.cancel();
    state = state.copyWith(query: '', clearResult: true, suggestions: const []);
  }

  void _updateSuggestions(String query) {
    final lexicon = ref.read(lexiconProvider).asData?.value;
    if (lexicon == null) {
      return;
    }
    state = state.copyWith(suggestions: lexicon.suggest(query));
  }

  Future<void> check([String? word]) async {
    final target = (word ?? state.query).toUpperCase();
    if (target.isEmpty) {
      return;
    }

    final lexicon = ref.read(lexiconProvider).asData?.value;
    if (lexicon == null) {
      return;
    }

    final valid = lexicon.isValid(target);
    final entry = lexicon.entry(target);
    final result = WordLookupResult(
      word: target,
      valid: valid,
      points: Lexicon.points(target),
      definition: entry?.definition ?? '',
      partOfSpeech: entry?.partOfSpeech ?? '',
    );

    await ref
        .read(lookupHistoryRepositoryProvider)
        .record(word: target, valid: valid);

    final history = await ref.read(lookupHistoryRepositoryProvider).recent();
    state = state.copyWith(
      query: target,
      result: result,
      suggestions: const [],
      recent: history
          .map((e) => RecentWord(word: e.word, valid: e.valid))
          .toList(),
    );
  }

  Future<void> toggleFavorite() async {
    final word = state.result?.word;
    if (word == null) {
      return;
    }
    final locale = ref.read(settingsProvider).dictionaryLocale.name;
    await ref
        .read(favoritesRepositoryProvider)
        .toggle(word: word, lexicon: locale);
    final favs = await ref.read(favoritesRepositoryProvider).allWords();
    state = state.copyWith(favorites: favs);
  }

  Future<void> clearRecent() async {
    await ref.read(lookupHistoryRepositoryProvider).clear();
    state = state.copyWith(recent: const []);
  }
}
