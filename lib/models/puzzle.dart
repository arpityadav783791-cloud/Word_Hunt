import 'difficulty_config.dart';
import 'word_entry.dart';

enum GameMode { regular, dailyChallenge }

class CellPosition {
  const CellPosition(this.row, this.column);

  final int row, column;

  Map<String, dynamic> toJson() => {'row': row, 'column': column};

  factory CellPosition.fromJson(Map<String, dynamic> json) {
    return CellPosition(json['row'] as int, json['column'] as int);
  }

  @override
  bool operator ==(Object other) =>
      other is CellPosition && other.row == row && other.column == column;

  @override
  int get hashCode => Object.hash(row, column);
}

class Puzzle {
  Puzzle({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.grid,
    required this.targetWords,
    required this.placements,
    this.dateKey,
  });

  final String id;
  final GameMode mode;
  final DifficultyConfig difficulty;
  final List<List<String>> grid;
  final List<WordEntry> targetWords;
  final Map<String, List<CellPosition>> placements;
  final String? dateKey;

  Map<String, dynamic> toJson() => {
    'id': id,
    'mode': mode.name,
    'difficulty': difficulty.level.name,
    'dateKey': dateKey,
    'grid': grid,
    'targetWords': targetWords.map((word) => word.toJson()).toList(),
    'placements': placements.map(
      (key, value) =>
          MapEntry(key, value.map((position) => position.toJson()).toList()),
    ),
  };

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    final level = DifficultyLevel.values.firstWhere(
      (value) => value.name == json['difficulty'],
    );

    final difficulty = DifficultyConfig.all.firstWhere(
      (value) => value.level == level,
    );

    return Puzzle(
      id: json['id'] as String,
      mode: GameMode.values.byName(json['mode'] as String),
      difficulty: difficulty,
      dateKey: json['dateKey'] as String?,
      grid: (json['grid'] as List)
          .map((row) => List<String>.from(row as List))
          .toList(),
      targetWords: (json['targetWords'] as List)
          .map(
            (word) =>
                WordEntry.fromJson(Map<String, dynamic>.from(word as Map)),
          )
          .toList(),
      placements: (json['placements'] as Map).map(
        (key, value) => MapEntry(
          key as String,
          (value as List)
              .map(
                (position) => CellPosition.fromJson(
                  Map<String, dynamic>.from(position as Map),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
