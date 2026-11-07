import '../data/progress_repository.dart';
import '../models/active_game.dart';
import '../models/player_progress.dart';
import '../models/word_usage.dart';

class ProgressService {
  ProgressService(this._repository);

  final ProgressRepository _repository;

  Future<PlayerProgress> loadProgress() => _repository.load();

  Future<PlayerProgress> completePuzzle(
    String puzzleId, {
    required List<String> wordIds,
  }) async {
    final p = await _repository.load();

    if (p.completedPuzzleIds.contains(puzzleId)) return p;

    final gameNumber = p.completedGames + 1;
    final now = DateTime.now();
    final history = Map<String, WordUsage>.from(p.wordHistory);

    for (final id in wordIds.toSet()) {
      final previous = history[id];

      history[id] = WordUsage(
        wordId: id,
        firstUsedGameNumber:
            previous?.firstUsedGameNumber ?? gameNumber,
        lastUsedGameNumber: gameNumber,
        totalUses: (previous?.totalUses ?? 0) + 1,
        lastUsedAt: now,
      );
    }

    final updated = p.copyWith(
      completedGames: gameNumber,
      foundWordIds: {...p.foundWordIds, ...wordIds},
      wordHistory: history,
      completedPuzzleIds: {...p.completedPuzzleIds, puzzleId},
    );

    await _repository.save(updated);
    return updated;
  }

  Future<void> saveSettings({
    String? themeMode,
    double? textScale,
    bool? soundEnabled,
  }) async {
    final p = await _repository.load();

    await _repository.save(
      p.copyWith(
        themeMode: themeMode,
        textScale: textScale,
        soundEnabled: soundEnabled,
      ),
    );
  }

  Future<void> saveActiveGame(ActiveGame game) =>
      _repository.saveActiveGame(game);

  Future<ActiveGame?> loadActiveGame() =>
      _repository.loadActiveGame();

  Future<void> clearActiveGame() =>
      _repository.clearActiveGame();

  Future<void> savePreferredDifficulty(String difficulty) async {
    final p = await _repository.load();

    await _repository.save(
      p.copyWith(preferredDifficulty: difficulty),
    );
  }
}
