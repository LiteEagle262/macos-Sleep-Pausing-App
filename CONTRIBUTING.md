# Contributing

Open an issue describing the behavior you want to change before a large feature. For a bug, include your macOS version, Mac architecture, steps to reproduce, and expected versus actual behavior.

Keep the app small and native. Power-management changes need tests covering failure and cleanup. UI changes should include screenshots in light and dark mode.

Run `./scripts/test.sh`, `swift test` with full Xcode, and `./scripts/build-app.sh` before opening a pull request. Do not commit certificates, credentials, generated builds, or personal machine paths.
