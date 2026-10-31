import 'dart:math';

import '../models/difficulty_config.dart';
import '../models/player_progress.dart';
import '../models/puzzle.dart';
import '../models/word_entry.dart';
import 'word_selection_policy.dart';

class _Direction {
  const _Direction(this.r, this.c);

  final int r;
  final int c;
}

class PuzzleGenerator {
  PuzzleGenerator({WordSelectionPolicy? policy})
    : _policy = policy ?? WordSelectionPolicy();

  final WordSelectionPolicy _policy;

  static const _all = [
    _Direction(0, 1),
    _Direction(0, -1),
    _Direction(1, 0),
    _Direction(-1, 0),
    _Direction(1, 1),
    _Direction(-1, -1),
    _Direction(1, -1),
    _Direction(-1, 1),
  ];

  Puzzle generate({
    required List<WordEntry> catalog,
    required PlayerProgress progress,
    required DifficultyConfig difficulty,
    required GameMode mode,
    String? dateKey,
  }) {
    final size = difficulty.gridSize;

    final seed = mode == GameMode.dailyChallenge
        ? _stableSeed('${dateKey ?? 'unknown'}-${difficulty.level.name}')
        : DateTime.now().microsecondsSinceEpoch;

    final random = Random(seed);

    final directions = _all;

    for (var attempt = 0; attempt < 100; attempt++) {
      final words = _policy.selectWords(
        catalog: catalog,
        progress: progress,
        config: difficulty,
        random: random,
      );

      if (words.length != difficulty.wordCount) {
        throw StateError(
          'Expected ${difficulty.wordCount} words, '
          'but selected ${words.length}.',
        );
      }

      if (words.any((word) => word.normalizedWord.length > size)) {
        throw StateError(
          'A selected word is longer than the $size × $size grid.',
        );
      }

      final grid = List.generate(size, (_) => List<String?>.filled(size, null));

      final placements = <String, List<CellPosition>>{};

      final sorted = [...words]
        ..sort(
          (a, b) => b.normalizedWord.length.compareTo(a.normalizedWord.length),
        );

      var success = true;

      for (final word in sorted) {
        final path = _place(
          word.normalizedWord.toUpperCase(),
          grid,
          directions,
          random,
        );

        if (path == null) {
          success = false;
          break;
        }

        placements[word.id] = path;
      }

      if (!success) continue;

      const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

      final finished = List.generate(
        size,
        (r) => List.generate(
          size,
          (c) => grid[r][c] ?? alphabet[random.nextInt(alphabet.length)],
        ),
      );

      return Puzzle(
        id: mode == GameMode.dailyChallenge
            ? 'daily-${dateKey ?? 'unknown'}-${difficulty.level.name}'
            : 'regular-$seed',
        mode: mode,
        difficulty: difficulty,
        dateKey: dateKey,
        grid: finished,
        targetWords: words,
        placements: placements,
      );
    }

    throw StateError(
      'Could not fit the selected words into a $size × $size grid '
      'after 100 attempts. Try reducing the word count or word lengths.',
    );
  }

  List<CellPosition>? _place(
    String word,
    List<List<String?>> grid,
    List<_Direction> directions,
    Random random,
  ) {
    final size = grid.length;

    if (word.length > size) return null;

    for (var attempt = 0; attempt < 1000; attempt++) {
      final direction = directions[random.nextInt(directions.length)];

      final row = random.nextInt(size);
      final column = random.nextInt(size);

      final path = <CellPosition>[];
      var fits = true;

      for (var i = 0; i < word.length; i++) {
        final r = row + direction.r * i;
        final c = column + direction.c * i;

        if (r < 0 ||
            r >= size ||
            c < 0 ||
            c >= size ||
            (grid[r][c] != null && grid[r][c] != word[i])) {
          fits = false;
          break;
        }

        path.add(CellPosition(r, c));
      }

      if (!fits) continue;

      for (var i = 0; i < word.length; i++) {
        final cell = path[i];
        grid[cell.row][cell.column] = word[i];
      }

      return path;
    }

    return null;
  }

  int _stableSeed(String input) {
    var hash = 17;

    for (final unit in input.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return hash;
  }
}
