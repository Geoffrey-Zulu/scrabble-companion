# ADR-0003 - Routing: go_router

- **Status:** Accepted
- **Date:** 2026-07-21

## Context

Four bottom tabs + fullscreen score overlays + sheets. Need deep links,
Android back correctness, and shell navigation that preserves tab state.

Options: `go_router`, `auto_route`, Navigator 2.0 manual, classic Navigator 1.

## Decision

Use **`go_router` ^17.3.0** with `StatefulShellRoute.indexedStack` for tabs.

Score Keeper / Winner are root-stack routes above the shell.

## Consequences

- Aligns with Flutter team’s maintained router.
- Typed routes can be added via `TypedGoRoute` later if desired.
- AutoRoute’s stronger codegen is unnecessary for this navigation graph.
