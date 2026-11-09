import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../services/dictionary_api_service.dart';

class DictionaryCache {
  static Database? _database;
  static final Map<String, Future<DictionaryEntry?>> _pending = {};

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();

    _database = await openDatabase(
      join(dbPath, 'word_hunt_dictionary.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE dictionary_entries (
            word TEXT PRIMARY KEY,
            definition TEXT NOT NULL,
            exampleSentence TEXT NOT NULL,
            partOfSpeech TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<DictionaryEntry?> getEntry(String word) async {
    final db = await database;

    final rows = await db.query(
      'dictionary_entries',
      where: 'word = ?',
      whereArgs: [word.trim().toLowerCase()],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;

    return DictionaryEntry(
      word: row['word'] as String,
      definition: row['definition'] as String,
      exampleSentence: row['exampleSentence'] as String,
      partOfSpeech: row['partOfSpeech'] as String,
    );
  }

  Future<void> saveEntry(DictionaryEntry entry) async {
    final db = await database;

    await db.insert(
      'dictionary_entries',
      {
        'word': entry.word.toLowerCase(),
        'definition': entry.definition,
        'exampleSentence': entry.exampleSentence,
        'partOfSpeech': entry.partOfSpeech,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DictionaryEntry?> getOrFetch(
    String word,
    DictionaryApiService api,
  ) async {
    final key = word.trim().toLowerCase();

    if (key.isEmpty) return null;

    final cached = await getEntry(key);
    if (cached != null) return cached;

    // Reuse an API request already running for this word.
    if (_pending.containsKey(key)) {
      return _pending[key];
    }

    final request = _fetchAndSave(key, api);
    _pending[key] = request;

    try {
      return await request;
    } finally {
      _pending.remove(key);
    }
  }

  Future<DictionaryEntry?> _fetchAndSave(
    String word,
    DictionaryApiService api,
  ) async {
    final entry = await api.lookupWord(word);

    if (entry != null) {
      await saveEntry(entry);
    }

    return entry;
  }
}
