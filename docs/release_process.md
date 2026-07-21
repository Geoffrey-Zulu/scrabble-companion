# Release Process

## Versioning

Semantic Versioning: `MAJOR.MINOR.PATCH`

- **MAJOR** - breaking UX/data migrations users must notice
- **MINOR** - features backward compatible
- **PATCH** - fixes

App version lives in `pubspec.yaml` (`version: X.Y.Z+BUILD`).

## Checklist before release PR (`dev` → `main`)

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

### Android (Play Store)

1. Create an upload keystore once (keep a secure offline backup):

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Copy `android/key.properties.example` → `android/key.properties` and fill passwords.
3. Build the signed App Bundle:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

4. Upload the `.aab` in [Google Play Console](https://play.google.com/console).

Never commit `key.properties`, `*.jks`, or `*.keystore`.

### iOS

- Archive via Xcode / CI with distribution cert


## Hotfix

1. Branch `hotfix/*` from `main`
2. Fix + bump PATCH
3. PR to `main`, tag
4. Merge `main` back into `dev`

## Post-release

- Verify crash-free sessions for 48h
- File follow-ups into `tasks.md` / `future_ideas.md`
