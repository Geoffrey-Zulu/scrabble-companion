# Data Flow

## Overview

```
UI event → Riverpod Notifier → Domain service / Repository → Drift / Assets
                ↓
           state emit
                ↓
           UI rebuild (narrow selects)
```

No network I/O on the product’s critical paths.

---

## App start

```
main()
  → WidgetsFlutterBinding
  → open Drift database
  → load Settings
  → runApp(ProviderScope → ScrabbleApp)
  → splash (~1150 ms) then shell
  → lexicon warm in background (default NWL)
```

Failure to open DB → blocking error screen with retry (rare).

---

## Settings

```
User toggles theme
  → SettingsNotifier.updateTheme
  → SettingsRepository.save
  → Drift settings row upsert
  → ThemeMode rebuild via watch
```

Sound mode similarly updates `SoundService` configuration immediately and
persists asynchronously.

---

## Timer

```
toggle
  → TimerNotifier.start/pause
  → HapticsService (if enabled)
  → Stopwatch start/stop
  → UI ticker watches remainingDuration

remaining ≤ warnAt && running
  → SoundService.playWarning (mode A/B)
  → HapticsService.warn

remaining == 0
  → state = expired
  → SoundService.playExpiry
  → HapticsService.heavy
```

Player switch (game active):

```
switchPlayer / chip tap
  → tPlayer = next/index
  → remaining = duration
  → running = false
```

Background:

```
AppLifecycleState.paused
  → TimerNotifier.pauseForBackground()  # v1 policy: pause
```

---

## Dictionary lookup

```
onQuery changed (debounced)
  → normalize A–Z uppercase
  → DictionaryController.setQuery
  → if length ≥ 1: Lexicon.suggest(prefix, 5)

onCheck / Enter / suggestion tap
  → Lexicon.isValid(word)
  → Lexicon.definition(word)  # may enrich via ospd-defs
  → Lexicon.points(word)
  → push RecentLookup repository
  → emit Result(valid, def, pos, pts, …)
  → light haptic (success/error)
```

Lexicon switch:

```
Settings.dictionaryLocale = csw
  → LexiconLoader.activate(csw)
  → dispose previous HashSet when idle
  → toast “British word list ready”
```

---

## Score keeper

### Start game

```
New Game sheet → Start
  → GameRepository.create(players)
  → GameNotifier.setActive(game)
  → navigate /game
```

### Add turn

```
Add → sheet open
  → keypad builds points string
  → optional word
  → submit
  → GameRepository.addTurn(...)
  → update player score
  → close sheet
  → haptic medium
```

### Undo

```
Undo
  → pop last turn
  → subtract points
  → persist
```

### End game

```
End Game
  → mark finished, endedAt
  → compute winner + stats
  → persist GameSummary for Home recent
  → update aggregate Stats
  → show winner route/overlay
  → confetti (if motion allowed)
```

### Delete recent

```
Swipe → delete
  → GameRepository.deleteSummary(id)
  → animate height collapse
```

---

## Persistence map

| User-facing data | Table(s) |
| --- | --- |
| Settings | `settings` |
| Active + finished games | `games`, `players`, `turns` |
| Home recent list | derived from finished `games` |
| Favorites | `favorite_words` |
| Recent lookups | `recent_lookups` |
| Lifetime stats | `stats` |
| Cached definitions | optional `lexicon_entries` |

---

## Error propagation

Repositories throw typed errors or return `Result`. Notifiers catch and expose
`AsyncValue` / explicit `errorMessage` for toasts. Dictionary parse skips bad
lines; load still succeeds if coverage remains high.
