//
//  MixpanelLogger.swift
//  MixpanelSwiftCommon
//
//  Copyright © 2026 Mixpanel. All rights reserved.
//

import Foundation
import os.log
import os

/// Defines the various levels of logging that a message may be tagged with.
public enum LogLevel: String {
    case debug
    case info
    case warning
    case error

    /// Maps to OSLogType for legacy os_log calls (iOS 12-13)
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default // os_log doesn't have "warning", use default
        case .error: return .error
        }
    }
}

/// Main logger class using modern os.Logger (iOS 14+) with fallback to legacy os_log.
///
/// ## Thread Safety
/// Uses NSLock for low-overhead, thread-safe access to configuration and state.
public class MixpanelLogger {
    private static let lock = NSLock()
     
    // Modern logger (iOS 14+)
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    private static var _modernLogger: os.Logger?
    
    // Legacy logger (iOS 12+)
    private static var _legacyLog: OSLog?
    
    private static var _enabledLevels = Set<LogLevel>()
    private static var _initialized = false
    private static var _useModernAPI = false
    
    #if DEBUG
    /// Test-only: allows injecting a test logger for message verification
    internal static var testLogger: TestLogging?
    #endif
    
    /// Initialize the logger with subsystem and category.
    public class func initialize(
        subsystem: String = "com.mixpanel.common",
        category: String = "default",
        levels: Set<LogLevel>? = nil
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        let levelsToEnable = levels ?? defaultLogLevels()
        
        if !_initialized {
            _initialized = true
            _enabledLevels = levelsToEnable
            
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                _modernLogger = os.Logger(subsystem: subsystem, category: category)
                _useModernAPI = true
            } else {
                _legacyLog = OSLog(subsystem: subsystem, category: category)
                _useModernAPI = false
            }
        } else {
            _enabledLevels.formUnion(levelsToEnable)
        }
    }
    
    /// Check if the logger has been initialized
    public class func isInitialized() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return _initialized
    }

    /// Get currently enabled log levels (for testing/debugging)
    internal class func getEnabledLevels() -> Set<LogLevel> {
        lock.lock()
        defer { lock.unlock() }
        return _enabledLevels
    }

    /// Enable log messages of a specific `LogLevel`
    public class func enableLevel(_ level: LogLevel) {
        lock.lock()
        defer { lock.unlock() }
        _enabledLevels.insert(level)
    }

    /// Disable log messages of a specific `LogLevel`
    public class func disableLevel(_ level: LogLevel) {
        lock.lock()
        defer { lock.unlock() }
        _enabledLevels.remove(level)
    }

    /// Reset logger to uninitialized state (for testing only)
    internal class func reset() {
        lock.lock()
        defer { lock.unlock() }
        _initialized = false
        _useModernAPI = false
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            _modernLogger = nil
        }
        _legacyLog = nil
        _enabledLevels.removeAll()
        #if DEBUG
        testLogger = nil
        #endif
    }
    
    private class func defaultLogLevels() -> Set<LogLevel> {
        #if DEBUG
        return [.debug, .info, .warning, .error]
        #else
        return [.warning, .error]
        #endif
    }
    
    // MARK: - Public Logging API
    
    public class func debug(_ message: @autoclosure () -> String, file: String = #file, function: String = #function) {
        log(level: .debug, message: message(), file: file, function: function)
    }
    
    public class func info(_ message: @autoclosure () -> String, file: String = #file, function: String = #function) {
        log(level: .info, message: message(), file: file, function: function)
    }
    
    public class func warn(_ message: @autoclosure () -> String, file: String = #file, function: String = #function) {
        log(level: .warning, message: message(), file: file, function: function)
    }
    
    public class func error(_ message: @autoclosure () -> String, file: String = #file, function: String = #function) {
        log(level: .error, message: message(), file: file, function: function)
    }
    
    // MARK: - Core Implementation
    
    private class func log(level: LogLevel, message: String, file: String, function: String) {
        // Refinement 1: Snapshot state under a single lock to minimize contention
        lock.lock()
        let isInit = _initialized
        let isEnabled = _enabledLevels.contains(level)
        let useModern = _useModernAPI
        lock.unlock()
        
        guard isInit && isEnabled else { return }
        
        let filename = (file as NSString).lastPathComponent
        
#if DEBUG
        if let testLogger = testLogger {
            testLogger.log(level: level, message: message, file: filename, function: function)
        }
#endif
        
        if useModern {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logWithModernAPI(level: level, message: message, filename: filename, function: function)
            }
        } else {
            logWithLegacyAPI(level: level, message: message, filename: filename, function: function)
        }
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    private class func logWithModernAPI(level: LogLevel, message: String, filename: String, function: String) {
        guard let logger = _modernLogger else { return }
        let formatted = "\(filename):\(function) - \(message)"
        
        // Refinement 3: Use explicit .warning level in modern API
        switch level {
        case .debug:   logger.debug("\(formatted, privacy: .public)")
        case .info:    logger.info("\(formatted, privacy: .public)")
        case .warning: logger.warning("\(formatted, privacy: .public)")
        case .error:   logger.error("\(formatted, privacy: .public)")
        }
    }
    
    private class func logWithLegacyAPI(level: LogLevel, message: String, filename: String, function: String) {
        guard let osLog = _legacyLog else { return }
        
        // Refinement 2: Use %{public}@ for Swift strings in C-based os_log
        os_log(
            "%{public}@:%{public}@ - %{public}@",
            log: osLog,
            type: level.osLogType,
            filename,
            function,
            message
        )
    }
}

#if DEBUG
public protocol TestLogging {
    func log(level: LogLevel, message: String, file: String, function: String)
}
#endif
