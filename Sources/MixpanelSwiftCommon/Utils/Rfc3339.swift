//
//  Rfc3339.swift
//  MixpanelSwiftCommon
//
//  Copyright © 2026 Mixpanel. All rights reserved.
//

import Foundation

/// RFC 3339 timestamp handling for date targeting.
///
/// Both sides resolve to whole seconds: sub-second precision is deliberately discarded so that a target
/// carrying an end-of-day `.999` still matches a subject sitting on the last whole second.
///
/// Kept free of any JSONLogic type so the same conversion can back either engine.
public enum Rfc3339 {

    // Strict RFC3339 guard for datetime strings. The date and hour fields are captured so the calendar
    // can be validated separately; the pattern only constrains their shape.
    private static let regex = try? NSRegularExpression(
        pattern:
            "^(\\d{4})-(\\d{2})-(\\d{2})[Tt](\\d{2}):\\d{2}:\\d{2}(\\.\\d+)?([Zz]|[+-]\\d{2}:\\d{2})$"
    )

    // Capture group indices in the pattern above.
    private enum Field {
        static let year = 1
        static let month = 2
        static let day = 3
        static let hour = 4
        static let fraction = 5
    }

    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func daysInMonth(year: Int, month: Int) -> Int {
        switch month {
            case 2:
                let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
                return isLeapYear ? 29 : 28
            case 4, 6, 9, 11:
                return 30
            default:
                return 31
        }
    }

    /// The pattern constrains each field to two digits, which still admits a date that cannot exist,
    /// such as 2026-02-30 or 29 February in a common year. Parsers across the SDK fleet disagree on
    /// those — several roll them forward into a real instant instead of rejecting them — so the
    /// calendar is checked here. RFC 3339 section 5.6 allows hours 00 through 23.
    private static func isRealCalendarDate(year: Int, month: Int, day: Int, hour: Int) -> Bool {
        guard (1...12).contains(month), day >= 1, hour <= 23 else {
            return false
        }
        return day <= daysInMonth(year: year, month: month)
    }

    private static func intField(_ match: NSTextCheckingResult, _ index: Int, in text: String) -> Int? {
        guard let range = Range(match.range(at: index), in: text) else {
            return nil
        }
        return Int(text[range])
    }

    /// Converts an RFC 3339 timestamp to whole seconds since the epoch, or nil when the string is not a
    /// well-formed timestamp.
    public static func toUnixSeconds(_ raw: String) -> Int64? {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let regex = regex else {
            return nil
        }
        let range = NSRange(normalized.startIndex..<normalized.endIndex, in: normalized)
        guard let match = regex.firstMatch(in: normalized, range: range) else {
            return nil
        }
        guard
            let year = intField(match, Field.year, in: normalized),
            let month = intField(match, Field.month, in: normalized),
            let day = intField(match, Field.day, in: normalized),
            let hour = intField(match, Field.hour, in: normalized),
            isRealCalendarDate(year: year, month: month, day: day, hour: hour)
        else {
            return nil
        }
        // The fraction is dropped before parsing rather than after. A Double holding a whole second
        // plus a fraction close enough to 1 rounds up to the next second, which would report an
        // instant a second later than the one written.
        var wholeSeconds = normalized
        if let fraction = Range(match.range(at: Field.fraction), in: normalized) {
            wholeSeconds.removeSubrange(fraction)
        }
        guard let parsed = formatter.date(from: wholeSeconds) else {
            return nil
        }
        return Int64(exactly: parsed.timeIntervalSince1970.rounded(.down))
    }

    /// Converts an epoch-milliseconds target to whole seconds.
    public static func epochMillisToUnixSeconds(_ millis: Int64) -> Int64 {
        return millis / 1000
    }

    /// Converts an epoch-milliseconds target to whole seconds, or nil when it is not a real instant.
    public static func epochMillisToUnixSeconds(_ millis: Double) -> Int64? {
        // Int64(_:) traps on a value that is NaN, infinite, or beyond Int64's range, and a value Int64
        // cannot represent is not a real timestamp anyway.
        guard let milliseconds = Int64(exactly: millis.rounded(.towardZero)) else {
            return nil
        }
        return milliseconds / 1000
    }
}
