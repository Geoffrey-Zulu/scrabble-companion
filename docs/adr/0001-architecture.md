# ADR-0001 — Feature-first Clean Architecture

- **Status:** Accepted
- **Date:** 2026-07-21

## Context

We need an architecture that stays maintainable for years, supports strong
testing, and matches the size of Scrabble Companion (three main features +
settings), without drowning in ceremony.

Options considered: layered package monorepo, MVC, MVVM-only, pure Clean
Architecture with many packages, feature-first Clean Architecture.

## Decision

Use **feature-first Clean Architecture inside a single Flutter package**.

- Features own presentation + application notifiers.
- Domain contracts sit next to features or under `data/`-facing interfaces.
- Data implements repositories (Drift, asset loaders).
- `core/` holds design system and shared utilities.

## Consequences

- Fast navigation for newcomers (`features/timer` is obvious).
- Easy to extract a package later if needed.
- Requires discipline: no Drift imports from widgets.
- Melos deferred until a real multi-package need appears.
