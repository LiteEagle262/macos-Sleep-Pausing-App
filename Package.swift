// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SleepPause",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "SleepPause", targets: ["SleepPause"])],
    targets: [
        .target(name: "SleepPauseCore", linkerSettings: [.linkedFramework("IOKit")]),
        .executableTarget(name: "SleepPause", dependencies: ["SleepPauseCore"]),
        .testTarget(name: "SleepPauseCoreTests", dependencies: ["SleepPauseCore"])
    ]
)
