class PlayerProgress {
  const PlayerProgress({
    this.completedGames = 0,
    this.foundWordIds = const <String>{},
    this.completedPuzzleIds = const <String>{},
    this.themeMode = 'system',
    this.textScale = 1.0,
    this.soundEnabled = false,
    this.preferredDifficulty = 'easy',
  });

  final int completedGames;
  final Set<String> foundWordIds, completedPuzzleIds;
  final String themeMode;
  final double textScale;
  final bool soundEnabled;
  final String preferredDifficulty;

  PlayerProgress copyWith({
    int? completedGames,
    Set<String>? foundWordIds,
    Set<String>? completedPuzzleIds,
    String? themeMode,
    double? textScale,
    bool? soundEnabled,
    String? preferredDifficulty,
  }) => PlayerProgress(
    completedGames: completedGames ?? this.completedGames,
    foundWordIds: foundWordIds ?? this.foundWordIds,
    completedPuzzleIds: completedPuzzleIds ?? this.completedPuzzleIds,
    themeMode: themeMode ?? this.themeMode,
    textScale: textScale ?? this.textScale,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'completedGames': completedGames,
    'foundWordIds': foundWordIds.toList(),
    'completedPuzzleIds': completedPuzzleIds.toList(),
    'themeMode': themeMode,
    'textScale': textScale,
    'soundEnabled': soundEnabled,
    'preferredDifficulty': preferredDifficulty,
  };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    final scale = ((json['textScale'] as num?)?.toDouble() ?? 1.0)
        .clamp(0.85, 1.5)
        .toDouble();
    final theme = json['themeMode'] as String? ?? 'system';
    return PlayerProgress(
      completedGames: ((json['completedGames'] as num?)?.toInt() ?? 0)
          .clamp(0, 1 << 30)
          .toInt(),
      foundWordIds: Set<String>.from(
        (json['foundWordIds'] as List? ?? const []).whereType<String>(),
      ),
      completedPuzzleIds: Set<String>.from(
        (json['completedPuzzleIds'] as List? ?? const []).whereType<String>(),
      ),
      themeMode: const {'system', 'light', 'dark'}.contains(theme)
          ? theme
          : 'system',
      textScale: scale,
      soundEnabled: json['soundEnabled'] as bool? ?? false,
      preferredDifficulty:
          const {
            'easy',
            'medium',
            'hard',
            'expert',
          }.contains(json['preferredDifficulty'])
          ? json['preferredDifficulty'] as String
          : 'easy',
    );
  }
}
