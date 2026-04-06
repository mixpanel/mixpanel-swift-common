//
//  PrintLogging.swift
//  MixpanelSwiftCommon
//
//  Copyright © 2026 Mixpanel. All rights reserved.
//

import Foundation

/// Simply formats and prints the object by calling `print`
public class PrintLogging: Logging {
    public static nonisolated(unsafe) let shared = PrintLogging()
    private init() {}

    public func addMessage(message: LogMessage) {
        print(
            "[Mixpanel Common - \(message.file) - func \(message.function)] (\(message.level.rawValue)) - \(message.text)"
        )
    }

    /// Helper method for simplified logging
    public func log(
        _ level: LogLevel,
        _ message: String,
        file: String = #file,
        function: String = #function
    ) {
        let logMessage = LogMessage(path: file, function: function, text: message, level: level)
        addMessage(message: logMessage)
    }
}

/// Simply formats and prints the object by calling `debugPrint`.
/// This makes things a bit easier if you need to print data that may be quoted for instance.
public class PrintDebugLogging: Logging {
    public static nonisolated(unsafe) let shared = PrintDebugLogging()
    private init() {}

    public func addMessage(message: LogMessage) {
        debugPrint(
            "[Mixpanel Common - \(message.file) - func \(message.function)] (\(message.level.rawValue)) - \(message.text)"
        )
    }

    /// Helper method for simplified logging
    public func log(
        _ level: LogLevel,
        _ message: String,
        file: String = #file,
        function: String = #function
    ) {
        let logMessage = LogMessage(path: file, function: function, text: message, level: level)
        addMessage(message: logMessage)
    }
}
