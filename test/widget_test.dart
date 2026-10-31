import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt/models/player_progress.dart';

void main() {
  test('preferred difficulty survives progress serialization', () {
    const original = PlayerProgress(preferredDifficulty: 'expert');
    final restored = PlayerProgress.fromJson(original.toJson());
    expect(restored.preferredDifficulty, 'expert');
  });

  test('missing preferred difficulty defaults to Easy', () {
    final restored = PlayerProgress.fromJson(<String, dynamic>{});
    expect(restored.preferredDifficulty, 'easy');
  });
}
