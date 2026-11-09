import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class DictionaryEntry {
  final String word;
  final String definition;
  final String exampleSentence;
  final String partOfSpeech;

  const DictionaryEntry({
    required this.word,
    required this.definition,
    required this.exampleSentence,
    required this.partOfSpeech,
  });
}

class DictionaryApiService {
  final Map<String, DictionaryEntry> _cache = {};

  Future<DictionaryEntry?> lookupWord(String word) async {
    final normalizedWord = word.trim().toLowerCase();

    if (normalizedWord.isEmpty) return null;

    // Return cached result if available.
    if (_cache.containsKey(normalizedWord)) {
      return _cache[normalizedWord];
    }

    final uri = Uri.https(
      'api.dictionaryapi.dev',
      '/api/v2/entries/en/$normalizedWord',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw Exception('Dictionary API returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data is! List || data.isEmpty) {
        return null;
      }

      final entry = data.first as Map<String, dynamic>;
      final meanings = entry['meanings'] as List? ?? [];

      String? definition;
      String? example;
      String? partOfSpeech;

      for (final meaning in meanings) {
        if (meaning is! Map) continue;

        partOfSpeech ??= meaning['partOfSpeech']?.toString();

        final definitions = meaning['definitions'] as List? ?? [];

        for (final item in definitions) {
          if (item is! Map) continue;

          definition ??= item['definition']?.toString();

          final exampleText = item['example']?.toString();

          if (example == null &&
              exampleText != null &&
              exampleText.trim().isNotEmpty) {
            example = exampleText;
          }

          if (definition != null && example != null) {
            break;
          }
        }

        if (definition != null && example != null) {
          break;
        }
      }

      if (definition == null) return null;

      final result = DictionaryEntry(
        word: normalizedWord,
        definition: definition,
        exampleSentence: example ?? 'No example sentence available.',
        partOfSpeech: partOfSpeech ?? 'Unknown',
      );

      _cache[normalizedWord] = result;

      return result;
    } catch (e) {
      debugPrint('Dictionary lookup failed for $normalizedWord: $e');
      rethrow;
    }
  }
}
