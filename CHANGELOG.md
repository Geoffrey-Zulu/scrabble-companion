# Changelog

All notable changes to Scrabble Companion are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Flutter app scaffold (`scrabble_companion`, org `com.geoffreyzulu`) on
  Flutter 3.44 / Dart 3.12.
- Feature-first `lib/` layout with Riverpod bootstrap and go_router shell
  (Home / Timer / Dictionary / Settings).
- Design tokens and ThemeData for light + dark; system theme + text scale.
- Splash, bottom nav, toast host, bottom sheet helper, and core `Sc*` widgets.
- Settings screen with Drift-backed persistence.
- Offline dictionary: NWL2023 + CSW21 + ospd-defs, word checker UI with
  suggestions, favorites, and recent lookups.
- Turn timer with Stopwatch-based countdown, ring UI, durations, warn
  threshold, sound A/B/off, haptics, and pause-on-background.
- Launcher icons installed from `assets/icons/` into Android/iOS; store masters
  under `assets/store/`.
- Audio assets under `assets/audio/`; CI workflow (format, analyze, test).
- Engineering foundation: repository documentation, ADRs, task tracker, lint
  configuration, and design-system import from Claude Design handoff.
- Restored offline `ospd-defs.txt` definitions corpus (was empty placeholder).
- Researched and decided toolchain: Flutter **3.44.6** / Dart **3.12.2** stable.
- Architecture decisions: feature-first Clean Architecture, Riverpod 3,
  go_router, Drift, dual English dictionaries (NWL2023 + CSW21).

### Fixed

- Timer screen bottom overflow on short viewports (scroll + adaptive ring).
- Narrow-width overflows on Home search hint and Settings chip/text rows.
- Settings gameplay options: title above chips (not side-by-side); chip gaps restored.
- About rows use a simple title/value line (no empty third column).
- Developer card: removed GZ avatar badge.
- Theme light↔dark crossfade (420ms easeInOutCubic) instead of a hard cut.
- Warning audio: Android `resume()` after `stop()` was a no-op - now uses `play()`.
- Haptics: added `VIBRATE` permission + vibrate fallback for OEM impact no-ops.
- Expiry flash is a full-viewport accent blink (not a soft element tint).

### Changed

- Timer duration chips replaced with iOS-style preset wheel
  (30s / 1:00 / 1:30 / 2:00 / 3:00).
- Timer audio backend switched to `just_audio`; Settings A/B taps preview sound.
- Scrabble rules sheet from Home (info icon) and Settings → Scrabble rules;
  `rules.txt` removed after import.
- Timer warning hard-coded at 13s with `sound1.mp3` only (`sound2` removed).
- Timer duration wheel spacing/smoothness; player-name subtitle removed.

### Added

- UI widget test suite under `test/ui/` (home, timer, dictionary, settings, shell).
- Timer warn/expiry sound policy tests (one-shot entry, no loop for long thresholds).

### Notes

- Score keeper feature logic still pending (player chips on timer follow).
- `logo_android/` / `logo_ios/` are unused brand leftovers (not wired into UI).
- Warning clips are ~11–13s stings: play once when crossing `warnAt`, again on
  expiry - they do not loop for the full threshold.
- Timer expiry: double accent screen flash synced with a double haptic pulse
  (respects reduce-motion + haptics setting).


## [0.0.0] - 2026-07-21

### Added

- Initial repository with design prototype handoff, countdown sound assets
  (`sound1.mp3`, `sound2.mp3`), and empty definitions placeholder.
