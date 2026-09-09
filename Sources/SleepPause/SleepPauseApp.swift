import SwiftUI
import AppKit
import SleepPauseCore

@main
struct SleepPauseApp: App {
    @StateObject private var session = SleepSession()

    var body: some Scene {
        MenuBarExtra {
            SleepPanel(session: session)
        } label: {
            Label(session.isPaused ? "Sleep paused" : "Sleep Pause",
                  systemImage: session.isPaused ? "pause.circle.fill" : "moon.zzz")
        }
        .menuBarExtraStyle(.window)
    }
}

