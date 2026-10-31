import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import '../models/difficulty_config.dart';
import 'game_screen.dart';
import '../services/progress_service.dart';
import '../services/theme_controller.dart';

class WordMeaningsScreen extends StatelessWidget {
  const WordMeaningsScreen({
    super.key,
    required this.puzzle,
    required this.progress,
    required this.theme,
  });
  final Puzzle puzzle;
  final ProgressService progress;
  final ThemeController theme;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Words and Their Meanings')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Keep learning',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Here are all the words you found, with their meanings and examples.',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < puzzle.targetWords.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ${puzzle.targetWords[i].word}',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      puzzle.targetWords[i].category,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(puzzle.targetWords[i].definition),
                    const SizedBox(height: 8),
                    Text(
                      'Example: ${puzzle.targetWords[i].exampleSentence}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Home'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final saved = await progress.loadProgress();
              if (!context.mounted) return;
              final level = DifficultyLevel.values.firstWhere(
                (e) => e.name == saved.preferredDifficulty,
                orElse: () => DifficultyLevel.easy,
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    progress: progress,
                    theme: theme,
                    difficulty: DifficultyConfig.forLevel(level),
                    mode: GameMode.regular,
                  ),
                ),
                (route) => route.isFirst,
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Play again'),
          ),
        ],
      ),
    ),
  );
}
