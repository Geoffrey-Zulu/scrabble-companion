# Tasks - Scrabble Companion

Living engineering checklist. Update status as work lands.
Statuses: `[ ]` todo · `[~]` in progress · `[x]` done · `[-]` cancelled

Last updated: **2026-07-21**

---

## Milestone 0 - Project foundation

- [x] Research latest Flutter/Dart stable (3.44.6 / 3.12.2)
- [x] Inspect Claude Design handoff (MCP unavailable → local prototype)
- [x] Extract design tokens, screens, motion into `.design/` + UI guidelines
- [x] Investigate dictionary sources (scrabblewords + alternatives)
- [x] Restore `ospd-defs.txt` (was empty); document formats
- [x] Decide architecture, state, routing, persistence (ADRs)
- [x] Create README, docs/, ADRs, CHANGELOG, LICENSE, .gitignore, analysis_options
- [x] Skip Melos (single-package app) - document rationale
- [x] Initialize `dev` branch and document PR workflow
- [x] Scaffold Flutter project (`flutter create`) with org/bundle IDs
- [x] Move sounds into `assets/audio/` and register in pubspec
- [x] Add CI workflow skeleton (analyze + test + format)

---

## Milestone 1 - Architecture & app shell

- [x] Create feature-first folder structure under `lib/`
- [x] Wire `ProviderScope` + app bootstrap
- [x] Implement design tokens (`AppColors`, `AppSpacing`, `AppRadii`, `AppMotion`, `AppTypography`)
- [x] Implement ThemeData light + dark + system resolution
- [x] Implement text scale setting (Small / Medium / Large)
- [x] go_router with `StatefulShellRoute` for Home / Timer / Dictionary / Settings
- [x] Splash screen matching prototype (`tileIn` + fade brand)
- [x] Shared chrome: bottom nav, toast, bottom sheet scaffold
- [x] Accessibility baseline: semantics, min touch targets 44×44, contrast check

---

## Milestone 2 - Design system & reusable widgets

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

## Milestone 3 - Persistence (Drift)

- [x] Add Drift + sqlite3_flutter_libs + path_provider
- [x] Schema: settings, games, players, turns, favorites, recent_lookups, stats aggregates
- [ ] Migrations strategy (versioned) - v1 schema only so far
- [x] Repository interfaces + Drift implementations (settings, lookups, favorites)
- [x] Seed defaults on first launch
- [ ] Repository unit tests with in-memory Drift

---

## Milestone 4 - Dictionary (critical path)

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

## Milestone 5 - Timer

- [x] Precise ticker (prefer `Stopwatch` + animation/TVs over naïve 1s `Timer` drift)
- [x] Durations: iOS wheel with presets 30s / 1:00 / 1:30 / 2:00 / 3:00
- [x] Pause / resume / reset
- [x] Circular progress ring with warn color transition
- [x] Warning threshold setting (5 / 10 / 20 / 30s)
- [x] Sound via `just_audio`: Off / A / B + Settings preview tap
  - Policy: play once on enter-warn + once on expiry (no loop for full threshold)
- [x] Haptics on start, pause, warn ticks, expiry (+ `VIBRATE` permission)
- [x] Expiry: double/long haptic pulse (no screen flash)
- [x] Splash uses real `assets/branding/logo.png`
- [x] Warning hard-coded at 10s (`sound1.mp3` may overrun; stopped on reset)
- [-] Player chips / names on timer - cancelled; timer stays standalone
- [x] Scrabble rules sheet (Home info + Settings → Scrabble rules)
- [ ] Player chips when active game exists; switch player resets remaining
- [x] Standalone mode copy when no game
- [x] Background / lifecycle: pause or freeze accurately; document behavior
- [x] Timer layout: scroll + adaptive ring (no bottom overflow on short phones)
- [ ] Landscape-friendly layout (optional stretch goal for v1.1)
- [x] Widget + unit tests for timer state machine
- [x] UI widget suite: home / timer / dictionary / settings / shell navigation

---

## Milestone 6 - Score Keeper

- [x] New Game sheet: 2–6 players (match prototype max)
- [x] Default names `Player N` when blank
- [x] Score overlay with leader highlight
- [x] Add-score bottom sheet + numeric keypad (max 3 digits)
- [x] Signed scores (+ add / − subtract)
- [-] Pass / Bingo quick actions - removed (not needed)
- [x] Inline word check on add-score sheet
- [x] Persistent mini-timer on score + shell (pause / resume / reset)
- [x] Keep screen awake while timer is running
- [x] Optional word field (uppercase A–Z)
- [x] Round derivation from turn index
- [x] Undo last turn
- [x] End Game → winner + stats (highest turn, avg, rounds, duration)
- [-] Soft letter-tile confetti on winner - removed (tiles froze on screen)
- [x] Persist finished games to recent list (cap 12)
- [x] Swipe-to-delete recent games
- [x] Resume in-progress game after restart
- [x] Edit previous round scores (tap history row → edit sheet)
- [-] Aggregate / career statistics store - cancelled for v1 (keep simple)
- [x] Repository lifecycle tests (add / edit / undo / end → recent)

---

## Milestone 7 - Home & navigation polish

- [x] Greeting by time of day
- [x] Timer / Dictionary / Score Keeper cards
- [x] Start New Game CTA
- [x] Recent games list + empty state
- [ ] Deep link / route restoration for overlays
- [x] Motion: fade-up for score / winner overlays

---

## Milestone 8 - Settings

- [x] Gameplay: haptics (warn-at / A-B sound simplified to fixed 10s + sound1)
- [x] Dictionary: NWL vs CSW
- [x] Appearance: theme, text size
- [x] About: version, privacy, feedback (stubs), Scrabble rules
- [x] Developer card (WhatsApp contact)
- [x] Reset all settings
- [x] Persist all settings via repository

---

## Milestone 9 - Animations, haptics, sound

- [ ] Screen transitions (subtle fade / shared axis)
- [ ] Button press feedback
- [ ] Swipe-delete animation
- [ ] Timer ring + danger pulse
- [-] Win confetti - removed (tiles froze on screen)
- [x] Central `HapticsService` gated by setting
- [x] Central `SoundService` (`sound1.mp3`; A/B simplified away)

---

## Milestone 10 - Accessibility

- [ ] Screen reader labels for nav, timer controls, keypad
- [ ] Large text / text scale verification on all screens
- [ ] Contrast audit light + dark (WCAG AA)
- [ ] Touch targets ≥ 44pt
- [ ] Respect `MediaQuery.disableAnimations` / platform reduce motion
- [ ] TalkBack / VoiceOver pass checklist in docs

---

## Milestone 11 - Testing & quality

- [ ] Unit tests ≥ critical domain (timer, scoring, dictionary)
- [ ] Widget tests for primary screens
- [ ] Golden tests for design system atoms
- [ ] Integration test: start game → score → end → history
- [ ] Coverage report in CI (informative threshold)
- [ ] `flutter analyze` clean; format enforced

---

## Milestone 12 - Performance

- [ ] Profile cold start; keep dictionary load off UI jank path
- [ ] Avoid unnecessary rebuilds (Riverpod selects)
- [ ] Memory check with both lexicons strategy
- [ ] Asset size budget for store listing
- [ ] Impeller / jank checklist on mid-tier Android

---

## Milestone 13 - Release readiness

- [ ] App icons + splash (native)
- [ ] Store metadata drafts
- [ ] Privacy policy page / URL
- [ ] Crash-free path smoke on iOS + Android
- [ ] Remove prototype from release artifact (keep in repo for reference)
- [ ] Clean unused files / deps
- [ ] Tag `v1.0.0` + CHANGELOG

---

## Milestone 14 - Polish

- [ ] Microcopy pass
- [ ] Empty / error / edge states
- [ ] First-run swipe hint for recent games
- [ ] Final visual QA against prototype screenshots
- [ ] Open-source README badges / screenshots

---

## Discovered / parked

- [ ] Landscape timer layout (v1.1)
- [x] Edit arbitrary historical turns (not just undo)
- [ ] Share word / game summary via system share sheet
- [ ] Export game as CSV / image
- [ ] Anagram / rack helper (future_ideas)
- [ ] iPad / tablet layouts
