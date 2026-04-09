//
//  MixpanelEventBridge.swift
//  MixpanelSwiftCommon
//
//  Created by Ketan on 25/03/26.
//  Copyright © 2026 Mixpanel. All rights reserved.
//

import Foundation

/// Represents a tracked event to be broadcasted through the bridge.
///
/// - Note: This type is marked as `@unchecked Sendable` because it carries a `[String: Any]` dictionary.
/// To maintain thread safety, ensure that all values stored in the `properties` dictionary are inherently
/// thread-safe (e.g., `String`, `Int`, `Double`, `Bool`, `Date`, or `URL`). Avoid passing mutable
/// reference types or UI-related objects.
public struct MixpanelEvent: @unchecked Sendable {
    public let eventName: String
    public let properties: [String: Any]

    public init(eventName: String, properties: [String: Any]) {
        self.eventName = eventName
        self.properties = properties
    }
}

/// Event bridge for multicasting Mixpanel events to external consumers via AsyncStream.
/// Thread-safe, supports multiple concurrent stream consumers with automatic cleanup.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class MixpanelEventBridge: NSObject, @unchecked Sendable {

    // MARK: - Singleton
    /// Shared instance
    @objc public static let shared = MixpanelEventBridge()

    // MARK: - Private Properties

    /// Thread-safe storage for active stream continuations
    private var continuations: [UUID: AsyncStream<MixpanelEvent>.Continuation] = [:]
    private let continuationsLock = NSLock()

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Public API

    /// Creates a new event stream for consuming tracked events.
    ///
    /// Each call returns a new, independent stream that receives all subsequent events.
    /// The stream automatically cleans up when deallocated or cancelled.
    ///
    /// - Returns: AsyncStream that yields MixpanelEvent instances for all tracked events
    public func eventStream() -> AsyncStream<MixpanelEvent> {
        let id = UUID()

        return AsyncStream { continuation in
            // Register continuation
            self.continuationsLock.lock()
            self.continuations[id] = continuation
            let streamCount = self.continuations.count
            self.continuationsLock.unlock()

            // Setup automatic cleanup on termination
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }

                self.continuationsLock.lock()
                defer { self.continuationsLock.unlock() }

                self.continuations.removeValue(forKey: id)
                let remainingCount = self.continuations.count
            }
        }
    }

    // MARK: - Event Dispatch

    /// Notify all active stream consumers of a tracked event.
    ///
    /// This method yields the event to all active stream consumers and returns immediately without
    /// blocking. The yield operation is non-blocking; consumers process events asynchronously at their
    /// own pace. Thread-safe with snapshot-based iteration to avoid holding locks during dispatch.
    ///
    /// - Parameters:
    ///   - eventName: Event name
    ///   - properties: Event properties dictionary (ensure values are thread-safe)
    public func notifyListeners(
        eventName: String,
        properties: [String: Any]
    ) {
        let event = MixpanelEvent(eventName: eventName, properties: properties)
        
        // Get snapshot of active continuations
        continuationsLock.lock()
        let activeConsumers = Array(self.continuations.values)
        continuationsLock.unlock()
        
        // Yield to all consumers
        for continuation in activeConsumers {
            continuation.yield(event)
        }
    }
}
