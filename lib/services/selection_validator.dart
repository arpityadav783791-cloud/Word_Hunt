import '../models/puzzle.dart';
import '../models/word_entry.dart';

class SelectionValidator {
  List<CellPosition>? pathBetween(
    CellPosition start,
    CellPosition end,
    int size,
  ) {
    final rd = end.row - start.row, cd = end.column - start.column;
    if (rd == 0 && cd == 0) return [start];
    if (rd != 0 && cd != 0 && rd.abs() != cd.abs()) return null;
    final rs = rd == 0 ? 0 : rd ~/ rd.abs();
    final cs = cd == 0 ? 0 : cd ~/ cd.abs();
    final steps = rd.abs() > cd.abs() ? rd.abs() : cd.abs();
    return List.generate(
      steps + 1,
      (i) => CellPosition(start.row + rs * i, start.column + cs * i),
    );
  }

  WordEntry? matchSelection({
    required List<CellPosition> selectedPath,
    required Puzzle puzzle,
  }) {
    for (final word in puzzle.targetWords) {
      final intended = puzzle.placements[word.id];
      if (intended == null || intended.length != selectedPath.length) continue;
      if (_same(selectedPath, intended) ||
          _same(selectedPath, intended.reversed.toList())) {
        return word;
      }
    }
    return null;
  }

  bool _same(List<CellPosition> a, List<CellPosition> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
