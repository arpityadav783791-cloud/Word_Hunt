import '../models/difficulty_config.dart';

class DailyChallengeService {
  String dateKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  String labelFor(DifficultyConfig config, [DateTime? date]) =>
      'Daily Challenge · ${dateKey(date)} · ${config.label}';
}
