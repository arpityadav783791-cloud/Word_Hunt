import 'package:flutter/material.dart';

import '../models/active_game.dart';
import '../models/puzzle.dart';
import '../services/progress_service.dart';
import '../services/theme_controller.dart';
import 'difficulty_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.progress, required this.theme});

  final ProgressService progress;
  final ThemeController theme;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  ActiveGame? _activeGame;
  bool _checkingSavedGame = true;

  @override
  void initState() {
    super.initState();
    _loadActiveGame();
  }

  Future<void> _loadActiveGame() async {
    final game = await widget.progress.loadActiveGame();

    if (!mounted) return;

    setState(() {
      _activeGame = game;
      _checkingSavedGame = false;
    });
  }

  Future<void> _resumeGame() async {
    final savedGame = _activeGame;
    if (savedGame == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          progress: widget.progress,
          theme: widget.theme,
          difficulty: savedGame.puzzle.difficulty,
          mode: savedGame.puzzle.mode,
          resumeGame: savedGame,
        ),
      ),
    );

    if (!mounted) return;
    await _loadActiveGame();
  }

  void _choose(GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DifficultyScreen(
          progress: widget.progress,
          theme: widget.theme,
          mode: mode,
        ),
      ),
    ).then((_) => _loadActiveGame());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 52,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Word Hunt',
                    style: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find hidden words. Discover their meanings. '
                    'Learn something new every day.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (_checkingSavedGame)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    )
                  else if (_activeGame != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _resumeGame,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Resume Game'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_activeGame!.puzzle.difficulty.label} · '
                      '${_activeGame!.foundWordIds.length}/'
                      '${_activeGame!.puzzle.targetWords.length} words found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _choose(GameMode.regular),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play Game'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _choose(GameMode.dailyChallenge),
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: const Text('Daily Challenge'),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                          progress: widget.progress,
                          theme: widget.theme,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Settings'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No scores. No pressure. Just words.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
