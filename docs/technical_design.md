# Technical Design Document - Scrabble Companion

**Version:** 0.1  
**Date:** 2026-07-21  
**Status:** Approved for implementation  
**Authors:** Engineering lead (this repository)  
**Audience:** Future maintainers, reviewers, contributors

---

## 1. Purpose

Build a production-quality, **offline-first** Flutter companion for Scrabble that
a senior engineer can inherit years later without archaeological work.

The app ships three pillars:

1. **Turn timer** - precise, beautiful, haptic/sonic feedback  
2. **Word checker** - tournament-grade validity + definitions, zero latency feel  
3. **Score keeper** - multi-player games with history and stats  

All data and lookups work without a network connection.

---

## 2. Goals & non-goals

### Goals

- Premium UX matching the Claude Design prototype
- Instant word validation on device
- Durable local persistence across restarts
- Strict analysis, strong tests, clear ADRs
- Support **North American** and **British** English lexicons
- Accessibility (large text, screen readers, contrast, reduce motion)

### Non-goals (v1)

- Online multiplayer / accounts / sync
- Board visualization or move solver
- Non-English lexicons
- Monetization / ads
- Web / desktop as primary targets (may run, not polished)

---

## 3. Toolchain (researched, not hallucinated)

| Component | Choice | Evidence |
| --- | --- | --- |
| Flutter | **3.44.6** stable | Local `flutter --version` (2026-07-21); Flutter 3.44 I/O release May 2026 |
| Dart | **3.12.2** | Bundled with Flutter 3.44.6 |
| Lints | `flutter_lints` + strict analyzer | `analysis_options.yaml` |
| Melos | **Not used** | Single app package; revisit only if extracting packages |

Package versions below are the latest **stable** on pub.dev as of 2026-07-21.
Lock exact versions in `pubspec.yaml` at scaffold time.

| Package | Planned | Why |
| --- | --- | --- |
| `flutter_riverpod` | ^3.3.2 | Compile-safe DI + state; test overrides; industry default for new Flutter apps |
| `go_router` | ^17.3.0 | Official Flutter team router; `StatefulShellRoute` for bottom nav; deep links |
| `drift` + `drift_flutter` / `sqlite3_flutter_libs` | ^2.34.2 | Actively maintained type-safe SQLite; migrations; relational games/turns |
| `shared_preferences` | latest stable | Tiny bootstrap flags only (e.g. first-run); not primary store |
| `audioplayers` or `just_audio` | evaluate at impl | Play `sound1.mp3` / `sound2.mp3`; prefer the lighter API that supports volume |
| `intl` | latest | Date labels for recent games |
| `equatable` / freezed *(optional)* | prefer simple equality first | Avoid codegen unless models grow painful |
| `mocktail` + `flutter_test` | latest | Unit/widget tests |
| `alchemist` or golden toolkit | evaluate | Golden tests for design atoms |

**Rejected for new work:**

| Option | Reason |
| --- | --- |
| Hive (classic) / Isar (classic) | Upstream maintenance risk; community forks add uncertainty for a multi-year product |
| Bloc as primary | Excellent, but more boilerplate for this app’s size; Riverpod covers the same needs |
| AutoRoute | Strong typed routes, but go_router is the Flutter-team default and enough for 4 tabs + overlays |
| Online definition APIs | Violates offline-first; last resort only |

---

## 4. Architecture

### 4.1 Style

**Feature-first Clean Architecture** (pragmatic, not ceremonial).

```
Presentation (Widgets + Riverpod Notifiers)
        ↓ depends on
Domain (entities, use cases / services, repository interfaces)
        ↓ depends on
Data (Drift, asset parsers, repository implementations)
```

Dependency rule: **inner layers never import Flutter UI or Drift.**  
Features own their presentation; shared UI lives in `core/`.

### 4.2 Folder structure (target)

```
lib/
  main.dart
  app/
    app.dart
    bootstrap.dart
    router.dart
    theme/
  core/
    constants/
    design/          # tokens, theme extensions
    widgets/         # Sc* shared components
    utils/
    errors/
    services/        # haptics, sound, clock
  features/
    home/
    timer/
    dictionary/
    score/
    settings/
  data/
    local/
      database.dart
      tables/
      daos/
    dictionary/
      word_list_parser.dart
      lexicon_loader.dart
    repositories/
assets/
  audio/sound1.mp3
  audio/sound2.mp3
  dictionaries/
    nwl2023.txt
    csw21.txt
    ospd-defs.txt
    NOTICE
test/
integration_test/
docs/
.design/
```

### 4.3 State management

**Riverpod 3** with `Notifier` / `AsyncNotifier` per feature.

- Settings → durable `SettingsNotifier`
- Timer → ephemeral `TimerNotifier` (persists only last duration preference)
- Active game → `GameNotifier` backed by repository
- Dictionary → `DictionaryController` + lexicon provider family by locale

Providers are the composition root; widgets stay dumb.

See [ADR-0002](adr/0002-state-management.md).

### 4.4 Navigation

**go_router** with:

- `StatefulShellRoute.indexedStack` for Home / Timer / Dictionary / Settings
- Imperative overlays for Score Keeper, New Game sheet, Win screen
  (fullscreen routes or root navigator pages - prefer routes over ad-hoc
  stacks so back button / Android predictive back work)

See [ADR-0003](adr/0003-routing.md).

---

## 5. Theme system

Tokens extracted from prototype CSS (`:root` / `[data-theme="dark"]`):

| Token | Light | Dark |
| --- | --- | --- |
| desk | `#E7E4DB` | `#0E0D0B` |
| bg | `#FAF9F5` | `#181713` |
| card | `#FFFFFF` | `#221F1B` |
| ink | `#141413` | `#F4F2EB` |
| muted | `#8C8A80` | `#918E84` |
| faint | `#B0AEA5` | `#605D55` |
| line | `#E8E6DC` | `#2E2B26` |
| accent | `#D97757` | `#E28A6C` |
| accentSoft | `#F5E4DB` | `#3A2A22` |
| valid | `#4F8A6D` | `#7BB093` |
| invalid | `#B4534B` | `#D07E74` |
| field | `#F1EFE8` | `#2A2723` |

Typography: system / SF Pro on Apple; on Android use a high-quality sans
(`google_fonts` with **Inter is avoided** per product design rules - prefer
something expressive but legible such as **Source Sans 3** or **IBM Plex Sans**
if system fonts feel insufficient). Tabular numbers for timer and scores.

Spacing scale: 4 / 8 / 10 / 12 / 14 / 16 / 18 / 22 / 26 / 34 (from prototype).  
Radii: 12–16 (small), 18–22 (cards), 24–28 (pills / CTAs), 46 (timer primary).

Theme modes: **Light / Dark / System** (exact segmented control in Settings).

Full guidelines: [`ui_guidelines.md`](ui_guidelines.md).

---

## 6. Dictionary architecture

### 6.1 Source evaluation

| Source | Verdict |
| --- | --- |
| [scrabblewords/scrabblewords](https://github.com/scrabblewords/scrabblewords) | **Selected.** English NA + British lists; `.txt` lines include definitions |
| [kamilmielnik/scrabble-dictionaries](https://github.com/kamilmielnik/scrabble-dictionaries) | Clean word-only lists; no defs - useful backup, not primary |
| [fogleman/twl06](https://github.com/fogleman/twl06) | Excellent DAWG idea for memory; outdated TWL06; no defs |
| [Ada-Developers-Academy/dictionary](https://github.com/Ada-Developers-Academy/dictionary) | General English, not tournament Scrabble |
| [redbo/scrabble](https://github.com/redbo/scrabble) | Incomplete / project-specific |

### 6.2 Lexicons to ship

| Locale setting | File | Approx. size | Lines |
| --- | --- | --- | --- |
| North American (default) | `NWL2023.txt` | ~7.4 MB | ~196,601 |
| British | `CSW21.txt` | ~13 MB | ~279,078 |

**Both are supported**; switching in Settings reloads the active lexicon.

### 6.3 Line formats

**NWL / CSW (primary):**

```
WORD plain definition text [pos INFLECTIONS]
```

Examples:

```
AA rough, cindery lava [n AAS]
AD an {advertisement=n} [n ADS]
AAH an interjection expressing surprise [interj] / to exclaim in surprise [v -ED, -ING, -S]
```

CSW first line is a `#` license comment - skip `#` lines.

**ospd-defs.txt (supplemental):**

```
WORD pos inflection_fragment definition…
AA n pl. -S rough, cindery lava
ABASE v ABASED, ABASING, ABASES to lower in rank…
```

~45,486 entries. Restored into the repo (placeholder was empty). Used when
the primary entry is a pure cross-reference (`{x=n}` / `<x=v>`) to improve UX.

### 6.4 Runtime model

```
LexiconService
  load(locale) → Lexicon
Lexicon
  isValid(word) → bool          # HashSet
  definition(word) → Definition?
  suggest(prefix, limit) → List<String>
  points(word) → int            # standard English tile values
```

**Loading strategy:**

1. Prefer a **build-time** script that emits a compact asset
   (gzipped JSON or messagepack of `{word, def, pos}`) - optional optimization.
2. v1 acceptable path: parse `.txt` once on first use of a locale, cache into
   Drift tables, subsequent launches read Drift (or keep HashSet warm in memory).

Memory: one active `HashSet` (~200–280k strings) is acceptable on modern phones.
Do **not** keep both lexicons fully expanded unless the user has switched
recently (LRU of one).

### 6.5 Performance budget

| Operation | Target |
| --- | --- |
| Exact validity after warm | < 1 ms |
| Prefix suggestions (5) | < 16 ms (debounce 50–100 ms on input) |
| First locale load | < 2 s on mid-tier device; show non-blocking progress |

Prefix search: group by first letter buckets or maintain sorted list + binary
search range - avoid scanning 280k on every keystroke.

---

## 7. Storage

### Decision: Drift (SQLite)

Relational shape fits games → players → turns. Migrations are first-class.
Hive/Isar rejected for long-term maintenance risk (see ADR-0004).

### Entities (logical)

- **Settings** - theme, textScale, warnAt, soundMode, volume, haptics, dictionaryLocale
- **Game** - id, startedAt, endedAt, finished, durationMs
- **Player** - gameId, name, seatIndex, finalScore
- **Turn** - gameId, playerId, round, points, word?, createdAt
- **FavoriteWord** - word, lexicon, createdAt
- **RecentLookup** - word, valid, lookedUpAt
- **Stats** - aggregates (gamesCount, winsByName, highestTurn, longestGameMs)

### Offline strategy

There is no sync layer. Drift is the system of record. Export/share is
best-effort (clipboard / share sheet) without servers.

---

## 8. Score Keeper

- **Players:** 2–6 (prototype `addPlayer` cap; grid remains usable)
- **Per turn:** points (0–999), optional word
- **Undo:** pop last turn, subtract points
- **Edit previous rounds:** v1.1 stretch if undo insufficient; track in tasks
- **End game:** compute winner, stats, persist summary to recent (cap 12)
- Survive process death via Drift

---

## 9. Timer

- Durations: 30 / 60 / 120 / 180
- State machine: idle → running → paused → expired
- Implementation: `Stopwatch` + periodic UI refresh (or `Ticker`) to avoid
  cumulative drift from chained `Timer.periodic` seconds
- Warn window: accent ring + optional sound/haptics
- Sound modes: **Off / A / B**; volume slider if OS allows meaningful control
- Lifecycle: when app backgrounds, freeze remaining based on elapsed wall clock
  or pause - **prefer pause on background** for fairness at the table (document
  in Settings help text)
- Integrate player names when `Game` active

---

## 10. Animations & haptics

Prototype keyframes to port:

| Name | Use |
| --- | --- |
| `tileIn` | Splash tile |
| `fadeName` | Splash title |
| `fadeIn` / `fadeUp` | Screen / result entrance |
| `pop` | Winner title |
| `fall` | Confetti tiles |
| `sheetUp` | Bottom sheets |

Curves: `cubic-bezier(.2,.8,.2,1)` ≈ Flutter `Cubic(0.2, 0.8, 0.2, 1)`.

Haptics (gated): timer start/pause, warn, expiry, add score, delete game,
valid/invalid word (light/success/error differently).

Respect reduced motion: skip confetti/fall; use opacity fades only.

---

## 11. Accessibility

- Semantics on icon-only buttons
- Dynamic type via Settings text scale × MediaQuery
- Contrast: ink on bg / accent on white meets AA in both themes (verify with tooling)
- Min touch target 44×44
- Announce timer expiry via semantics live region where supported

---

## 12. Testing strategy

| Layer | What |
| --- | --- |
| Unit | Parser, points, timer state machine, scoring undo, settings reduce |
| Repository | Drift in-memory |
| Widget | Each primary screen state matrix |
| Golden | Buttons, cards, search field, theme pair |
| Integration | New game → turns → end → appears in recent |

CI: format + analyze + test on PR to `develop`.

---

## 13. Error handling

- Typed failures: `DictionaryLoadException`, `PersistenceException`
- UI: toast for recoverable; inline empty/error for load failures
- Never crash on bad dictionary lines - skip + log count in debug

---

## 14. Performance considerations

- Avoid rebuilding shell on timer tick - narrow `ref.watch` selects
- Dictionary load on isolate (`compute` / `Isolate.run`) if parse > 300 ms
- Compress assets with gzip if raw text bloats IPA/APK
- Impeller default on modern Flutter - avoid unnecessary saveLayers

---

## 15. Security & privacy

- No accounts, no analytics required for v1
- No network calls in release dictionary path
- Contact links in Settings open external apps only on user tap
- Privacy policy: local-only data statement

---

## 16. Risk analysis

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Dictionary licensing (esp. CSW / Collins) | Legal | Ship NOTICE; allow disabling CSW build flavor if needed |
| Large asset size | Store / install | Compress; optional download-on-demand later (still offline after) |
| Timer drift / background kill | Fairness | Stopwatch + explicit pause-on-background |
| Memory with large lexicons | Low-end devices | Single active lexicon; optional word-only bloom if needed |
| Design MCP unavailable | Fidelity | Local HTML handoff is authoritative |
| Empty ospd-defs originally | Missing defs | Restored; primary defs come from NWL/CSW anyway |
| Isar/Hive churn | Maintenance | Chose Drift |

---

## 17. Future scalability

See [`future_ideas.md`](future_ideas.md). Architecture leaves room for:

- Additional lexicons behind the same `Lexicon` interface
- Optional cloud backup without rewriting domain
- Solver features as a new feature module

---

## 18. Open questions (resolved for v1)

| Question | Decision |
| --- | --- |
| NA vs British? | Support both; default NWL2023 |
| Max players? | 6 |
| Melos? | No |
| Online defs? | No |
| Primary DB? | Drift |

---

## 19. Implementation order

Follow [`../tasks.md`](../tasks.md) milestones 0 → 14. Dictionary and Drift
early; UI shell in parallel; polish last.
