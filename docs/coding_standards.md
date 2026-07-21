# Coding Standards

## Principles

1. **Clarity over cleverness** — prefer boring Dart.
2. **Small PRs** — one concern per PR when possible.
3. **Tests for logic** — UI can be golden/widget; domain must be unit-tested.
4. **No dead code** — delete, don’t comment out.
5. **Match neighbors** — consistency beats personal taste.

## Dart / Flutter

- `dart format` is mandatory (line width default 80 unless repo later sets 100).
- `flutter analyze` must be clean on CI.
- Prefer `const` constructors.
- Prefer single quotes.
- Prefer trailing commas for clean diffs.
- Public API types are explicit (`type_annotate_public_apis`).
- Avoid `print`; use `debugPrint` or a tiny `AppLog` gated to debug.
- Do not swallow errors with empty `catch`.

## Riverpod

- Name providers `xxxProvider`; notifiers `XxxNotifier`.
- Prefer `Notifier` / `AsyncNotifier` over legacy `StateNotifier` unless needed.
- Use `ref.watch(provider.select(...))` to limit rebuilds.
- Override dependencies in tests — don’t reach into singletons.

## Widgets

- Split widgets when `build` exceeds ~80 lines or nests deeply.
- Private widgets stay in the same file until reused.
- Design-system components are prefixed `Sc` (Scrabble Companion).
- No business logic in `build` beyond trivial mapping.

## Files & names

- `snake_case.dart` files
- `PascalCase` types
- Feature folders match route names

## Comments & docs

- Document **why**, not what, for non-obvious code.
- Public domain services get dartdoc.
- Dictionary parser gets a format example in dartdoc.

## Forbidden without ADR

- Adding a new state-management library
- Adding network calls to the dictionary path
- Checking in secrets / keystores
- Disabling analyzer rules globally

## Review checklist

- [ ] Matches UI guidelines for any visual change
- [ ] Accessibility: labels, targets, contrast
- [ ] Tests updated
- [ ] CHANGELOG / tasks.md updated when milestone-relevant
- [ ] No new warnings
