import '../models/player_progress.dart';
import '../models/active_game.dart';

abstract class ProgressRepository {
  Future<PlayerProgress> load();

  Future<void> save(PlayerProgress progress);

  // Save unfinished game
  Future<void> saveActiveGame(ActiveGame game);

  // Restore unfinished game
  Future<ActiveGame?> loadActiveGame();

  // Delete saved game after completion
  Future<void> clearActiveGame();
}
