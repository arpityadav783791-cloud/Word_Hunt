# Word Hunt --- Technical Requirements Document (TRD)

**Status:** Draft v1.0\
**Stack:** Flutter + Dart; `shared_preferences` already added\
**Initial storage:** Local device only

## 1. Technical approach

Use a feature-oriented Flutter structure with a small domain layer. Keep
puzzle generation and selection validation as plain Dart logic so they
can be unit-tested without Flutter widgets. Use a repository/service
boundary for persistence.

For the first release, `shared_preferences` is acceptable for small
settings and serialized progress. It is not a relational database and
should not be treated as a transactional database. If word history or
saved sessions become large, migrate progress to SQLite/Drift or Isar
behind the same repository interface.

## 2. Dependencies

-   `flutter`: UI and application framework.
-   `shared_preferences`: local settings and lightweight progress
    persistence.
-   No network dependency for v1.
-   Avoid adding state-management or routing packages until there is a
    concrete need; use a simple app-level state solution initially, or
    add one deliberately later.

## 3. Domain models

### WordEntry

-   `id`: stable unique identifier.
-   `word`: display word.
-   `normalizedWord`: lowercase, trimmed key used for comparisons.
-   `definition`: plain-language definition.
-   `exampleSentence`: example usage.
-   `difficultyTags`: optional tags/categories.

### DifficultyConfig

-   `difficulty`: Easy, Medium, Hard, Expert.
-   `gridRows`, `gridColumns`.
-   `targetWordCount`.
-   `allowedDirections`.
-   `minimumWordLength`, `maximumWordLength` or an equivalent
    data-selection policy.

### Puzzle

-   `id`: unique puzzle instance identifier.
-   `mode`: regular or daily.
-   `difficulty`.
-   `dateKey`: nullable, present for daily puzzles.
-   `grid`: two-dimensional character array.
-   `targetWords`: ordered list of `WordEntry`.
-   `placements`: word-to-cell paths used for validation and
    highlighting.
-   `foundWordIds`: IDs found in the current puzzle.
-   `status`: inProgress or completed.

### PlayerProgress

-   `completedGames`: number of fully completed puzzles.
-   `foundWordIds`: persistent set of IDs ever found by the player.
-   `lastDailyCompletionByDateAndDifficulty`: completed daily challenge
    keys as needed.
-   `activePuzzle`: optional serialized snapshot if resume is supported.
-   `themeMode`, `textScale`, `soundEnabled`: settings.

## 4. Difficulty constants

  Level      Rows   Columns   Target words
  -------- ------ --------- --------------
  Easy          4         4              4
  Medium        8         8              8
  Hard         16        16             16
  Expert       32        32             32

Both dimensions and target word count double each level. Total cells:
16, 64, 256, 1,024.

## 5. Puzzle generation algorithm

1.  Load the word catalog.
2.  Load player progress.
3.  Determine whether reuse is permitted (`completedGames >= 1000`).
4.  Filter eligible words: before reuse is permitted, remove every word
    whose normalized ID/key is in the player's found history.
5.  Select exactly the target word count. If insufficient eligible words
    exist, return a typed generation failure rather than silently
    reusing words.
6.  Initialize an empty grid.
7.  Place each selected word in a permitted direction, checking bounds
    and letter conflicts. Allow intersections only when the letters
    match.
8.  Use a bounded number of attempts per word and a bounded number of
    full-grid retries.
9.  Fill remaining empty cells with random letters.
10. Return the grid, target words, and placement paths. If placement
    fails after retries, try a different selected word set or return a
    recoverable failure.

Use a seeded random generator for deterministic Daily Challenge
generation. Daily seed should be derived from date + difficulty + a
stable catalog/version value. Player-specific exclusions must still be
applied, so a daily puzzle may differ by player.

## 6. Letter selection and validation

-   Track a start cell and current end cell while the user drags.
-   A valid straight-line selection must have a constant
    row/column/diagonal direction.
-   Convert the selected path into a string.
-   Compare against normalized target words in forward and reverse
    order.
-   Accept only a target word not already found in the current puzzle.
-   On success, record the word, its cell path, and persistent found
    history.
-   On failure, show subtle feedback and clear the selection without
    changing found-word progress.
-   Support tap/drag input with an accessible alternative where
    feasible.

## 7. Persistence requirements

Use a `ProgressRepository` interface so the storage mechanism can change
without affecting UI or domain logic.

Suggested `shared_preferences` keys: - `word_hunt.completed_games` -
`word_hunt.found_word_ids` - `word_hunt.settings` -
`word_hunt.daily_state` - `word_hunt.active_puzzle` (only if resume is
implemented)

Persistence rules: - Normalize and deduplicate found word IDs before
writing. - Save found history after a word is successfully found. -
Increment completed games exactly once when the final target word is
found and completion is committed. - Avoid incrementing the counter
again if the completion screen is reopened. - Validate stored values and
recover with safe defaults if data is missing or malformed. - A
device-local profile is the v1 identity. Clearing app data or
uninstalling may erase local history; disclose this limitation if
needed. - Use a serialized version field so future data migrations are
possible.

## 8. Screen and navigation requirements

-   `WelcomeScreen`: Regular Game, Daily Challenge, Settings.
-   `DifficultyScreen`: all four difficulty options, always selectable.
-   `GameScreen`: grid, target word list, found/remaining status,
    settings/pause access.
-   `CongratulationsScreen`: completion acknowledgement only; no points
    or reward UI.
-   `WordMeaningsScreen`: all target words with definitions and example
    sentences in one scrollable view; Home and Play Again actions.
-   `SettingsScreen`: theme mode, text scale, optional sound.

Use named routes or a router abstraction when navigation grows. Pass
typed arguments rather than loose maps.

## 9. Error handling

-   Not enough unused words: explain that the available unused
    vocabulary is exhausted for the selected level; do not repeat words
    before the threshold.
-   Impossible word placement: retry within limits, then show a retry
    option.
-   Invalid stored data: reset only the invalid value and continue
    safely.
-   Empty or duplicate word catalog entries: reject them during
    validation.
-   Daily challenge already completed: allow review or replay according
    to product decision, without incrementing completion count twice for
    the same puzzle instance.

## 10. Testing strategy

### Unit tests

-   Difficulty configuration values.
-   Word normalization and duplicate detection.
-   Word selection excludes found words before threshold.
-   Reuse becomes eligible at/after the threshold.
-   Completed-game count increments exactly once.
-   Grid placement respects bounds and letter intersections.
-   Selection validation in all supported directions and reversed order.
-   Generation fails gracefully when eligible vocabulary is
    insufficient.
-   Daily seed is stable for the same date/difficulty/catalog version.

### Widget tests

-   Welcome screen navigation.
-   Difficulty options are all visible/selectable.
-   Progress count updates after a found word.
-   Congratulations appears only when all words are found.
-   Meanings screen shows all words and definitions.
-   Theme and text scale settings are reflected.

### Manual checks

-   Test 4×4 on a small phone.
-   Test 32×32 with scrolling and readable touch targets.
-   Rotate/relaunch if supported; confirm persistence.
-   Check dark mode, large text, and screen-reader semantics.

## 11. Performance and reliability

-   Keep grid generation bounded.
-   Avoid rebuilding the entire 32×32 grid on every pointer movement;
    use localized selection state and efficient builders.
-   Use `GridView.builder` or a custom grid renderer for large grids.
-   Profile Expert mode on a real device before optimizing prematurely.
-   Persist only necessary state; don't write on every drag update.
