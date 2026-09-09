#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ -z "${SIGNING_IDENTITY:-}" || -z "${NOTARY_PROFILE:-}" ]]; then
    echo 'Set SIGNING_IDENTITY to a Developer ID Application identity and NOTARY_PROFILE to a notarytool keychain profile.' >&2
    exit 1
fi
if [[ "$SIGNING_IDENTITY" != "Developer ID Application:"* ]]; then
    echo 'Public releases require a Developer ID Application signing identity.' >&2
    exit 1
fi
./scripts/build-app.sh
APP="dist/Sleep Pause.app"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist")
ZIP="dist/Sleep-Pause-$VERSION-macos.zip"
ditto -c -k --keepParent "$APP" "dist/notarization.zip"
xcrun notarytool submit dist/notarization.zip --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"
spctl --assess --type execute --verbose=2 "$APP"
ditto -c -k --keepParent "$APP" "$ZIP"
(cd dist && shasum -a 256 "Sleep-Pause-$VERSION-macos.zip" > SHA256SUMS.txt)
echo "Release ready: $ZIP"
