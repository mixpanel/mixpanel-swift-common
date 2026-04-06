//
//  Logger.swift
//  MixpanelSwiftCommon
//
//  Copyright © 2026 Mixpanel. All rights reserved.
//

import Foundation

/// Defines the various levels of logging that a message may be tagged with.
/// This allows hiding and showing different logging levels at run time depending on the environment.
public enum LogLevel: String {
    /// Logging displays *all* logs and additional debug information that may be useful to a developer
    case debug

    /// Logging displays *all* logs (**except** debug)
    case info

    /// Logging displays *only* warnings and above
    case warning

    /// Logging displays *only* errors and above
    case error
}

/// Holds all the data for each log message, since the formatting is up to each logging object.
/// It is a simple bag of data.
public struct LogMessage {
    /// The file where this log message was created
    public let file: String

    /// The function where this log message was created
    public let function: String

    /// The text of the log message
    public let text: String

    /// The level of the log message
    public let level: LogLevel

    public init(path: String, function: String, text: String, level: LogLevel) {
        if let file = path.components(separatedBy: "/").last {
            self.file = file
        } else {
            self.file = path
        }
        self.function = function
        self.text = text
        self.level = level
    }
}

/// Any object that conforms to this protocol may log messages
public protocol Logging {
    func addMessage(message: LogMessage)
}

/// Main logger class that manages log levels and forwards messages to registered loggers.
///
/// ## Initialization Required
/// Logger must be explicitly initialized before use via `Logger.initialize()`.
/// Until initialized, all logging calls are silent no-ops.
///
/// ## Multi-SDK Support
/// Multiple SDKs can safely call `initialize()`. Log levels are unioned (most permissive wins).
///
/// ## Usage
/// ```swift
/// // In SDK initialization
/// Logger.initialize() // Uses build-appropriate defaults
///
/// // Logging
/// Logger.debug(message: "Debug info")
/// Logger.error(message: "Error occurred")
/// ```
///
/// ## Thread Safety
/// All operations are thread-safe using an internal serial queue.
public class Logger {
    private static nonisolated(unsafe) var loggers = [Logging]()
    private static nonisolated(unsafe) var enabledLevels = Set<LogLevel>()
    private static nonisolated(unsafe) var initialized = false
    private static let serialQueue = DispatchQueue(label: "com.mixpanel.shared.logger")

    /// Initialize the logger with optional custom configuration.
    ///
    /// This method can be called multiple times safely. Subsequent calls will:
    /// - Union log levels with already-enabled levels (most permissive)
    /// - Add any new custom loggers
    ///
    /// - Parameters:
    ///   - levels: Set of log levels to enable. If nil, uses build-appropriate defaults:
    ///             - DEBUG builds: [.debug, .info, .warning, .error]
    ///             - RELEASE builds: [.warning, .error]
    ///   - customLoggers: Array of custom loggers to register. If nil, adds PrintLogging.shared
    ///                    on first initialization only.
    ///
    /// - Note: Logging calls made before initialization are silent no-ops.
    public class func initialize(
        levels: Set<LogLevel>? = nil,
        customLoggers: [Logging]? = nil
    ) {
        serialQueue.sync {
            let levelsToEnable = levels ?? defaultLogLevels()

            if !initialized {
                // First initialization
                initialized = true
                enabledLevels = levelsToEnable

                let loggersToAdd = customLoggers ?? [PrintLogging.shared]
                loggers.append(contentsOf: loggersToAdd)
            } else {
                // Subsequent initialization - union levels
                enabledLevels.formUnion(levelsToEnable)

                // Add custom loggers if provided
                if let newLoggers = customLoggers {
                    loggers.append(contentsOf: newLoggers)
                }
            }
        }
    }

    /// Check if the logger has been initialized
    public class func isInitialized() -> Bool {
        serialQueue.sync { initialized }
    }

    /// Get currently enabled log levels (for testing/debugging)
    internal class func getEnabledLevels() -> Set<LogLevel> {
        serialQueue.sync { enabledLevels }
    }

    /// Reset logger to uninitialized state (for testing only)
    internal class func reset() {
        serialQueue.sync {
            initialized = false
            loggers.removeAll()
            enabledLevels.removeAll()
        }
    }

    /// Get build-appropriate default log levels
    private class func defaultLogLevels() -> Set<LogLevel> {
        #if DEBUG
        return [.debug, .info, .warning, .error]
        #else
        return [.warning, .error]
        #endif
    }

    /// Add a `Logging` object to receive all log messages
    public class func addLogging(_ logging: Logging) {
        serialQueue.sync {
            loggers.append(logging)
        }
    }

    /// Enable log messages of a specific `LogLevel` to be added to the log
    public class func enableLevel(_ level: LogLevel) {
        serialQueue.sync {
            enabledLevels.insert(level)
        }
    }

    /// Disable log messages of a specific `LogLevel` to prevent them from being logged
    public class func disableLevel(_ level: LogLevel) {
        serialQueue.sync {
            enabledLevels.remove(level)
        }
    }

    /// debug: Adds a debug message to the Mixpanel log
    /// - Parameter message: The message to be added to the log
    public class func debug(
        message: @autoclosure () -> Any,
        _ path: String = #file,
        _ function: String = #function
    ) {
        let messageText = "\(message())" // Evaluate before async
        serialQueue.async {
            guard initialized else { return }
            guard enabledLevels.contains(.debug) else { return }
            forwardLogMessage(
                LogMessage(
                    path: path,
                    function: function,
                    text: messageText,
                    level: .debug
                )
            )
        }
    }

    /// info: Adds an informational message to the Mixpanel log
    /// - Parameter message: The message to be added to the log
    public class func info(
        message: @autoclosure () -> Any,
        _ path: String = #file,
        _ function: String = #function
    ) {
        let messageText = "\(message())" // Evaluate before async
        serialQueue.async {
            guard initialized else { return }
            guard enabledLevels.contains(.info) else { return }
            forwardLogMessage(
                LogMessage(
                    path: path,
                    function: function,
                    text: messageText,
                    level: .info
                )
            )
        }
    }

    /// warn: Adds a warning message to the Mixpanel log
    /// - Parameter message: The message to be added to the log
    public class func warn(
        message: @autoclosure () -> Any,
        _ path: String = #file,
        _ function: String = #function
    ) {
        let messageText = "\(message())" // Evaluate before async
        serialQueue.async {
            guard initialized else { return }
            guard enabledLevels.contains(.warning) else { return }
            forwardLogMessage(
                LogMessage(
                    path: path,
                    function: function,
                    text: messageText,
                    level: .warning
                )
            )
        }
    }

    /// error: Adds an error message to the Mixpanel log
    /// - Parameter message: The message to be added to the log
    public class func error(
        message: @autoclosure () -> Any,
        _ path: String = #file,
        _ function: String = #function
    ) {
        let messageText = "\(message())" // Evaluate before async
        serialQueue.async {
            guard initialized else { return }
            guard enabledLevels.contains(.error) else { return }
            forwardLogMessage(
                LogMessage(
                    path: path,
                    function: function,
                    text: messageText,
                    level: .error
                )
            )
        }
    }

    /// This forwards a `LogMessage` to each logger that has been added
    private class func forwardLogMessage(_ message: LogMessage) {
        // Forward the log message to every registered Logging instance
        loggers.forEach { $0.addMessage(message: message) }
    }
}
