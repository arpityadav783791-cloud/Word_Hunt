
import 'package:flutter_test/flutter_test.dart';

import 'package:word_hunt/data/progress_repository.dart';
import 'package:word_hunt/models/active_game.dart';
import 'package:word_hunt/models/player_progress.dart';
import 'package:word_hunt/services/progress_service.dart';

class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository() : _progress = const PlayerProgress();

  PlayerProgress _progress;
  ActiveGame? _activeGame;

  @override
  Future<PlayerProgress> load() async => _progress;

  @override
  Future<void> save(PlayerProgress progress) async {
    _progress = progress;
  }

  @override
  Future<void> saveActiveGame(ActiveGame game) async {
    _activeGame = game;
  }

  @override
  Future<ActiveGame?> loadActiveGame() async => _activeGame;

  @override
  Future<void> clearActiveGame() async {
    _activeGame = null;
  }
}

void main() {
  late FakeProgressRepository repository;
  late ProgressService service;

  setUp(() {
    repository = FakeProgressRepository();
    service = ProgressService(repository);
  });

  group('ProgressService.completePuzzle', () {
    test('duplicate word IDs are counted only once', () async {
      final progress = await service.completePuzzle(
        'puzzle-1',
        wordIds: ['cat', 'cat', 'dog', 'dog'],
      );

      expect(progress.completedGames, 1);
      expect(progress.wordHistory.length, 2);

      expect(progress.wordHistory['cat']?.totalUses, 1);
      expect(progress.wordHistory['dog']?.totalUses, 1);
    });

    test('completing the same puzzle twice does not update history',
        () async {
      await service.completePuzzle(
        'puzzle-1',
        wordIds: ['cat', 'dog'],
      );

      final progress = await service.completePuzzle(
        'puzzle-1',
        wordIds: ['cat', 'dog', 'bird'],
      );

      expect(progress.completedGames, 1);
      expect(progress.wordHistory.length, 2);
      expect(progress.wordHistory.containsKey('bird'), false);
      expect(progress.wordHistory['cat']?.totalUses, 1);
    });

    test('using a word in another puzzle increments its usage count',
        () async {
      await service.completePuzzle(
        'puzzle-1',
        wordIds: ['cat'],
      );

      final progress = await service.completePuzzle(
        'puzzle-2',
        wordIds: ['cat'],
      );

      expect(progress.completedGames, 2);
      expect(progress.wordHistory['cat']?.totalUses, 2);
      expect(progress.wordHistory['cat']?.lastUsedGameNumber, 2);
    });
  });
}

