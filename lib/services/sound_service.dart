import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _successPlayer = AudioPlayer();
  static final AudioPlayer _completePlayer = AudioPlayer();
  static final AudioPlayer _leavePlayer = AudioPlayer();
  static final AudioPlayer _resumePlayer = AudioPlayer();

  static Future<void> _play(
    AudioPlayer player,
    String filename,
    bool enabled,
  ) async {
    if (!enabled) return;

    try {
      await player.stop();
      await player.play(AssetSource('audio/$filename'));
    } catch (e) {
      // Audio failures must not interrupt gameplay.
    }
  }

  static Future<void> success(bool enabled) =>
      _play(_successPlayer, 'success.wav', enabled);

  static Future<void> complete(bool enabled) =>
      _play(_completePlayer, 'complete.wav', enabled);

  static Future<void> leave(bool enabled) =>
      _play(_leavePlayer, 'leave.wav', enabled);

  static Future<void> resume(bool enabled) =>
      _play(_resumePlayer, 'resume.wav', enabled);
}
