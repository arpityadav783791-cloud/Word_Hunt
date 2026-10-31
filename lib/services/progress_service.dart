import '../data/progress_repository.dart';
import '../models/active_game.dart';
import '../models/player_progress.dart';

class ProgressService {
  ProgressService(this._repository);

  final ProgressRepository _repository;

  Future<PlayerProgress> loadProgress() => _repository.load();

  // Existing progress methods

  Future<void> recordFoundWord(String wordId) async {
    final p = await _repository.load();
    if (p.foundWordIds.contains(wordId)) return;

    await _repository.save(
      p.copyWith(foundWordIds: {...p.foundWordIds, wordId}),
    );
  }

  Future<PlayerProgress> completePuzzle(String puzzleId) async {
    final p = await _repository.load();
    if (p.completedPuzzleIds.contains(puzzleId)) return p;

    final updated = p.copyWith(
      completedGames: p.completedGames + 1,
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

  // New active-game methods

  Future<void> saveActiveGame(ActiveGame game) =>
      _repository.saveActiveGame(game);

  Future<ActiveGame?> loadActiveGame() => _repository.loadActiveGame();

  Future<void> clearActiveGame() => _repository.clearActiveGame();

  Future<void> savePreferredDifficulty(String difficulty) async {
    final p = await _repository.load();

    await _repository.save(p.copyWith(preferredDifficulty: difficulty));
  }
}
