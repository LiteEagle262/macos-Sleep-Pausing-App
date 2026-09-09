import SwiftUI
import AppKit
import SleepPauseCore

struct SleepPanel: View {
    @ObservedObject var session: SleepSession
    @AppStorage("durationMinutes") private var duration = 0
    private let repository = URL(string: "https://github.com/LiteEagle262/macos-Sleep-Pausing-App")!

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: session.isPaused ? "pause.circle.fill" : "moon.zzz")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(session.isPaused ? Color.accentColor : Color.secondary)
                    .frame(width: 36)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Pause").font(.headline)
                    Text(session.isPaused ? "Your Mac is staying awake" : "Your Mac can sleep normally")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Toggle(isOn: Binding(get: { session.isPaused }, set: { enabled in
                if enabled { session.start(minutes: duration) } else { session.stop() }
            })) {
                Text("Pause sleep").font(.system(size: 15, weight: .semibold))
            }
            .toggleStyle(.switch)
            .padding(12)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityHint("Keep this Mac awake so work can continue. The display may still turn off.")

            if session.isPaused {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    HStack(spacing: 8) {
                        Image(systemName: "clock").foregroundStyle(.secondary)
                        if let deadline = session.deadline {
                            Text("Resumes in \(remaining(until: deadline, now: context.date))")
                                .monospacedDigit()
                        } else {
                            Text("Until you turn it off")
                        }
                    }.font(.subheadline)
                }
            } else {
                Picker("Pause for", selection: $duration) {
                    Text("Until I turn it off").tag(0)
                    Text("30 minutes").tag(30)
                    Text("1 hour").tag(60)
                    Text("2 hours").tag(120)
                    Text("4 hours").tag(240)
                    Text("8 hours").tag(480)
                }
                .pickerStyle(.menu)
            }

            Text("Your display can turn off while work continues. Keep your laptop lid open.")
                .font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let error = session.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.caption).foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()
            HStack {
                Link("Help & source", destination: repository)
                Spacer()
                Button("Quit") {
                    session.stop()
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .font(.caption)
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 320)
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)) { _ in
            session.checkDeadline()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            session.stop()
        }
    }

    private func remaining(until deadline: Date, now: Date) -> String {
        let seconds = max(0, Int(ceil(deadline.timeIntervalSince(now))))
        return String(format: "%d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }
}
