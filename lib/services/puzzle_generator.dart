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

  static const _horizontal = [_Direction(0, 1), _Direction(0, -1)];

  static const _vertical = [_Direction(1, 0), _Direction(-1, 0)];

  static const _diagonal = [
    _Direction(1, 1),
    _Direction(-1, -1),
    _Direction(1, -1),
    _Direction(-1, 1),
  ];

  static const _all = [..._horizontal, ..._vertical, ..._diagonal];

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

      final sorted = [...words]..shuffle(random);

      sorted.sort(
        (a, b) => b.normalizedWord.length.compareTo(a.normalizedWord.length),
      );

      final directions = _balancedDirections(sorted.length, random);

      final success = _placeWords(
        index: 0,
        words: sorted,
        directions: directions,
        grid: grid,
        placements: placements,
        random: random,
      );

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
      'after 100 attempts.',
    );
  }

  List<_Direction> _balancedDirections(int wordCount, Random random) {
    final directions = <_Direction>[];

    if (wordCount == 4) {
      final horizontal = [..._horizontal]..shuffle(random);
      final vertical = [..._vertical]..shuffle(random);
      final diagonal = [..._diagonal]..shuffle(random);

      directions.add(horizontal.first);
      directions.add(vertical.first);
      directions.add(diagonal[0]);
      directions.add(diagonal[1]);
    } else {
      // Use every direction at least once.
      directions.addAll(_all);

      // Add extra directions randomly for larger difficulties.
      while (directions.length < wordCount) {
        directions.add(_all[random.nextInt(_all.length)]);
      }
    }

    directions.shuffle(random);
    return directions;
  }

  bool _placeWords({
    required int index,
    required List<WordEntry> words,
    required List<_Direction> directions,
    required List<List<String?>> grid,
    required Map<String, List<CellPosition>> placements,
    required Random random,
  }) {
    if (index == words.length) return true;

    final wordEntry = words[index];
    final word = wordEntry.normalizedWord.toUpperCase();
    final direction = directions[index];
    final size = grid.length;

    final startingPositions = List.generate(size * size, (i) => i)
      ..shuffle(random);

    for (final start in startingPositions) {
      final row = start ~/ size;
      final column = start % size;

      final path = _buildPath(word, grid, direction, row, column);

      if (path == null) continue;

      final newlyFilled = <CellPosition>[];

      for (var i = 0; i < path.length; i++) {
        final cell = path[i];

        if (grid[cell.row][cell.column] == null) {
          grid[cell.row][cell.column] = word[i];
          newlyFilled.add(cell);
        }
      }

      placements[wordEntry.id] = path;

      if (_placeWords(
        index: index + 1,
        words: words,
        directions: directions,
        grid: grid,
        placements: placements,
        random: random,
      )) {
        return true;
      }

      // Undo this placement and try another position.
      placements.remove(wordEntry.id);

      for (final cell in newlyFilled) {
        grid[cell.row][cell.column] = null;
      }
    }

    return false;
  }

  List<CellPosition>? _buildPath(
    String word,
    List<List<String?>> grid,
    _Direction direction,
    int row,
    int column,
  ) {
    final size = grid.length;
    final path = <CellPosition>[];

    for (var i = 0; i < word.length; i++) {
      final r = row + direction.r * i;
      final c = column + direction.c * i;

      if (r < 0 ||
          r >= size ||
          c < 0 ||
          c >= size ||
          (grid[r][c] != null && grid[r][c] != word[i])) {
        return null;
      }

      path.add(CellPosition(r, c));
    }

    return path;
  }

  int _stableSeed(String input) {
    var hash = 17;

    for (final unit in input.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return hash;
  }
}
