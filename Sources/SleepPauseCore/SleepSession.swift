import Foundation
import Combine
import IOKit.pwr_mgt

public protocol PowerAsserting: AnyObject {
    func acquire() throws
    func release() throws
}

public struct PowerError: LocalizedError {
    let operation: String
    let code: IOReturn
    public var errorDescription: String? {
        "Could not \(operation) sleep prevention (macOS error \(code)). Try again."
    }
}

public final class SystemPowerAssertion: PowerAsserting {
    private var id: IOPMAssertionID?
    public init() {}

    public func acquire() throws {
        guard id == nil else { return }
        var newID: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Sleep Pause: keeping work running" as CFString,
            &newID
        )
        guard result == kIOReturnSuccess else { throw PowerError(operation: "start", code: result) }
        id = newID
    }

    public func release() throws {
        guard let id else { return }
        let result = IOPMAssertionRelease(id)
        guard result == kIOReturnSuccess else { throw PowerError(operation: "stop", code: result) }
        self.id = nil
    }

    deinit {
        if let id { IOPMAssertionRelease(id) }
    }
}

@MainActor
public final class SleepSession: ObservableObject {
    @Published public private(set) var isPaused = false
    @Published public private(set) var deadline: Date?
    @Published public private(set) var startedAt: Date?
    @Published public private(set) var errorMessage: String?
    private let assertion: PowerAsserting
    private var timer: Timer?

    public init(assertion: PowerAsserting = SystemPowerAssertion()) {
        self.assertion = assertion
    }

    public func start(minutes: Int = 0, now: Date = Date()) {
        guard !isPaused else { return }
        do {
            try assertion.acquire()
            isPaused = true
            startedAt = now
            deadline = minutes > 0 ? now.addingTimeInterval(Double(minutes) * 60) : nil
            errorMessage = nil
            if deadline != nil {
                let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                    Task { @MainActor in self?.checkDeadline() }
                }
                self.timer = timer
                RunLoop.main.add(timer, forMode: .common)
            }
        } catch { errorMessage = error.localizedDescription }
    }

    public func stop() {
        do {
            try assertion.release()
            timer?.invalidate()
            timer = nil
            isPaused = false
            startedAt = nil
            deadline = nil
            errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }

    public func checkDeadline(now: Date = Date()) {
        if let deadline, now >= deadline { stop() }
    }

    deinit { timer?.invalidate() }
}
