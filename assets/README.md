# Assets

## Used by the app

| Path | Purpose |
| --- | --- |
| `audio/sound1.mp3` | Timer warning / expiry chime (~13s) |
| `branding/logo.png` | Splash / in-app brand mark (from `logo_ios/logo.png`) |
| `dictionaries/nwl2023.txt` | North American tournament list + defs |
| `dictionaries/csw21.txt` | British / CSW21 list + defs |
| `dictionaries/ospd-defs.txt` | Supplemental OSPD definitions |
| `dictionaries/NOTICE` | Third-party dictionary licensing |
| `store/playstore-icon.png` | Google Play listing master (512×512) |
| `store/app-store-icon-1024.png` | App Store marketing master (1024×1024) |

## Launcher icons (installed into native projects)

Source masters live in `icons/` for regeneration. They are **copied** into:

- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Do not reference `icons/` from `pubspec.yaml` - native builds read the platform folders.

To reinstall after replacing masters:

```bash
# See scripts/install_launcher_icons.sh (or re-run the copy commands in git history)
```

## Not used in the UI

| Path | Notes |
| --- | --- |
| `logo_android/` | Extra logo density set - **not wired** into the Flutter UI or launcher |
| `logo_ios/` | Extra logo set - **not wired** into the Flutter UI or splash |

Kept in the repo only as unused brand leftovers. Safe to delete later if unwanted.
