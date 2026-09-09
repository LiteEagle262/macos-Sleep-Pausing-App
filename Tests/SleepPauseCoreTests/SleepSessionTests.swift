import XCTest
@testable import SleepPauseCore

private final class FakeAssertion: PowerAsserting {
    var acquisitions = 0
    var releases = 0
    var failAcquire = false
    var failRelease = false
    func acquire() throws {
        if failAcquire { throw NSError(domain: "Test", code: 1) }
        acquisitions += 1
    }
    func release() throws {
        if failRelease { throw NSError(domain: "Test", code: 2) }
        releases += 1
    }
}

final class SleepSessionTests: XCTestCase {
    func testToggleAndRepeatedStart() async {
        await MainActor.run {
            let power = FakeAssertion()
            let session = SleepSession(assertion: power)
            XCTAssertFalse(session.isPaused)
            session.start()
            session.start()
            XCTAssertTrue(session.isPaused)
            XCTAssertEqual(power.acquisitions, 1)
            XCTAssertNil(session.deadline)
            session.stop()
            XCTAssertFalse(session.isPaused)
            XCTAssertEqual(power.releases, 1)
        }
    }

    func testDeadlineAndWakeAfterExpiry() async {
        await MainActor.run {
            let power = FakeAssertion()
            let session = SleepSession(assertion: power)
            let now = Date(timeIntervalSince1970: 1000)
            session.start(minutes: 30, now: now)
            session.checkDeadline(now: now.addingTimeInterval(1799))
            XCTAssertTrue(session.isPaused)
            session.checkDeadline(now: now.addingTimeInterval(1900))
            XCTAssertFalse(session.isPaused)
            XCTAssertNil(session.deadline)
            XCTAssertEqual(power.releases, 1)
        }
    }

    func testAcquisitionFailureDoesNotShowActive() async {
        await MainActor.run {
            let power = FakeAssertion()
            power.failAcquire = true
            let session = SleepSession(assertion: power)
            session.start(minutes: 30)
            XCTAssertFalse(session.isPaused)
            XCTAssertNil(session.deadline)
            XCTAssertNotNil(session.errorMessage)
            power.failAcquire = false
            session.start()
            XCTAssertTrue(session.isPaused)
            XCTAssertNil(session.errorMessage)
            session.stop()
        }
    }

    func testReleaseFailureKeepsActiveUntilRetry() async {
        await MainActor.run {
            let power = FakeAssertion()
            let session = SleepSession(assertion: power)
            session.start()
            power.failRelease = true
            session.stop()
            XCTAssertTrue(session.isPaused)
            XCTAssertNotNil(session.errorMessage)
            power.failRelease = false
            session.stop()
            XCTAssertFalse(session.isPaused)
            XCTAssertNil(session.errorMessage)
        }
    }

    func testRealPowerAssertionLifecycle() throws {
        let power = SystemPowerAssertion()
        try power.acquire()
        try power.acquire()
        try power.release()
        try power.release()
    }
}
