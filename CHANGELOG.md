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
- Settings screen wired to in-memory preferences (persistence in Milestone 3).
- Audio assets under `assets/audio/`; CI workflow (format, analyze, test).
- Engineering foundation: repository documentation, ADRs, task tracker, lint
  configuration, and design-system import from Claude Design handoff.
- Restored offline `ospd-defs.txt` definitions corpus (was empty placeholder).
- Researched and decided toolchain: Flutter **3.44.6** / Dart **3.12.2** stable.
- Architecture decisions: feature-first Clean Architecture, Riverpod 3,
  go_router, Drift, dual English dictionaries (NWL2023 + CSW21).

### Notes

- Timer / dictionary / score keeper feature logic still pending; shell UI is live.

## [0.0.0] - 2026-07-21

### Added

- Initial repository with design prototype handoff, countdown sound assets
  (`sound1.mp3`, `sound2.mp3`), and empty definitions placeholder.
