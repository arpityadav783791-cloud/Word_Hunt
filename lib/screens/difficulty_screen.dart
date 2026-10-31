import 'package:flutter/material.dart';
import '../models/difficulty_config.dart';
import '../models/puzzle.dart';
import '../services/progress_service.dart';
import '../services/theme_controller.dart';
import 'game_screen.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key, required this.progress, required this.theme, required this.mode});
  final ProgressService progress;
  final ThemeController theme;
  final GameMode mode;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(mode == GameMode.dailyChallenge ? 'Daily Challenge' : 'Choose Difficulty')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Choose your level', style: Theme.of(context).textTheme.headlineMedium
        ?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('You can change difficulty whenever you want.'),
      const SizedBox(height: 20),
      for (final config in DifficultyConfig.all)
        Card(child: ListTile(contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(child: Text('${config.wordCount}')),
          title: Text(config.label, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Padding(padding: const EdgeInsets.only(top: 6),
            child: Text('${config.gridSize} × ${config.gridSize} grid · ${config.wordCount} words\n${config.description}')),
          isThreeLine: true, trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            if (mode == GameMode.regular) await progress.savePreferredDifficulty(config.level.name);
            if (!context.mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
              GameScreen(progress: progress, theme: theme, difficulty: config, mode: mode)));
          },
        )),
    ]),
  );
}
