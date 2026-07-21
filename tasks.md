# Tasks — Scrabble Companion

Living engineering checklist. Update status as work lands.
Statuses: `[ ]` todo · `[~]` in progress · `[x]` done · `[-]` cancelled

Last updated: **2026-07-21**

---

## Milestone 0 — Project foundation

- [x] Research latest Flutter/Dart stable (3.44.6 / 3.12.2)
- [x] Inspect Claude Design handoff (MCP unavailable → local prototype)
- [x] Extract design tokens, screens, motion into `.design/` + UI guidelines
- [x] Investigate dictionary sources (scrabblewords + alternatives)
- [x] Restore `ospd-defs.txt` (was empty); document formats
- [x] Decide architecture, state, routing, persistence (ADRs)
- [x] Create README, docs/, ADRs, CHANGELOG, LICENSE, .gitignore, analysis_options
- [x] Skip Melos (single-package app) — document rationale
- [x] Initialize `develop` branch and document PR workflow
- [x] Scaffold Flutter project (`flutter create`) with org/bundle IDs
- [x] Move sounds into `assets/audio/` and register in pubspec
- [x] Add CI workflow skeleton (analyze + test + format)

---

## Milestone 1 — Architecture & app shell

- [x] Create feature-first folder structure under `lib/`
- [x] Wire `ProviderScope` + app bootstrap
- [x] Implement design tokens (`AppColors`, `AppSpacing`, `AppRadii`, `AppMotion`, `AppTypography`)
- [x] Implement ThemeData light + dark + system resolution
- [x] Implement text scale setting (Small / Default / Large)
- [x] go_router with `StatefulShellRoute` for Home / Timer / Dictionary / Settings
- [x] Splash screen matching prototype (`tileIn` + fade brand)
- [x] Shared chrome: bottom nav, toast, bottom sheet scaffold
- [x] Accessibility baseline: semantics, min touch targets 44×44, contrast check

---

## Milestone 2 — Design system & reusable widgets

- [x] `ScCard` (home feature cards)
- [x] `ScPrimaryButton` / `ScSecondaryButton` / `ScIconButton`
- [x] `ScSearchField` (pill field, uppercase filter)
- [ ] `ScSegmentedControl` (theme, durations, warn opts)
- [ ] `ScToggle` (settings switches)
- [ ] `ScAvatarInitial` (recent games / player rows)
- [x] `ScBottomNav`
- [x] `ScToast`
- [x] `ScBottomSheet` (score keypad, new game)
- [ ] Icon set (stroke icons matching prototype SVG paths)
- [x] Install launcher icons from `assets/icons/` into Android/iOS
- [ ] Golden tests for key atoms in light + dark

---

## Milestone 3 — Persistence (Drift)

- [x] Add Drift + sqlite3_flutter_libs + path_provider
- [x] Schema: settings, games, players, turns, favorites, recent_lookups, stats aggregates
- [ ] Migrations strategy (versioned) — v1 schema only so far
- [x] Repository interfaces + Drift implementations (settings, lookups, favorites)
- [x] Seed defaults on first launch
- [ ] Repository unit tests with in-memory Drift

---

## Milestone 4 — Dictionary (critical path)

- [x] Vendor NWL2023.txt + CSW21.txt (English only) with NOTICE
- [x] Build-time (or first-launch) parser for `WORD def [pos …]` lines
- [x] Strip comments / license headers (CSW)
- [x] In-memory `HashSet` for O(1) validity
- [x] Definition lookup map (or Drift FTS) keyed by word
- [x] Parse / normalize `{lemma=pos}` and `<lemma=pos>` cross-refs into readable copy
- [x] Supplemental merge from `ospd-defs.txt` where primary def is empty/cross-ref only
- [x] Prefix suggestions (max 5) sorted by length then alpha
- [x] Favorites + recent searches (persist)
- [x] Scrabble letter-point calculator (standard English values)
- [x] Dictionary locale setting: North American (NWL) / British (CSW)
- [x] Lazy load inactive lexicon to save memory
- [ ] Performance: cold lookup < 16ms after warm; suggestions debounce
- [x] Unit tests: parser, validity, points, suggestions
- [ ] Widget tests: checker empty / suggest / valid / invalid states

---

## Milestone 5 — Timer

- [x] Precise ticker (prefer `Stopwatch` + animation/TVs over naïve 1s `Timer` drift)
- [x] Durations: 30 / 60 / 120 / 180 seconds
- [x] Pause / resume / reset
- [x] Circular progress ring with warn color transition
- [x] Warning threshold setting (5 / 10 / 20 / 30s)
- [x] Sound: Off / Sound A (`sound1.mp3`) / Sound B (`sound2.mp3`) + volume
- [x] Haptics on start, pause, warn ticks, expiry
- [ ] Player chips when active game exists; switch player resets remaining
- [x] Standalone mode copy when no game
- [x] Background / lifecycle: pause or freeze accurately; document behavior
- [ ] Landscape-friendly layout (optional stretch goal for v1.1)
- [x] Widget + unit tests for timer state machine

---

## Milestone 6 — Score Keeper

- [ ] New Game sheet: 2–6 players (match prototype max)
- [ ] Default names `Player N` when blank
- [ ] Score overlay with leader highlight
- [ ] Add-score bottom sheet + numeric keypad (max 3 digits)
- [ ] Optional word field (uppercase A–Z)
- [ ] Round derivation from turn index
- [ ] Undo last turn
- [ ] End Game → winner + stats (highest turn, avg, rounds, duration)
- [ ] Confetti / letter-tile fall animation (respect reduce motion)
- [ ] Persist finished games to recent list (cap 12)
- [ ] Swipe-to-delete recent games
- [ ] Resume in-progress game after restart
- [ ] Edit previous round scores (discovered need — implement after undo)
- [ ] Aggregate statistics store (wins, longest game, highest word)
- [ ] Integration tests for full game lifecycle

---

## Milestone 7 — Home & navigation polish

- [ ] Greeting by time of day
- [ ] Timer / Dictionary / Score Keeper cards
- [ ] Start New Game CTA
- [ ] Recent games list + empty state
- [ ] Deep link / route restoration for overlays
- [ ] Motion: `fadeIn`, card press scale, sheet spring

---

## Milestone 8 — Settings

- [ ] Gameplay: warn-at, timer sound (Off/A/B), volume, haptics
- [ ] Dictionary: NWL vs CSW
- [ ] Appearance: theme, text size
- [ ] About: version, privacy, feedback
- [ ] Developer card (Geoffrey Zulu contact links from design)
- [ ] Reset all settings
- [ ] Persist all settings via repository

---

## Milestone 9 — Animations, haptics, sound

- [ ] Screen transitions (subtle fade / shared axis)
- [ ] Button press feedback
- [ ] Swipe-delete animation
- [ ] Timer ring + danger pulse
- [ ] Win confetti (disable when `disableAnimations` / reduced motion)
- [ ] Central `HapticsService` gated by setting
- [ ] Central `SoundService` with A/B assets + volume

---

## Milestone 10 — Accessibility

- [ ] Screen reader labels for nav, timer controls, keypad
- [ ] Large text / text scale verification on all screens
- [ ] Contrast audit light + dark (WCAG AA)
- [ ] Touch targets ≥ 44pt
- [ ] Respect `MediaQuery.disableAnimations` / platform reduce motion
- [ ] TalkBack / VoiceOver pass checklist in docs

---

## Milestone 11 — Testing & quality

- [ ] Unit tests ≥ critical domain (timer, scoring, dictionary)
- [ ] Widget tests for primary screens
- [ ] Golden tests for design system atoms
- [ ] Integration test: start game → score → end → history
- [ ] Coverage report in CI (informative threshold)
- [ ] `flutter analyze` clean; format enforced

---

## Milestone 12 — Performance

- [ ] Profile cold start; keep dictionary load off UI jank path
- [ ] Avoid unnecessary rebuilds (Riverpod selects)
- [ ] Memory check with both lexicons strategy
- [ ] Asset size budget for store listing
- [ ] Impeller / jank checklist on mid-tier Android

---

## Milestone 13 — Release readiness

- [ ] App icons + splash (native)
- [ ] Store metadata drafts
- [ ] Privacy policy page / URL
- [ ] Crash-free path smoke on iOS + Android
- [ ] Remove prototype from release artifact (keep in repo for reference)
- [ ] Clean unused files / deps
- [ ] Tag `v1.0.0` + CHANGELOG

---

## Milestone 14 — Polish

- [ ] Microcopy pass
- [ ] Empty / error / edge states
- [ ] First-run swipe hint for recent games
- [ ] Final visual QA against prototype screenshots
- [ ] Open-source README badges / screenshots

---

## Discovered / parked

- [ ] Landscape timer layout (v1.1)
- [ ] Edit arbitrary historical turns (not just undo)
- [ ] Share word / game summary via system share sheet
- [ ] Export game as CSV / image
- [ ] Anagram / rack helper (future_ideas)
- [ ] iPad / tablet layouts
