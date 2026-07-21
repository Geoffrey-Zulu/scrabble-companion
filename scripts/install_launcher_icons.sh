#!/usr/bin/env bash
# Reinstall launcher icons from assets/icons masters into native projects.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC_ANDROID=assets/icons/Android
RES=android/app/src/main/res
cp "$SRC_ANDROID/drawable-mdpi/icon.png"    "$RES/mipmap-mdpi/ic_launcher.png"
cp "$SRC_ANDROID/drawable-hdpi/icon.png"    "$RES/mipmap-hdpi/ic_launcher.png"
cp "$SRC_ANDROID/drawable-xhdpi/icon.png"   "$RES/mipmap-xhdpi/ic_launcher.png"
cp "$SRC_ANDROID/drawable-xxhdpi/icon.png"  "$RES/mipmap-xxhdpi/ic_launcher.png"
cp "$SRC_ANDROID/drawable-xxxhdpi/icon.png" "$RES/mipmap-xxxhdpi/ic_launcher.png"

mkdir -p assets/store
cp "$SRC_ANDROID/playstore-icon.png" assets/store/playstore-icon.png
cp assets/icons/iOS/iTunesArtwork@2x.png assets/store/app-store-icon-1024.png

IOS_SRC=assets/icons/iOS
IOS_DST=ios/Runner/Assets.xcassets/AppIcon.appiconset
cp "$IOS_SRC/icon-20.png"            "$IOS_DST/Icon-App-20x20@1x.png"
cp "$IOS_SRC/icon-20@2x.png"         "$IOS_DST/Icon-App-20x20@2x.png"
cp "$IOS_SRC/icon-20@3x.png"         "$IOS_DST/Icon-App-20x20@3x.png"
cp "$IOS_SRC/icon-29.png"            "$IOS_DST/Icon-App-29x29@1x.png"
cp "$IOS_SRC/icon-29@2x.png"         "$IOS_DST/Icon-App-29x29@2x.png"
cp "$IOS_SRC/icon-29@3x.png"         "$IOS_DST/Icon-App-29x29@3x.png"
cp "$IOS_SRC/icon-40.png"            "$IOS_DST/Icon-App-40x40@1x.png"
cp "$IOS_SRC/icon-40@2x.png"         "$IOS_DST/Icon-App-40x40@2x.png"
cp "$IOS_SRC/icon-40@3x.png"         "$IOS_DST/Icon-App-40x40@3x.png"
cp "$IOS_SRC/icon-60@2x.png"         "$IOS_DST/Icon-App-60x60@2x.png"
cp "$IOS_SRC/icon-60@3x.png"         "$IOS_DST/Icon-App-60x60@3x.png"
cp "$IOS_SRC/icon-76.png"            "$IOS_DST/Icon-App-76x76@1x.png"
cp "$IOS_SRC/icon-76@2x.png"         "$IOS_DST/Icon-App-76x76@2x.png"
cp "$IOS_SRC/icon-83.5@2x.png"       "$IOS_DST/Icon-App-83.5x83.5@2x.png"
cp "$IOS_SRC/iTunesArtwork@2x.png"   "$IOS_DST/Icon-App-1024x1024@1x.png"

echo "Launcher icons installed."
