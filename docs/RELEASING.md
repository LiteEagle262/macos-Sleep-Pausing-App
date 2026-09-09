# Releasing Sleep Pause

## Requirements

Public downloads require an Apple Developer Program membership, a Developer ID Application certificate with its private key in your keychain, and Apple's notarization tools. Do not distribute the ad hoc development build as a signed public release.

1. Update `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist`.
2. Update `CHANGELOG.md` and finish the [test checklist](TESTING.md).
3. Run `./scripts/test.sh` and, with full Xcode, `swift test`.
4. Configure a notarytool keychain profile using Apple's [notarization instructions](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution). Keep credentials in Keychain, never in this repository.
5. Build and notarize:

```sh
export SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)'
export NOTARY_PROFILE='sleep-pause-notary'
./scripts/package-release.sh
```

The script signs a universal app with hardened runtime, submits it for notarization, staples and validates the ticket, checks Gatekeeper acceptance, and writes the final ZIP and SHA-256 checksum in `dist/`. It fails if signing credentials or notarization are unavailable.

6. Test the ZIP on a clean Mac. Confirm the app opens through Gatekeeper and repeat the toggle and quit checks.
7. Commit the version change and tag it `v1.0.0`, substituting the release version.
8. Create a GitHub release for that tag. Attach `Sleep-Pause-<version>-macos.zip` and `SHA256SUMS.txt`, then publish after reviewing the release notes.

The CI workflow tests and builds pull requests. It does not publish releases or expose signing credentials. Repository visibility is managed separately; preparing a release does not make the repository public.
