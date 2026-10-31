import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import '../services/progress_service.dart';
import '../services/theme_controller.dart';
import 'word_meanings_screen.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({
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
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 88,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'You found all ${puzzle.targetWords.length} words. Great job!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordMeaningsScreen(
                          puzzle: puzzle,
                          progress: progress,
                          theme: theme,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Learn the word meanings'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
