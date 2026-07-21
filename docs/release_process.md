# Release Process

## Versioning

Semantic Versioning: `MAJOR.MINOR.PATCH`

- **MAJOR** - breaking UX/data migrations users must notice
- **MINOR** - features backward compatible
- **PATCH** - fixes

App version lives in `pubspec.yaml` (`version: X.Y.Z+BUILD`).

## Checklist before release PR (`develop` → `main`)

1. [`tasks.md`](../tasks.md) release milestone items complete
2. CHANGELOG `[Unreleased]` moved into `## [X.Y.Z] - YYYY-MM-DD`
3. `flutter analyze` clean
4. `flutter test` green
5. Manual smoke: timer, dictionary (both lexicons), full game, settings persistence, cold start offline (airplane mode)
6. Accessibility smoke (large text + TalkBack/VoiceOver spot-check)
7. Store assets ready (icon, screenshots)
8. Privacy policy URL live
9. Dictionary `NOTICE` present
10. No secrets in tree

## Tagging

```bash
git checkout main
git pull
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags
```

## Store builds

- Android: app bundle signed with upload key (key.properties gitignored)
- iOS: Archive via Xcode / CI with distribution cert

## Hotfix

1. Branch `hotfix/*` from `main`
2. Fix + bump PATCH
3. PR to `main`, tag
4. Merge `main` back into `develop`

## Post-release

- Verify crash-free sessions for 48h
- File follow-ups into `tasks.md` / `future_ideas.md`
