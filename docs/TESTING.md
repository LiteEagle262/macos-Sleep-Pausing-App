# Testing

## Automated

`./scripts/test.sh` works with Command Line Tools. It exercises state transitions, duplicate activation, acquisition and release failures, indefinite sessions, expiry, and a real IOKit assertion verified through `pmset`.

`swift test` runs the XCTest suite with full Xcode. CI runs both test commands and builds the universal app. Unit tests use an injected power provider; the integration test briefly holds a real assertion.

## Before a public release

- Launch from Applications. Confirm a menu bar icon appears with no Dock icon or main window.
- Open the popover. Test mouse and keyboard navigation, Escape dismissal, and VoiceOver labels.
- Turn on Pause sleep. Confirm the icon and status change and `pmset -g assertions` lists the app's assertion.
- Turn it off. Confirm the app's assertion disappears, including after repeated toggles.
- Start a timed session and verify countdown and expiry. Test manual sleep/wake after the deadline.
- Quit while active. Confirm the assertion disappears. Relaunch and verify sleep prevention starts off.
- Force quit while active. Confirm macOS removes the process-owned assertion.
- Check light and dark appearance, increased contrast, and the smallest supported display size.
- Verify idle work continues with the screen locked and display off. Do not expect lid closure or explicit Sleep to be blocked.
- Test on macOS 13 and the current macOS, on Apple Silicon and Intel hardware.
- Open the signed, notarized ZIP on a clean Mac and verify Gatekeeper accepts it.

A successful universal build confirms both architectures compile; it does not replace testing on Intel hardware or older macOS versions.

## Initial local verification

Verified on an Apple Silicon Mac with macOS 26 and Command Line Tools: universal build, signature validation, standalone tests, and direct SwiftUI panel rendering in light and dark mode. The app process launches. Desktop automation timed out inspecting the windowless menu bar app, so interactive popover checks remain on the manual checklist. XCTest requires full Xcode and could not run on this machine.
