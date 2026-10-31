import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/active_game.dart';
import '../models/player_progress.dart';
import 'progress_repository.dart';

class SharedPreferencesProgressRepository implements ProgressRepository {
  static const _key = 'word_hunt.player_progress.v1';
  static const _activeGameKey = 'word_hunt.active_game.v1';

  @override
  Future<PlayerProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return const PlayerProgress();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return PlayerProgress.fromJson(decoded);
      }
    } catch (_) {
      // Recover from invalid saved progress.
    }

    return const PlayerProgress();
  }

  @override
  Future<void> save(PlayerProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(progress.toJson()));
  }

  @override
  Future<void> saveActiveGame(ActiveGame game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeGameKey, jsonEncode(game.toJson()));
  }

  @override
  Future<ActiveGame?> loadActiveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeGameKey);

    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ActiveGame.fromJson(decoded);
      }
    } catch (_) {
      await clearActiveGame();
    }

    return null;
  }

  @override
  Future<void> clearActiveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeGameKey);
  }
}
