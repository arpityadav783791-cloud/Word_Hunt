WORD HUNT - UPDATED SOURCE

Copy the included lib/ folder into your existing Flutter project and replace
the existing lib/ folder.

Dependencies expected in pubspec.yaml:
  shared_preferences: (already used by the project)
  english_words: (add with: flutter pub add english_words)

The included test/ folder contains a progress-persistence regression test.
If your package name is not `word_hunt`, update the import in test/widget_test.dart.

Difficulty persistence:
- PlayerProgress.preferredDifficulty stores easy/medium/hard/expert.
- SharedPreferencesProgressRepository persists it with the rest of progress.
- First launch defaults to easy.
- Regular Start Game uses the saved difficulty directly.
- Settings saves a new regular-game difficulty immediately.
- Daily Challenge still opens its own difficulty chooser and does not modify
  the regular-game preference.

Vocabulary note:
english_words provides a word list, not definitions or example sentences.
The app keeps its curated offline entries with definitions. Additional words
imported from english_words currently display an offline-definition fallback.
A dictionary API or bundled definitions dataset is required to provide real
meanings/examples for every imported word.
