class WordUsage {
  const WordUsage({
    required this.wordId,
    required this.firstUsedGameNumber,
    required this.lastUsedGameNumber,
    required this.totalUses,
    required this.lastUsedAt,
  });

  final String wordId;
  final int firstUsedGameNumber;
  final int lastUsedGameNumber;
  final int totalUses;
  final DateTime lastUsedAt;

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'firstUsedGameNumber': firstUsedGameNumber,
        'lastUsedGameNumber': lastUsedGameNumber,
        'totalUses': totalUses,
        'lastUsedAt': lastUsedAt.toIso8601String(),
      };

  factory WordUsage.fromJson(Map<String, dynamic> json) {
    return WordUsage(
      wordId: json['wordId'] as String,
      firstUsedGameNumber: json['firstUsedGameNumber'] as int,
      lastUsedGameNumber: json['lastUsedGameNumber'] as int,
      totalUses: json['totalUses'] as int,
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
    );
  }
}
