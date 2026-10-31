# Word Hunt --- Product Requirements Document (PRD)

**Status:** Draft v1.0\
**Platform:** Flutter (Android-first; architecture should remain
portable to other Flutter targets)

## 1. Product overview

Word Hunt is a vocabulary-learning word-search game. Players find target
words in a letter grid, receive a simple congratulations message when
the puzzle is complete, and then review every word's meaning and an
example sentence on one scrollable screen.

The game intentionally has no points, coins, stars, leaderboards, or
reward economy.

## 2. Product goals

-   Make word-search gameplay simple and accessible.
-   Help players learn vocabulary through definitions and example
    sentences.
-   Offer four freely selectable difficulty levels.
-   Offer a daily challenge.
-   Avoid showing a player words they have already found until the
    player's 1,000-completed-game threshold has been reached.
-   Preserve local progress across app restarts.

## 3. Target user experience

### Main flow

1.  Welcome screen.
2.  Player selects Regular Game or Daily Challenge.
3.  Player chooses Easy, Medium, Hard, or Expert.
4.  Game screen displays the target-word list, grid, and remaining-word
    count.
5.  Player selects a word by tapping/dragging through contiguous
    letters.
6.  Correct words are highlighted and marked found.
7.  When all target words are found, show a congratulations message.
8.  Continue to a single scrollable Word Meanings screen containing all
    target words, definitions, and example sentences.
9.  Player can return Home or start another puzzle.

### Difficulty configuration

  -------------------------------------------------------------------------
  Difficulty                      Grid         Target words Intended
                                                            challenge
  --------------- -------------------- -------------------- ---------------
  Easy                           4 × 4                    4 Familiar short
                                                            words;
                                                            horizontal and
                                                            vertical
                                                            placement

  Medium                         8 × 8                    8 Familiar and
                                                            moderately
                                                            challenging
                                                            words; include
                                                            diagonals

  Hard                         16 × 16                   16 Longer
                                                            vocabulary;
                                                            forwards,
                                                            backwards,
                                                            vertical and
                                                            diagonal
                                                            placement

  Expert                       32 × 32                   32 Advanced
                                                            vocabulary; all
                                                            eight
                                                            directions
  -------------------------------------------------------------------------

Grid dimensions and word count double from one level to the next. The
cell count therefore quadruples at each level. The UI must handle large
grids with scrolling and appropriately sized cells.

### Word non-repetition policy

-   Maintain one shared found-word history per local player profile
    across all difficulties and game modes.
-   Before the player's 1,000th completed game, do not include any word
    already found by that player.
-   Count a game only when all target words have been found and the
    completion flow is committed.
-   Abandoned/incomplete puzzles do not increment the completed-game
    count. Words successfully found during an incomplete puzzle should
    be persisted as found and excluded from future puzzles before the
    threshold.
-   After 1,000 completed games, previously found words become eligible
    for reuse. Reuse is allowed, not required.
-   Normalize word keys (trim whitespace and compare case-insensitively)
    to avoid duplicates caused by capitalization.
-   If there are not enough eligible words to fill a puzzle, do not
    silently repeat words early. Show a clear "not enough new words"
    message and provide a safe retry/return option.

**Clarification for implementation:** Treat the threshold as
`completedGames >= 1000` when deciding whether reuse is permitted for
the next puzzle. A puzzle that becomes the 1,000th completed game still
uses the no-repeat rules that applied when it was generated.

## 4. Daily challenge

-   Offer a Daily Challenge entry point from the welcome screen.
-   Provide one deterministic daily puzzle per calendar date and
    selected difficulty.
-   Use a stable date key based on the device's local date for v1.
-   A player may choose difficulty; the daily challenge uses the
    selected difficulty's grid and word count.
-   Previously found words remain excluded according to the shared
    word-history policy.
-   Prevent accidental rerolls of the same daily puzzle within the same
    date/difficulty unless the user intentionally restarts it. The same
    puzzle seed should be reproducible.
-   If the daily pool cannot satisfy the no-repeat policy, explain why
    rather than violate the policy.

## 5. Accessibility and settings

-   Follow system light/dark mode and provide an in-app override:
    System, Light, Dark.
-   Adjustable text scale.
-   Sufficient contrast; found, selected, and unfound states must not
    rely on color alone.
-   Large enough touch targets and clear selection feedback.
-   Screen-reader labels for letters, word list, actions, and progress.
-   Respect reduced motion where practical.
-   Optional sound effects, off by default or controlled in settings.
-   Keyboard navigation can be added for desktop/web builds; touch
    interaction is primary for mobile.

## 6. Functional requirements

-   FR-01: Show welcome screen with Regular Game, Daily Challenge, and
    Settings entry points.
-   FR-02: Allow switching among all four difficulties at any time.
-   FR-03: Generate a valid grid with exactly the configured number of
    target words.
-   FR-04: Display all target words and remaining-word progress.
-   FR-05: Recognize a selection only when its letter path exactly
    matches a target word or its reverse.
-   FR-06: Support the directions configured for each difficulty.
-   FR-07: Highlight found words and prevent counting the same target
    twice in a puzzle.
-   FR-08: Show congratulations only after all target words have been
    found.
-   FR-09: Show all puzzle word definitions and examples on one
    scrollable screen.
-   FR-10: Persist found-word history, completed-game count, settings,
    and daily-challenge state locally.
-   FR-11: Enforce the shared 1,000-completed-game repetition rule.
-   FR-12: Show a useful error/empty state if a valid puzzle cannot be
    generated from eligible words.
-   FR-13: Support accessible text sizing and theme settings.

## 7. Non-functional requirements

-   Offline-first; no account or server required for v1.
-   Puzzle generation must terminate within a bounded number of attempts
    and fail gracefully.
-   Keep UI responsive; avoid expensive synchronous work on the UI
    thread for large grids if profiling shows a need.
-   Persist progress safely and tolerate missing/corrupt preference
    values by using validated defaults.
-   Keep UI, puzzle logic, word data, and persistence separated for
    testability.
-   Do not claim cross-device sync; local storage is device-local.

## 8. Out of scope for v1

-   User accounts, cloud synchronization, online multiplayer.
-   Ads, purchases, subscriptions, coins, points, stars, or
    leaderboards.
-   AI-generated definitions at runtime.
-   Social sharing.
-   Timed competitions.

## 9. Success criteria

-   All four difficulty configurations generate valid puzzles or a clear
    recoverable error.
-   Correct selections are recognized in supported directions; incorrect
    selections do not alter progress.
-   Found words are excluded across difficulties and game modes until
    the reuse threshold.
-   Completed-game count increments exactly once per completed puzzle.
-   Meanings screen includes every target word exactly once with a
    definition and example.
-   Progress and settings survive app restarts.
-   Light/dark themes and text scaling work without clipping core
    controls.
