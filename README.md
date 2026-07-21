# Scrabble Companion

A premium, offline-first Flutter companion for Scrabble nights: turn timer,
tournament word checker with definitions, multi-player score keeper, and
polished settings - designed to feel like a shipping App Store product.

> **Status:** Milestone 1 complete - runnable app shell with design system.
> Next: Drift persistence + dictionary (see [`tasks.md`](tasks.md)).

---

## Product

| Feature | Description |
| --- | --- |
| **Timer** | Precise countdown with pause/resume/reset, warning threshold, sound + haptics, optional player chips when a game is active |
| **Word Checker** | Instant offline lookup against NWL (North American) or CSW (British), with definitions, recent history, and favorites |
| **Score Keeper** | 2–6 players, rounds, undo, optional word per turn, win screen with stats, persisted recent games |
| **Settings** | Theme (light / dark / system), text size, warning seconds, sound A/B/off, haptics, dictionary locale |

Everything works with **no network**.

---

## Toolchain (verified)

Do not guess versions. Pin to current stable:

| Tool | Version | Verified |
| --- | --- | --- |
| Flutter | **3.44.6** (stable) | `flutter --version` on 2026-07-21 |
| Dart | **3.12.2** | Bundled with Flutter 3.44.6 |
| Target | iOS / Android (phone-first) | Design is 393×852 |

Recommended local workflow:

```bash
flutter channel stable
flutter upgrade
flutter doctor -v
```

---

## Architecture at a glance

**Feature-first Clean Architecture** with Riverpod for DI/state, go_router for
typed navigation, and Drift (SQLite) for relational persistence.

```
lib/
  app/                 # bootstrap, router, theme
  core/                # shared widgets, tokens, utils, errors
  features/
    home/
    timer/
    dictionary/
    score/
    settings/
  data/                # Drift DB, dictionary assets, repositories
```

Full detail: [`docs/architecture.md`](docs/architecture.md) ·
[`docs/technical_design.md`](docs/technical_design.md)

**Why not Melos?** This is a single application package, not a monorepo.
Melos adds ceremony without benefit until we extract packages.

---

## Design source

Claude Design MCP was **not available** in this environment. The source of
truth is the local handoff:

```
scrabble-companion-prototype/project/Scrabble Companion.dc.html
```

Design tokens, screens, motion, and component inventory are captured in:

- [`.design/claude_design.md`](.design/claude_design.md)
- [`docs/ui_guidelines.md`](docs/ui_guidelines.md)

---

## Dictionary decisions (summary)

| Lexicon | File | Words | Role |
| --- | --- | --- | --- |
| **NWL2023** (default) | North American tournament | ~196k | Validity + embedded definitions |
| **CSW21** | British / international | ~279k | Validity + embedded definitions |
| **ospd-defs.txt** | Supplemental OSPD-style defs | ~45k | Fallback / enrichment for older OSPD vocabulary |

Source archive: [scrabblewords/scrabblewords](https://github.com/scrabblewords/scrabblewords).
Users can switch NA ↔ British in Settings. See ADR-0005.

> **License note:** CSW lists include a Collins / HarperCollins notice. Ship a
> `NOTICE` with dictionary assets and review before commercial redistribution.

---

## Documentation map

| Document | Purpose |
| --- | --- |
| [`docs/technical_design.md`](docs/technical_design.md) | Full technical design |
| [`docs/architecture.md`](docs/architecture.md) | Layers, folders, dependency rules |
| [`docs/data_flow.md`](docs/data_flow.md) | Runtime flows for timer, dict, scores |
| [`docs/ui_guidelines.md`](docs/ui_guidelines.md) | Design system for Flutter |
| [`docs/future_ideas.md`](docs/future_ideas.md) | Backlog beyond v1 |
| [`docs/coding_standards.md`](docs/coding_standards.md) | Style & review bar |
| [`docs/branching_strategy.md`](docs/branching_strategy.md) | `main` / `dev` / features |
| [`docs/release_process.md`](docs/release_process.md) | Versioning & store release |
| [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) | How to contribute |
| [`docs/adr/`](docs/adr/) | Architecture Decision Records |
| [`tasks.md`](tasks.md) | Living milestone checklist |
| [`CHANGELOG.md`](CHANGELOG.md) | Keep a Changelog |

---

## Getting started (once the app is scaffolded)

```bash
git clone https://github.com/<org>/scrabble-companion.git
cd scrabble-companion
flutter pub get
flutter run
```

Quality gates:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

---

## Assets already in repo

| Path | Use |
| --- | --- |
| `sound1.mp3` | Countdown warning chime (~13s) |
| `ospd-defs.txt` | Offline definitions corpus (restored) |
| `scrabble-companion-prototype/` | Claude Design handoff (reference only) |

---

## License

MIT - see [`LICENSE`](LICENSE). Dictionary assets may carry additional terms.
