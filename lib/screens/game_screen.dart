import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/word_database.dart';
import '../models/active_game.dart';
import '../models/difficulty_config.dart';
import '../models/puzzle.dart';
import '../services/daily_challenge_service.dart';
import '../services/progress_service.dart';
import '../services/puzzle_generator.dart';
import '../services/selection_validator.dart';
import '../services/theme_controller.dart';
import '../widgets/letter_grid.dart';
import '../widgets/word_list.dart';
import 'congratulations_screen.dart';
import 'difficulty_screen.dart';

import 'dart:async';

import '../data/dictionary_cache.dart';
import '../services/dictionary_api_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.progress,
    required this.theme,
    required this.difficulty,
    required this.mode,
    this.resumeGame,
  });

  final ProgressService progress;
  final ThemeController theme;
  final DifficultyConfig difficulty;
  final GameMode mode;
  final ActiveGame? resumeGame;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _generator = PuzzleGenerator();
  final _validator = SelectionValidator();
  final _wordDatabase = WordDatabase();
  final _dictionaryApi = DictionaryApiService();
  final _dictionaryCache = DictionaryCache();

  Puzzle? _puzzle;
  String? _error;

  bool _loading = true;
  bool _completing = false;

  CellPosition? _selectedStart;
  final Set<String> _found = {};

  @override
  void initState() {
    super.initState();
    _createPuzzle();
  }

  Future<void> _prefetchPuzzleWords(Puzzle puzzle) async {
    await Future.wait(
      puzzle.targetWords.map((word) async {
        try {
          // Already downloaded? No API request needed.
          final cached = await _dictionaryCache.getEntry(word.normalizedWord);

          if (cached != null) return;

          // Fetch from API.
          final entry = await _dictionaryApi.lookupWord(word.normalizedWord);

          if (entry != null) {
            await _dictionaryCache.saveEntry(entry);
            debugPrint('Dictionary cached: ${word.word}');
          }
        } catch (e) {
          debugPrint('Dictionary prefetch failed for ${word.word}: $e');
        }
      }),
    );
  }

  Future<void> _createPuzzle() async {
    setState(() {
      _loading = true;
      _error = null;
      _puzzle = null;
      _selectedStart = null;
      _found.clear();
      _completing = false;
    });

    try {
      final savedGame = widget.resumeGame;

      if (savedGame != null) {
        _puzzle = savedGame.puzzle;
        unawaited(_prefetchPuzzleWords(_puzzle!));

        
        _found.addAll(savedGame.foundWordIds);
      } else {
        final progress = await widget.progress.loadProgress();

        final dateKey = widget.mode == GameMode.dailyChallenge
            ? DailyChallengeService().dateKey()
            : null;

        if (widget.mode == GameMode.dailyChallenge) {
          final dailyId = 'daily-$dateKey-${widget.difficulty.level.name}';

          if (progress.completedPuzzleIds.contains(dailyId)) {
            throw StateError(
              'You have already completed today\'s challenge '
              'at this difficulty.',
            );
          }
        }

        _puzzle = _generator.generate(
          catalog: _wordDatabase.getAllWords(),
          progress: progress,
          difficulty: widget.difficulty,
          mode: widget.mode,
          dateKey: dateKey,
        );

        // start dictionary downloads without blocking gameplay.
        unawaited(_prefetchPuzzleWords(_puzzle!));

        await _saveActiveGame();
      }

      if (!mounted) return;

      setState(() => _loading = false);
    } catch (e, stackTrace) {
      debugPrint('PUZZLE GENERATION ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _saveActiveGame() async {
    final puzzle = _puzzle;
    if (puzzle == null) return;

    await widget.progress.saveActiveGame(
      ActiveGame(puzzle: puzzle, foundWordIds: Set<String>.from(_found)),
    );
  }

  Future<void> _tapCell(CellPosition position) async {
    final puzzle = _puzzle;

    if (puzzle == null || _completing) return;

    if (_selectedStart == null) {
      setState(() => _selectedStart = position);
      return;
    }

    final start = _selectedStart!;

    if (start == position) {
      setState(() => _selectedStart = null);
      return;
    }

    final path = _validator.pathBetween(
      start,
      position,
      puzzle.difficulty.gridSize,
    );

    if (path == null) {
      setState(() => _selectedStart = position);
      return;
    }

    final word = _validator.matchSelection(selectedPath: path, puzzle: puzzle);

    if (word == null || _found.contains(word.id)) {
      setState(() => _selectedStart = null);
      return;
    }

    setState(() {
      _found.add(word.id);
      _selectedStart = null;
    });

    if (widget.theme.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }

    await _saveActiveGame();

    if (!mounted) return;

    if (_found.length == puzzle.targetWords.length) {
      await _finish(puzzle);
    }
  }

  Future<void> _handleDragSelection(
    CellPosition start,
    CellPosition end,
  ) async {
    if (_completing || _puzzle == null) return;

    // Reset any previous manual selection.
    if (_selectedStart != null) {
      setState(() => _selectedStart = null);
    }

    // Validate the complete dragged selection.
    final path = _validator.pathBetween(
      start,
      end,
      _puzzle!.difficulty.gridSize,
    );

    if (path == null) return;

    final word = _validator.matchSelection(
      selectedPath: path,
      puzzle: _puzzle!,
    );

    if (word == null || _found.contains(word.id)) return;

    setState(() {
      _found.add(word.id);
    });

    if (widget.theme.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }

    await _saveActiveGame();

    if (!mounted) return;

    if (_found.length == _puzzle!.targetWords.length) {
      await _finish(_puzzle!);
    }
  }

  Future<void> _finish(Puzzle puzzle) async {
    if (_completing) return;

    _completing = true;

    // Record words only after the complete puzzle is finished.
    await widget.progress.completePuzzle(
      puzzle.id,
      wordIds: puzzle.targetWords.map((word) => word.id).toList(),
    );
    await widget.progress.clearActiveGame();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CongratulationsScreen(
          puzzle: puzzle,
          progress: widget.progress,
          theme: widget.theme,
        ),
      ),
    );
  }

  void _changeDifficulty() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DifficultyScreen(
          progress: widget.progress,
          theme: widget.theme,
          mode: widget.mode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.difficulty.label),
      actions: [
        IconButton(
          tooltip: 'Change difficulty',
          onPressed: _changeDifficulty,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    ),
    body: SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorView()
          : _gameView(_puzzle!),
    ),
  );

  Widget _errorView() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded, size: 48),
          const SizedBox(height: 16),
          Text(
            'Unable to create this puzzle',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _createPuzzle,
            child: const Text('Try again'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
        ],
      ),
    ),
  );

  Widget _gameView(Puzzle puzzle) {
    final remaining = puzzle.targetWords.length - _found.length;

    return Column(
      children: [
        // Game title and remaining words
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.mode == GameMode.dailyChallenge
                    ? 'Daily Challenge · ${puzzle.dateKey}'
                    : 'Find all ${puzzle.targetWords.length} words',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text('$remaining words remaining'),
            ],
          ),
        ),

        const Divider(height: 1),

        // Letter grid

        // Letter grid
        Expanded(
          flex: 4,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    // अब यह पूरी तरह से सेंटर में काम करेगा
                    child: LetterGrid(
                      puzzle: puzzle,
                      foundWordIds: _found,
                      selectedStart: _selectedStart,
                      onCellTap: _tapCell,
                      onDragSelection: _handleDragSelection,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        // Word list below the grid
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: WordList(words: puzzle.targetWords, foundWordIds: _found),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Tap a starting letter, then the final letter in a straight line. '
            'Words can run in either direction.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
