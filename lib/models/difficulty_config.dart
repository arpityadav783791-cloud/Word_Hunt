enum DifficultyLevel { easy, medium, hard, expert }

class DifficultyConfig {
  const DifficultyConfig({
    required this.level,
    required this.label,
    required this.gridSize,
    required this.wordCount,
    required this.minWordLength,
    required this.maxWordLength,
    required this.description,
  });
  final DifficultyLevel level;
  final String label;
  final int gridSize, wordCount, minWordLength, maxWordLength;
  final String description;

  static const easy = DifficultyConfig(
    level: DifficultyLevel.easy,
    label: 'Easy',
    gridSize: 4,
    wordCount: 4,
    minWordLength: 3,
    maxWordLength: 4,
    description: 'Short, familiar words in a small grid.',
  );
  static const medium = DifficultyConfig(
    level: DifficultyLevel.medium,
    label: 'Medium',
    gridSize: 8,
    wordCount: 8,
    minWordLength: 4,
    maxWordLength: 7,
    description: 'A larger grid with diagonal words.',
  );
  static const hard = DifficultyConfig(
    level: DifficultyLevel.hard,
    label: 'Hard',
    gridSize: 10,
    wordCount: 10,
    minWordLength: 5,
    maxWordLength: 10,
    description: 'Longer words and more directions.',
  );

  static const expert = DifficultyConfig(
    level: DifficultyLevel.expert,
    label: 'Expert',
    gridSize: 12,
    wordCount: 12,
    minWordLength: 6,
    maxWordLength: 14,
    description: 'A larger grid with advanced vocabulary.',
  );
  static const all = [easy, medium, hard, expert];
  static DifficultyConfig forLevel(DifficultyLevel level) =>
      all.firstWhere((config) => config.level == level);
}
