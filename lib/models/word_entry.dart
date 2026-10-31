class WordEntry {
  WordEntry({
    required this.word,
    required this.definition,
    required this.exampleSentence,
    String? id,
    this.category = 'General',
  }) : id = (id ?? word).trim().toLowerCase();

  final String id, word, definition, exampleSentence, category;

  String get normalizedWord => word.trim().toLowerCase();

  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'definition': definition,
    'exampleSentence': exampleSentence,
    'category': category,
  };

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      id: json['id'] as String?,
      word: json['word'] as String,
      definition: json['definition'] as String,
      exampleSentence: json['exampleSentence'] as String,
      category: json['category'] as String? ?? 'General',
    );
  }
}
