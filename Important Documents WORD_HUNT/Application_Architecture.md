# Word Hunt --- Application and Code Architecture

**Status:** Draft v1.0\
**Architecture style:** Feature-oriented presentation layer + domain
logic + data/repository layer

## 1. Architecture overview

The app is offline-first. Flutter widgets render the UI, domain services
implement puzzle rules, and repositories handle local persistence and
word catalog access.

``` text
┌──────────────────────────────────────────────┐
│                 Presentation                 │
│ Welcome · Difficulty · Game · Results       │
│ Meanings · Settings · Reusable Widgets       │
└───────────────────────┬──────────────────────┘
                        │ user actions / state
┌───────────────────────▼──────────────────────┐
│                 Application                  │
│ GameController · SettingsController          │
│ Orchestrates screen state and use cases      │
└───────────────┬─────────────────┬────────────┘
                │                 │
┌───────────────▼────────┐  ┌─────▼────────────┐
│         Domain         │  │   Repositories   │
│ PuzzleGenerator        │  │ ProgressRepository│
│ SelectionValidator     │  │ WordRepository    │
│ WordSelectionPolicy    │  └─────┬────────────┘
│ DifficultyConfig       │        │
│ Domain models          │  ┌─────▼────────────┐
└────────────────────────┘  │       Data       │
                            │ SharedPreferences│
                            │ Local word catalog│
                            └──────────────────┘
```

## 2. Proposed folder structure

``` text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme/
│       ├── app_theme.dart
│       └── theme_controller.dart
├── core/
│   ├── constants/
│   │   └── difficulty_configs.dart
│   ├── errors/
│   │   └── puzzle_generation_exception.dart
│   └── utils/
│       └── word_normalizer.dart
├── features/
│   ├── home/
│   │   └── presentation/
│   │       └── welcome_screen.dart
│   ├── difficulty/
│   │   └── presentation/
│   │       └── difficulty_screen.dart
│   ├── game/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── puzzle.dart
│   │   │   │   ├── word_entry.dart
│   │   │   │   └── difficulty_config.dart
│   │   │   ├── puzzle_generator.dart
│   │   │   ├── selection_validator.dart
│   │   │   └── word_selection_policy.dart
│   │   ├── data/
│   │   │   └── word_repository.dart
│   │   └── presentation/
│   │       ├── game_screen.dart
│   │       ├── game_controller.dart
│   │       └── widgets/
│   │           ├── letter_grid.dart
│   │           ├── letter_cell.dart
│   │           └── target_word_list.dart
│   ├── completion/
│   │   └── presentation/
│   │       └── congratulations_screen.dart
│   ├── meanings/
│   │   └── presentation/
│   │       └── word_meanings_screen.dart
│   ├── daily_challenge/
│   │   └── daily_challenge_service.dart
│   └── settings/
│       └── presentation/
│           ├── settings_screen.dart
│           └── settings_controller.dart
├── data/
│   ├── local/
│   │   ├── local_word_catalog.dart
│   │   └── preferences_progress_repository.dart
│   └── repositories/
│       └── progress_repository.dart
└── shared/
    └── widgets/
        ├── app_button.dart
        └── empty_state.dart
```

This is a target structure, not a requirement to create every file
immediately. Create files as each feature is implemented.

## 3. Responsibilities and dependency rules

### Presentation

-   Displays screens and reusable widgets.
-   Converts taps/drags into controller calls.
-   Reads state and renders progress, selections, and errors.
-   Contains no puzzle-generation algorithm or persistence key logic.

### Application/controllers

-   Coordinates a game session.
-   Requests puzzle generation, validates selections, updates state, and
    invokes repository methods.
-   Controls the transition from active puzzle to congratulations and
    meanings.
-   Guards against double-counting a completed puzzle.

### Domain

-   Pure Dart models and rules.
-   Defines difficulty settings, word normalization, word eligibility,
    grid generation, placement, and selection validation.
-   Must not import Flutter widgets or `shared_preferences`.

### Data/repositories

-   Loads the word catalog.
-   Reads/writes progress and settings.
-   Implements storage details behind interfaces.
-   Handles serialization and basic data migration.

## 4. Core data flow

### Start a puzzle

1.  UI sends selected mode and difficulty to `GameController`.
2.  Controller loads word catalog and `PlayerProgress`.
3.  `WordSelectionPolicy` excludes previously found words if
    `completedGames < 1000`.
4.  `PuzzleGenerator` selects the required number of words and creates a
    valid grid.
5.  Controller publishes the new puzzle state to the UI.

### Find a word

1.  Grid widget reports selected cell coordinates.
2.  `SelectionValidator` checks the straight-line path and
    forward/reverse word.
3.  Controller marks the word found and updates highlighted cells.
4.  Progress repository persists the word ID in the player's shared
    history.
5.  When all puzzle targets are found, the controller commits completion
    exactly once and increments `completedGames`.

### Complete a puzzle

1.  Show a congratulations acknowledgement.
2.  Navigate to one scrollable meanings screen.
3.  Display the completed puzzle's word entries in target-list order.
4.  Offer Home and Play Again.

## 5. Important invariants

-   Difficulty configurations are fixed at 4×4/4 words, 8×8/8 words,
    16×16/16 words, and 32×32/32 words.
-   Word history is shared across difficulties and game modes.
-   Before the 1,000-completed-game threshold, previously found words
    cannot be selected for a new puzzle.
-   A found word is persisted even if the player leaves an incomplete
    puzzle.
-   Each puzzle instance can increment completed-game count at most
    once.
-   The meanings screen uses the actual `WordEntry` records used by that
    puzzle, not a separate lookup that might fail offline.
-   A generation failure never silently breaks the no-repeat policy.
-   Daily puzzle seed is deterministic for a given
    date/difficulty/catalog version, but the available words are
    filtered by each player's history.

## 6. State management recommendation

For the first implementation, use a `ChangeNotifier` controller or a
simple `ValueNotifier` where state is small. If the app grows, consider
Riverpod or Bloc, but avoid mixing state-management styles. Keep the
domain layer independent so the choice can change later.

Suggested game state: - `status`: loading, playing, completed,
generationError. - `puzzle`: current puzzle or null. - `foundWordIds`:
found in this puzzle. - `selectedCells`: current drag selection. -
`remainingWordCount`. - `errorMessage`: nullable.

## 7. Local storage and migration

-   Use `ProgressRepository` as the interface; implement it with
    `SharedPreferencesProgressRepository`.
-   Include a schema version in serialized state.
-   Store stable word IDs rather than display words when possible.
-   Treat local data as device-specific; no cloud sync in v1.
-   If progress grows large, replace SharedPreferences with SQLite/Drift
    behind the same interface.
