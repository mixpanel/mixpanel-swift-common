//
//  MixpanelEventBridgeTests.swift
//  MixpanelSwiftCommon
//
//  Created by Mixpanel on 2026-03-31.
//

import Testing
import Foundation
@testable import MixpanelSwiftCommon

@Suite("MixpanelEventBridge Tests")
struct MixpanelEventBridgeTests {

    init() {
        // Initialize logger to see debug output from EventBridge
        MixpanelLogger.initialize()
    }

    // MARK: - Event Struct Tests

    @Test("Event struct creation")
    func testEventStructCreation() {
        let event = MixpanelEvent(
            eventName: "test_event",
            properties: ["key": "value", "number": 42]
        )

        #expect(event.eventName == "test_event")
        #expect(event.properties["key"] as? String == "value")
        #expect(event.properties["number"] as? Int == 42)
    }

    // MARK: - Singleton Tests

    @Test("Shared instance is accessible")
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testSharedInstance() {
        let bridge1 = MixpanelEventBridge.shared
        let bridge2 = MixpanelEventBridge.shared

        #expect(bridge1 === bridge2)
    }

    // MARK: - Event Stream Tests

    @Test("Event stream can be created")
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testEventStreamCreation() {
        let bridge = MixpanelEventBridge.shared
        let stream = bridge.eventStream()

        // Verify stream is created (type check)
        #expect(stream is AsyncStream<MixpanelEvent>)
    }

    @Test("Notify listeners executes without error")
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testNotifyListeners() {
        let bridge = MixpanelEventBridge.shared

        // Should not crash
        bridge.notifyListeners(
            eventName: "test_event",
            properties: ["key": "value"]
        )
    }
}
