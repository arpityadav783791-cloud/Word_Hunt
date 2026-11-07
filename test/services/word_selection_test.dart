import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:word_hunt/models/difficulty_config.dart';
import 'package:word_hunt/models/player_progress.dart';
import 'package:word_hunt/models/word_entry.dart';
import 'package:word_hunt/models/word_usage.dart';
import 'package:word_hunt/services/word_selection_policy.dart';

void main() {
  late WordSelectionPolicy policy;

  const config = DifficultyConfig(
    level: DifficultyLevel.easy,
    label: 'Test',
    gridSize: 4,
    wordCount: 1,
    minWordLength: 3,
    maxWordLength: 4,
    description: 'Test configuration',
  );

  final word = WordEntry(
    word: 'CAT',
    definition: 'A small animal',
    exampleSentence: 'The cat is sleeping.',
    category: 'Animals',
  );

  setUp(() {
    policy = WordSelectionPolicy();
  });

  group('Word cooldown', () {
    test('word remains unavailable before 1000 completed games', () {
      final progress = PlayerProgress(
        completedGames: 1000,
        wordHistory: {
          word.id: WordUsage(
            wordId: word.id,
            firstUsedGameNumber: 1,
            lastUsedGameNumber: 1,
            totalUses: 1,
            lastUsedAt: DateTime(2026, 1, 1),
          ),
        },
      );

      expect(
        () => policy.selectWords(
          catalog: [word],
          progress: progress,
          config: config,
          random: Random(1),
        ),
        throwsA(isA<InsufficientWordsException>()),
      );
    });

    test('word becomes available after 1000 completed games', () {
      final progress = PlayerProgress(
        completedGames: 1001,
        wordHistory: {
          word.id: WordUsage(
            wordId: word.id,
            firstUsedGameNumber: 1,
            lastUsedGameNumber: 1,
            totalUses: 1,
            lastUsedAt: DateTime(2026, 1, 1),
          ),
        },
      );

      final selected = policy.selectWords(
        catalog: [word],
        progress: progress,
        config: config,
        random: Random(1),
      );

      expect(selected.length, 1);
      expect(selected.first.id, word.id);
    });

    test('never-used words are eligible', () {
      final progress = PlayerProgress(completedGames: 50);

      final selected = policy.selectWords(
        catalog: [word],
        progress: progress,
        config: config,
        random: Random(1),
      );

      expect(selected.length, 1);
      expect(selected.first.id, word.id);
    });
  });
}
