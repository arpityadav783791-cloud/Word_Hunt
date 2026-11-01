import 'package:english_words/english_words.dart' as english;

import '../models/word_entry.dart';

class WordDatabase {
  WordDatabase();

  List<WordEntry>? _cachedWords;

  List<WordEntry> getAllWords() {
    return _cachedWords ??= _loadWords();
  }

  List<WordEntry> _loadWords() {
    final wordsById = <String, WordEntry>{};

    for (final raw in english.all) {
      final value = raw.toLowerCase().trim();

      if (value.length < 3 ||
          !RegExp(r'^[a-z]+$').hasMatch(value)) {
        continue;
      }

      wordsById.putIfAbsent(
        value,
        () => WordEntry(
          word: value.toUpperCase(),
          definition: 'Definition not available in the offline word list.',
          exampleSentence:
              'Try using ${value.toUpperCase()} in a sentence of your own.',
          category: 'Vocabulary',
        ),
      );
    }

    return wordsById.values.toList(growable: false);
  }
}
