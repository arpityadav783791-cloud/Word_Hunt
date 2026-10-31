import 'puzzle.dart';

class ActiveGame {
  const ActiveGame({required this.puzzle, required this.foundWordIds});

  final Puzzle puzzle;
  final Set<String> foundWordIds;

  Map<String, dynamic> toJson() => {
    'puzzle': puzzle.toJson(),
    'foundWordIds': foundWordIds.toList(),
  };

  factory ActiveGame.fromJson(Map<String, dynamic> json) {
    return ActiveGame(
      puzzle: Puzzle.fromJson(Map<String, dynamic>.from(json['puzzle'] as Map)),
      foundWordIds: Set<String>.from(json['foundWordIds'] as List),
    );
  }
}
