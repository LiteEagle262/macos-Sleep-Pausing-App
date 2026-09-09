#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
APP="dist/Sleep Pause.app"
# Separate builds also work with Command Line Tools, without full Xcode.
swift build -c release --arch arm64
swift build -c release --arch x86_64
ARM_BIN="$(swift build -c release --arch arm64 --show-bin-path)/SleepPause"
INTEL_BIN="$(swift build -c release --arch x86_64 --show-bin-path)/SleepPause"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
lipo -create "$ARM_BIN" "$INTEL_BIN" -output "$APP/Contents/MacOS/SleepPause"
cp Resources/Info.plist "$APP/Contents/Info.plist"
swift scripts/make-icon.swift .build/AppIcon.iconset
iconutil -c icns .build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
plutil -lint "$APP/Contents/Info.plist"
codesign --force --options runtime --sign "${SIGNING_IDENTITY:--}" "$APP"
codesign --verify --strict --verbose=2 "$APP"
echo "Built $APP"
