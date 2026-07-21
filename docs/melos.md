# Why there is no melos.yaml

Melos is appropriate for **multi-package** Dart/Flutter repositories (apps +
shared packages + example apps).

Scrabble Companion is intentionally a **single application package** for v1.
Introducing Melos now would add:

- bootstrap scripts and version orchestration
- `pubspec_overrides` noise
- cognitive overhead for a solo-friendly / small-team codebase

If we later extract e.g. `packages/scrabble_lexicon`, add Melos (or an equivalent
workspace) in the same PR that creates the second package — not before.

See ADR-0001.
