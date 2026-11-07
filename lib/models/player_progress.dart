import 'word_usage.dart';

class PlayerProgress {
  const PlayerProgress({
    this.completedGames = 0,
    this.foundWordIds = const <String>{},
    this.completedPuzzleIds = const <String>{},
    this.wordHistory = const <String, WordUsage>{},
    this.themeMode = 'system',
    this.textScale = 1.0,
    this.soundEnabled = false,
    this.preferredDifficulty = 'easy',
  });

  final int completedGames;
  final Set<String> foundWordIds;
  final Set<String> completedPuzzleIds;
  final Map<String, WordUsage> wordHistory;
  final String themeMode;
  final double textScale;
  final bool soundEnabled;
  final String preferredDifficulty;

  PlayerProgress copyWith({
    int? completedGames,
    Set<String>? foundWordIds,
    Set<String>? completedPuzzleIds,
    Map<String, WordUsage>? wordHistory,
    String? themeMode,
    double? textScale,
    bool? soundEnabled,
    String? preferredDifficulty,
  }) {
    return PlayerProgress(
      completedGames: completedGames ?? this.completedGames,
      foundWordIds: foundWordIds ?? this.foundWordIds,
      completedPuzzleIds: completedPuzzleIds ?? this.completedPuzzleIds,
      wordHistory: wordHistory ?? this.wordHistory,
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': 2,
        'completedGames': completedGames,
        'foundWordIds': foundWordIds.toList(),
        'completedPuzzleIds': completedPuzzleIds.toList(),
        'wordHistory': wordHistory.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'themeMode': themeMode,
        'textScale': textScale,
        'soundEnabled': soundEnabled,
        'preferredDifficulty': preferredDifficulty,
      };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    final completedGames =
        ((json['completedGames'] as num?)?.toInt() ?? 0)
            .clamp(0, 1 << 30)
            .toInt();

    final foundIds = Set<String>.from(
      (json['foundWordIds'] as List? ?? const []).whereType<String>(),
    );

    final history = <String, WordUsage>{};
    final rawHistory = json['wordHistory'];

    if (rawHistory is Map) {
      for (final entry in rawHistory.entries) {
        if (entry.value is! Map) continue;

        try {
          final usage = WordUsage.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
          history[usage.wordId] = usage;
        } catch (_) {
          // Ignore an invalid individual history entry.
        }
      }
    }

    // Migrate words from the previous progress format.
    for (final id in foundIds) {
      history.putIfAbsent(
        id,
        () => WordUsage(
          wordId: id,
          firstUsedGameNumber: completedGames,
          lastUsedGameNumber: completedGames,
          totalUses: 1,
          lastUsedAt: DateTime.now(),
        ),
      );
    }

    final scale = ((json['textScale'] as num?)?.toDouble() ?? 1.0)
        .clamp(0.85, 1.5)
        .toDouble();

    final theme = json['themeMode'] as String? ?? 'system';

    return PlayerProgress(
      completedGames: completedGames,
      foundWordIds: {...foundIds, ...history.keys},
      completedPuzzleIds: Set<String>.from(
        (json['completedPuzzleIds'] as List? ?? const [])
            .whereType<String>(),
      ),
      wordHistory: history,
      themeMode: const {'system', 'light', 'dark'}.contains(theme)
          ? theme
          : 'system',
      textScale: scale,
      soundEnabled: json['soundEnabled'] as bool? ?? false,
      preferredDifficulty:
          const {'easy', 'medium', 'hard', 'expert'}
                  .contains(json['preferredDifficulty'])
              ? json['preferredDifficulty'] as String
              : 'easy',
    );
  }
}
