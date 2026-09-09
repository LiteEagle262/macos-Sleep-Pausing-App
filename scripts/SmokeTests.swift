import Foundation

final class FakePower: PowerAsserting {
    var acquisitions = 0
    var releases = 0
    var failAcquire = false
    var failRelease = false
    func acquire() throws {
        if failAcquire { throw NSError(domain: "test", code: 1) }
        acquisitions += 1
    }
    func release() throws {
        if failRelease { throw NSError(domain: "test", code: 2) }
        releases += 1
    }
}

@main
struct SmokeTests {
    @MainActor static func main() throws {
        let power = FakePower()
        let session = SleepSession(assertion: power)
        precondition(!session.isPaused)
        power.failAcquire = true
        session.start()
        precondition(!session.isPaused && session.errorMessage != nil)
        power.failAcquire = false
        let now = Date()
        session.start(minutes: 30, now: now)
        session.start()
        precondition(session.isPaused && power.acquisitions == 1 && session.errorMessage == nil)
        session.checkDeadline(now: now.addingTimeInterval(1799))
        precondition(session.isPaused)
        power.failRelease = true
        session.stop()
        precondition(session.isPaused && session.errorMessage != nil)
        power.failRelease = false
        session.checkDeadline(now: now.addingTimeInterval(1800))
        precondition(!session.isPaused && session.deadline == nil && power.releases == 1)
        session.start()
        precondition(session.deadline == nil)
        session.stop()
        let real = SystemPowerAssertion()
        try real.acquire()
        try real.acquire()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "assertions"]
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        let output = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        process.waitUntilExit()
        precondition(output.contains("Sleep Pause: keeping work running"))
        try real.release()
        try real.release()
        print("PASS: toggle, duplicate start, acquire/release failures, timer expiry, indefinite session, real macOS assertion.")
    }
}
