import 'package:flutter/material.dart';
import 'progress_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._progress);
  final ProgressService _progress;
  String _mode = 'system';
  double _scale = 1;
  bool _sound = false;

  String get themeModeName => _mode;
  double get textScale => _scale;
  bool get soundEnabled => _sound;
  ThemeMode get themeMode => switch (_mode) {
    'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system
  };

  Future<void> load() async {
    final p = await _progress.loadProgress();
    _mode = p.themeMode; _scale = p.textScale; _sound = p.soundEnabled;
    notifyListeners();
  }
  Future<void> updateThemeMode(String value) async {
    if (!const {'system', 'light', 'dark'}.contains(value)) return;
    _mode = value; notifyListeners();
    await _progress.saveSettings(themeMode: value);
  }
  Future<void> updateTextScale(double value) async {
    _scale = value.clamp(0.85, 1.5).toDouble(); notifyListeners();
    await _progress.saveSettings(textScale: _scale);
  }
  Future<void> updateSoundEnabled(bool value) async {
    _sound = value; notifyListeners();
    await _progress.saveSettings(soundEnabled: value);
  }
}
