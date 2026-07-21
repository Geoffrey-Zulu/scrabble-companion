# ADR-0002 — State management: Riverpod 3

- **Status:** Accepted
- **Date:** 2026-07-21

## Context

Need compile-safe dependency injection, testable state, and minimal boilerplate
for timers, games, settings, and dictionary loading.

Options: `flutter_riverpod` 3.x, `bloc`/`flutter_bloc`, `provider`, plain
`InheritedWidget`, `signals`.

Research (2026): Riverpod 3.3.2 is stable on Dart 3.7+ and is the default
recommendation for many greenfield Flutter apps. Bloc remains excellent for
event-sourced UIs and large teams standardized on it.

## Decision

Adopt **`flutter_riverpod` ^3.3.2** with `Notifier` / `AsyncNotifier`.

Do not adopt flutter_hooks unless a concrete UI need appears.

## Consequences

- Single tool for DI + state.
- Easy provider overrides in tests.
- Team must learn Riverpod codegen only if we later opt into `riverpod_annotation`
  (optional — start without codegen to reduce build_runner surface).
