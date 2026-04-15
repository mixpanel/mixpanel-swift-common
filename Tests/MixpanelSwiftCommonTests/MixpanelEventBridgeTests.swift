//
//  MixpanelEventBridgeTests.swift
//  MixpanelSwiftCommon
//
//  Created by Mixpanel on 2026-03-31.
//

import Testing
import Foundation
@testable import MixpanelSwiftCommon

@Suite("MixpanelEventBridge Tests", .serialized)
struct MixpanelEventBridgeTests {

    init() {
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

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    private func firstEvent(
        from stream: AsyncStream<MixpanelEvent>,
        timeoutNanoseconds: UInt64 = 1_000_000_000
    ) async -> MixpanelEvent? {
        await withTaskGroup(of: MixpanelEvent?.self) { group in
            group.addTask {
                for await event in stream {
                    return event
                }
                return nil
            }

            group.addTask {
                try? await Task.sleep(nanoseconds: timeoutNanoseconds)
                return nil
            }

            let event = await group.next() ?? nil
            group.cancelAll()
            return event
        }
    }

    @Test("Event stream yields notified events")
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testEventStreamReceivesNotifiedEvent() async {
        let bridge = MixpanelEventBridge.shared
        let stream = bridge.eventStream()

        let awaitedEvent = Task {
            await firstEvent(from: stream)
        }

        bridge.notifyListeners(
            eventName: "test_event",
            properties: ["key": "value", "number": 42]
        )

        let event = await awaitedEvent.value
        #expect(event != nil)
        #expect(event?.eventName == "test_event")
        #expect(event?.properties["key"] as? String == "value")
        #expect(event?.properties["number"] as? Int == 42)

        // Clean up: cancel task and reset bridge to clear all continuations
        awaitedEvent.cancel()
//        bridge.reset()
    }

    @Test("Stream consumer can receive one event and finish")
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testNotifyListenersWithConsumingTask() async {
        let bridge = MixpanelEventBridge.shared
        var stream: AsyncStream<MixpanelEvent>? = bridge.eventStream()
        var iterator = stream?.makeAsyncIterator()

        bridge.notifyListeners(
            eventName: "termination_test_event",
            properties: ["key": "value"]
        )

        var event = await iterator?.next()

        #expect(event?.eventName == "termination_test_event")
        #expect(event?.properties["key"] as? String == "value")

        // Clean up: reset stream 
        stream = nil
        iterator = nil
    }
}
