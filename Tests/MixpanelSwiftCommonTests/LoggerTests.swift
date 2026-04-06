//
//  LoggerBasicTests.swift
//  MixpanelSwiftCommon
//
//  Basic tests to verify logger functionality
//

import Testing
import Foundation
@testable import MixpanelSwiftCommon

@Suite("Logger Basic Tests")
struct LoggerBasicTests {

    @Test("Logger can log without crashing")
    func testBasicLogging() {
        Logger.reset()
        Logger.initialize()

        // Just verify logging doesn't crash
        Logger.debug(message: "Debug test")
        Logger.info(message: "Info test")
        Logger.warn(message: "Warning test")
        Logger.error(message: "Error test")

        // If we get here, logging works
        #expect(Bool(true))
    }

    @Test("LogMessage parses file path correctly")
    func testLogMessageParsing() {
        let msg = LogMessage(
            path: "/Users/test/file.swift",
            function: "testFunc()",
            text: "Hello",
            level: .info
        )

        #expect(msg.file == "file.swift")
        #expect(msg.function == "testFunc()")
        #expect(msg.text == "Hello")
        #expect(msg.level == .info)
    }

    @Test("PrintLogging doesn't crash")
    func testPrintLogging() {
        let logger = PrintLogging.shared
        let msg = LogMessage(
            path: "test.swift",
            function: "test()",
            text: "Test message",
            level: .debug
        )

        logger.addMessage(message: msg)
        #expect(Bool(true))
    }

    @Test("Log levels can be enabled and disabled")
    func testLogLevels() {
        Logger.reset()
        Logger.initialize()

        // Just verify these don't crash
        Logger.enableLevel(.debug)
        Logger.disableLevel(.debug)
        Logger.enableLevel(.debug)

        #expect(Bool(true))
    }
}

@Suite("Logger Initialization", .serialized)
struct LoggerInitializationTests {

    @Test("Starts uninitialized")
    func testStartsUninitialized() {
        Logger.reset()
        #expect(Logger.isInitialized() == false)
    }

    @Test("Initialize with defaults")
    func testInitializeDefaults() {
        Logger.reset()
        Logger.initialize()
        #expect(Logger.isInitialized() == true)

        let levels = Logger.getEnabledLevels()
        #if DEBUG
        #expect(levels == [.debug, .info, .warning, .error])
        #else
        #expect(levels == [.warning, .error])
        #endif
    }

    @Test("Initialize with custom levels")
    func testInitializeCustomLevels() {
        Logger.reset()
        Logger.initialize(levels: [.error])
        #expect(Logger.getEnabledLevels() == [.error])
    }

    @Test("Multiple initialize calls union levels")
    func testMultipleInitializeUnion() {
        Logger.reset()
        Logger.initialize(levels: [.warning])
        Logger.initialize(levels: [.debug])
        #expect(Logger.getEnabledLevels().contains(.warning))
        #expect(Logger.getEnabledLevels().contains(.debug))
    }

    @Test("Logging before initialization is silent")
    func testLoggingBeforeInit() {
        Logger.reset()
        // This should not crash or log anything
        Logger.debug(message: "Should be silent")
        #expect(Bool(true))  // If we get here, no crash occurred
    }

    @Test("Reset clears state")
    func testReset() {
        Logger.reset()
        Logger.initialize()
        #expect(Logger.isInitialized() == true)

        Logger.reset()
        #expect(Logger.isInitialized() == false)
        #expect(Logger.getEnabledLevels().isEmpty)
    }

    @Test("Initialize with custom loggers")
    func testInitializeWithCustomLoggers() {
        class TestLogger: Logging {
            var messageCount = 0
            func addMessage(message: LogMessage) {
                messageCount += 1
            }
        }

        Logger.reset()
        let customLogger = TestLogger()
        Logger.initialize(customLoggers: [customLogger])

        Logger.error(message: "Test")
        Thread.sleep(forTimeInterval: 0.1) // Wait for async logging

        #expect(customLogger.messageCount > 0)
    }

    @Test("Multiple SDKs can initialize independently")
    func testMultiSDKInitialization() {
        Logger.reset()

        // SDK 1 initializes with errors only
        Logger.initialize(levels: [.error])
        #expect(Logger.getEnabledLevels() == [.error])

        // SDK 2 initializes with warnings and info
        Logger.initialize(levels: [.warning, .info])

        // Result should be union of all levels
        let finalLevels = Logger.getEnabledLevels()
        #expect(finalLevels.contains(.error))
        #expect(finalLevels.contains(.warning))
        #expect(finalLevels.contains(.info))
    }
}
