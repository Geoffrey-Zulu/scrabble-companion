# Contributing

Thanks for helping improve Scrabble Companion.

## Before you start

1. Read [`README.md`](../README.md) and [`architecture.md`](architecture.md).
2. Skim open ADRs in [`adr/`](adr/).
3. Check [`tasks.md`](../tasks.md) so work isn’t duplicated.

## Setup

```bash
flutter channel stable
flutter upgrade
flutter pub get
flutter analyze
flutter test
```

Use Flutter **3.44.x** stable (see README).

## Workflow

1. Branch from `dev` - see [`branching_strategy.md`](branching_strategy.md).
2. Follow [`coding_standards.md`](coding_standards.md).
3. Match [`ui_guidelines.md`](ui_guidelines.md) for UI work.
4. Add/adjust tests.
5. Update `tasks.md` checkboxes and CHANGELOG under Unreleased when relevant.
6. Open a PR to `dev`.

## PR expectations

- Clear description of **why**
- Screenshots/recordings for UI
- Notes on dictionary or schema migrations
- CI green

## Code of conduct (short)

Be respectful. Assume good intent. Prefer precise technical disagreement over
personal critique.

## License

By contributing, you agree your contributions are licensed under the MIT
License in the repository root. Do not contribute dictionary material you
cannot license for redistribution.
