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
  static const repetitionCooldown = 1000;

  List<WordEntry> selectWords({
    required List<WordEntry> catalog,
    required PlayerProgress progress,
    required DifficultyConfig config,
    required Random random,
  }) {
    final unique = <String, WordEntry>{};

    for (final word in catalog) {
      final normalized = word.normalizedWord;
      if (normalized.length < config.minWordLength ||
          normalized.length > config.maxWordLength ||
          !RegExp(r'^[a-z]+$').hasMatch(normalized)) {
        continue;
      }

      final usage = progress.wordHistory[word.id];

      if (usage != null &&
          progress.completedGames - usage.lastUsedGameNumber <
              repetitionCooldown) {
        continue;
      }

      unique.putIfAbsent(word.id, () => word);
    }

    final candidates = unique.values.toList()..shuffle(random);

    if (candidates.length < config.wordCount) {
      throw InsufficientWordsException(
        'Only ${candidates.length} eligible words are available for '
        '${config.label}; ${config.wordCount} are needed.',
      );
    }

    return candidates.take(config.wordCount).toList();
  }
}
