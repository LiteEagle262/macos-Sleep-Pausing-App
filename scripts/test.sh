#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build
swiftc Sources/SleepPauseCore/SleepSession.swift scripts/SmokeTests.swift -o .build/smoke-tests
.build/smoke-tests
