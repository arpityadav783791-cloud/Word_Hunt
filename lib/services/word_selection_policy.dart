import 'dart:math';

import '../models/difficulty_config.dart';
import '../models/player_progress.dart';
import '../models/word_entry.dart';

class InsufficientWordsException implements Exception {
  InsufficientWordsException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WordSelectionPolicy {
  static const repetitionThreshold = 1000;

  List<WordEntry> selectWords({
    required List<WordEntry> catalog,
    required PlayerProgress progress,
    required DifficultyConfig config,
    required Random random,
  }) {
    final canRepeat = progress.completedGames >= repetitionThreshold;
    final unique = <String, WordEntry>{};
    for (final word in catalog) {
      final normalized = word.normalizedWord;
      if (normalized.length < config.minWordLength ||
          normalized.length > config.maxWordLength ||
          !RegExp(r'^[a-z]+$').hasMatch(normalized)) {
        continue;
      }
      if (!canRepeat && progress.foundWordIds.contains(word.id)) continue;
      unique.putIfAbsent(word.id, () => word);
    }
    final candidates = unique.values.toList()..shuffle(random);
    if (candidates.length < config.wordCount) {
      throw InsufficientWordsException(
        'Only ${candidates.length} unused words are available for ${config.label}; '
        '${config.wordCount} are needed. Add more words to the catalog. '
        'Words will not repeat before 1,000 completed games.',
      );
    }
    return candidates.take(config.wordCount).toList();
  }
}
