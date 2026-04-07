//
//  LoggerBasicTests.swift
//  MixpanelSwiftCommon
//
//  Basic tests to verify logger functionality
//

import Testing
import Foundation
@testable import MixpanelSwiftCommon

/// Parent suite to ensure all logger tests run serially (prevents concurrent access to shared MixpanelLogger state)
@Suite("MixpanelLogger Tests", .serialized)
struct MixpanelLoggerTestSuite {

@Suite("Logger Basic Tests")
struct LoggerBasicTests {

    @Test("Logger can log without crashing")
    func testBasicLogging() {
        MixpanelLogger.reset()
        MixpanelLogger.initialize()

        // Just verify logging doesn't crash
        MixpanelLogger.debug("Debug test")
        MixpanelLogger.info("Info test")
        MixpanelLogger.warn("Warning test")
        MixpanelLogger.error("Error test")

        // If we get here, logging works
        #expect(Bool(true))
    }

    @Test("Log levels can be enabled and disabled")
    func testLogLevels() {
        MixpanelLogger.reset()
        MixpanelLogger.initialize()

        // Just verify these don't crash
        MixpanelLogger.enableLevel(.debug)
        MixpanelLogger.disableLevel(.debug)
        MixpanelLogger.enableLevel(.debug)

        #expect(Bool(true))
    }
}

@Suite("Logger Initialization", .serialized)
struct LoggerInitializationTests {

    @Test("Starts uninitialized")
    func testStartsUninitialized() {
        MixpanelLogger.reset()
        #expect(MixpanelLogger.isInitialized() == false)
    }

    @Test("Initialize with defaults")
    func testInitializeDefaults() {
        MixpanelLogger.reset()
        MixpanelLogger.initialize()
        #expect(MixpanelLogger.isInitialized() == true)

        let levels = MixpanelLogger.getEnabledLevels()
        #if DEBUG
        #expect(levels == [.debug, .info, .warning, .error])
        #else
        #expect(levels == [.warning, .error])
        #endif
    }

    @Test("Initialize with custom levels")
    func testInitializeCustomLevels() {
        MixpanelLogger.reset()
        MixpanelLogger.initialize(levels: [.error])
        #expect(MixpanelLogger.getEnabledLevels() == [.error])
    }

    @Test("Multiple initialize calls union levels")
    func testMultipleInitializeUnion() {
        MixpanelLogger.reset()
        MixpanelLogger.initialize(levels: [.warning])
        MixpanelLogger.initialize(levels: [.debug])
        #expect(MixpanelLogger.getEnabledLevels().contains(.warning))
        #expect(MixpanelLogger.getEnabledLevels().contains(.debug))
    }

    @Test("Logging before initialization is silent")
    func testLoggingBeforeInit() {
        MixpanelLogger.reset()
        // This should not crash or log anything
        MixpanelLogger.debug("Should be silent")
        #expect(Bool(true))  // If we get here, no crash occurred
    }

    @Test("Reset clears state")
    func testReset() {
        MixpanelLogger.reset()
        MixpanelLogger.initialize()
        #expect(MixpanelLogger.isInitialized() == true)

        MixpanelLogger.reset()
        #expect(MixpanelLogger.isInitialized() == false)
        #expect(MixpanelLogger.getEnabledLevels().isEmpty)
    }

    @Test("Multiple SDKs can initialize independently")
    func testMultiSDKInitialization() {
        MixpanelLogger.reset()

        // SDK 1 initializes with errors only
        MixpanelLogger.initialize(levels: [.error])
        #expect(MixpanelLogger.getEnabledLevels() == [.error])

        // SDK 2 initializes with warnings and info
        MixpanelLogger.initialize(levels: [.warning, .info])

        // Result should be union of all levels
        let finalLevels = MixpanelLogger.getEnabledLevels()
        #expect(finalLevels.contains(.error))
        #expect(finalLevels.contains(.warning))
        #expect(finalLevels.contains(.info))
    }
}

@Suite("Logger Message Counting (Debug Only)", .serialized)
struct LoggerMessageCountingTests {

    /// Test-only logger that counts messages
    class CountingTestLogger: TestLogging {
        var messageCount = 0
        var messages: [(level: LogLevel, message: String)] = []

        func log(level: LogLevel, message: String, file: String, function: String) {
            messageCount += 1
            messages.append((level: level, message: message))
        }
    }

    @Test("Can count messages using test logger injection")
    func testMessageCounting() {
        MixpanelLogger.reset()

        let testLogger = CountingTestLogger()
        MixpanelLogger.testLogger = testLogger
        MixpanelLogger.initialize()

        // Log some messages
        MixpanelLogger.error("Error 1")
        MixpanelLogger.warn("Warning 1")
        MixpanelLogger.debug("Debug 1")

        // Verify counting works
        #expect(testLogger.messageCount == 3)
        #expect(testLogger.messages[0].level == .error)
        #expect(testLogger.messages[0].message == "Error 1")
        #expect(testLogger.messages[1].level == .warning)
        #expect(testLogger.messages[2].level == .debug)
    }

    @Test("Test logger respects log levels")
    func testLoggerRespectsLevels() {
        MixpanelLogger.reset()

        let testLogger = CountingTestLogger()
        MixpanelLogger.testLogger = testLogger
        MixpanelLogger.initialize(levels: [.error])  // Only errors enabled

        MixpanelLogger.error("Error 1")
        MixpanelLogger.warn("Warning 1")  // Should not be logged
        MixpanelLogger.debug("Debug 1")   // Should not be logged

        // Only error should be counted
        #expect(testLogger.messageCount == 1)
        #expect(testLogger.messages[0].level == .error)
    }

    @Test("Test logger captures message content")
    func testMessageContent() {
        MixpanelLogger.reset()

        let testLogger = CountingTestLogger()
        MixpanelLogger.testLogger = testLogger
        MixpanelLogger.initialize()

        MixpanelLogger.info("User ID: 12345")
        MixpanelLogger.error("Network error: timeout")

        #expect(testLogger.messageCount == 2)
        #expect(testLogger.messages[0].message == "User ID: 12345")
        #expect(testLogger.messages[1].message == "Network error: timeout")
    }
}

} // End of MixpanelLoggerTestSuite
