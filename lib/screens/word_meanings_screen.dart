import 'package:flutter/material.dart';

import '../data/dictionary_cache.dart';
import '../models/puzzle.dart';
import '../models/difficulty_config.dart';
import '../services/dictionary_api_service.dart';
import 'game_screen.dart';
import '../services/progress_service.dart';
import '../services/theme_controller.dart';

class WordMeaningsScreen extends StatelessWidget {
  WordMeaningsScreen({
    super.key,
    required this.puzzle,
    required this.progress,
    required this.theme,
  });

  final Puzzle puzzle;
  final ProgressService progress;
  final ThemeController theme;

  final DictionaryCache _cache = DictionaryCache();
  final DictionaryApiService _api = DictionaryApiService();

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
            _meaningCard(context, i),

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

  Widget _meaningCard(BuildContext context, int index) {
    final word = puzzle.targetWords[index];

    return FutureBuilder(
      future: _cache.getOrFetch(word.normalizedWord, _api),
      builder: (context, snapshot) {
        final entry = snapshot.data;

        final definition = entry?.definition ??
            (snapshot.connectionState == ConnectionState.waiting
                ? 'Loading definition...'
                : word.definition);

        final example = entry?.exampleSentence ??
            (snapshot.connectionState == ConnectionState.waiting
                ? 'Loading example...'
                : word.exampleSentence);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${word.word}',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  entry?.partOfSpeech ?? word.category,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(definition),
                const SizedBox(height: 8),
                Text(
                  'Example: $example',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
                if (snapshot.hasError)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Dictionary unavailable. Showing offline content.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
