# Architecture

## Philosophy

Prefer **simple, boring, testable** structure over framework fashion.

The bar: would a Very Good Ventures / Google Flutter engineer find the
boundaries obvious in under ten minutes?

## Pattern

**Feature-first Clean Architecture** with Riverpod as the composition root.

```
┌─────────────────────────────────────────────┐
│  app/     bootstrap, router, MaterialApp    │
├─────────────────────────────────────────────┤
│  features/*   UI + feature notifiers        │
├─────────────────────────────────────────────┤
│  core/    design system, shared widgets     │
├─────────────────────────────────────────────┤
│  domain   entities + repository contracts   │
│  (often colocated under features/*/domain)  │
├─────────────────────────────────────────────┤
│  data/    Drift, parsers, repository impls  │
└─────────────────────────────────────────────┘
```

### Dependency rules

1. `features/*` may depend on `core/` and domain contracts.
2. `data/` implements domain contracts; **features never import Drift tables**.
3. `core/` must not depend on features.
4. No circular feature imports — share via `core/` or domain.

### Feature module layout

```
features/timer/
  presentation/
    timer_screen.dart
    widgets/
  application/
    timer_notifier.dart
  domain/
    timer_state.dart
```

Thin features (Home) may flatten folders until complexity appears.
**Do not** create empty layers for ceremony.

## Why not pure package-per-layer monorepo?

Premature. A single `lib/` with clear folders is enough for this product size.
Extract packages only when a boundary is reused (e.g. `scrabble_lexicon` pub
package) or when build times demand it.

## Why not Bloc globally?

Bloc/Cubit is excellent. Riverpod was chosen for:

- Fewer files per feature for this app’s surface area
- First-class overrides in tests
- Unified DI + state without a second service locator

Feature teams may still use a Cubit-like `Notifier` style — same idea.

## Navigation architecture

Bottom navigation owns four branches. Score Keeper is a **stack overlay**
above the shell (matches prototype fullscreen overlay), not a fifth tab.

```
ShellRoute
  ├── /home
  ├── /timer
  ├── /dictionary
  └── /settings
Root
  ├── /game          (score keeper)
  └── /game/winner   (optional)
```

## Dictionary boundary

```
DictionaryRepository (interface)
        ▲
        │
AssetLexiconRepository  ── parses assets, caches via Drift
```

UI talks only to Riverpod providers that call the repository.

## Persistence boundary

```
SettingsRepository
GameRepository
FavoritesRepository
```

All backed by one Drift database. Schema changes go through numbered
migrations; never silent `onCreate` resets in production builds.

## Cross-cutting services

| Service | Responsibility |
| --- | --- |
| `Clock` | Injectable time for tests |
| `HapticsService` | Respects user toggle |
| `SoundService` | Off / A / B + volume |
| `Analytics` | No-op stub in v1 |

## Testing seams

Every repository and service is provided via Riverpod so widget tests can
`overrideWithValue` fakes without `mockito` codegen unless needed.

## Related ADRs

- [0001 Architecture](adr/0001-architecture.md)
- [0002 State management](adr/0002-state-management.md)
- [0003 Routing](adr/0003-routing.md)
- [0004 Persistence](adr/0004-persistence.md)
- [0005 Dictionary](adr/0005-dictionary.md)
