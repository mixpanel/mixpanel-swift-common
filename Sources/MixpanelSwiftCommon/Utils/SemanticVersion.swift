//
//  SemanticVersion.swift
//  MixpanelSwiftCommon
//
//  Copyright © 2026 Mixpanel. All rights reserved.
//

import Foundation

/// Semantic Versioning 2.0.0 comparison, per [semver.org](https://semver.org).
///
/// Kept free of any JSONLogic type so the same ordering can back either engine.
public enum SemanticVersion {

    // SemVer 2.0.0 requires major.minor.patch; partial versions are zero-padded to this.
    private static let parts = 3

    // Longest operand the regex below is allowed to see. A real version never approaches this; the
    // bound matches MAX_LENGTH in node-semver, and keeps an arbitrarily long property value off the
    // regex regardless of how the engine schedules backtracking.
    private static let maxLength = 256

    // Using the official semantic versioning 2.0.0 regular expression to handle cross-platform validation
    // differences on other SDK's. For example, some platforms allow leading zeros even though it is not valid
    // as part of the Semver 2.0.0 spec. See https://semver.org/
    private static let regex = try? NSRegularExpression(
        pattern: "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)"
            + "(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?"
            + "(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$"
    )

    /// Orders two versions, returning a negative number, zero, or a positive number.
    ///
    /// Both sides are normalized first: surrounding whitespace is trimmed, a leading `v` or `V` is dropped,
    /// and a partial version is zero-padded. Returns nil when either side is still not a valid version,
    /// which callers treat as "no match".
    public static func compare(_ actual: String, _ target: String) -> Int64? {
        guard actual.count <= maxLength, target.count <= maxLength else {
            return nil
        }
        let normalizedActual = normalize(actual)
        let normalizedTarget = normalize(target)
        guard isValid(normalizedActual), isValid(normalizedTarget) else {
            return nil
        }
        return compareValidated(normalizedActual, normalizedTarget)
    }

    private static func normalize(_ version: String) -> String {
        let trimmed = version.trimmingCharacters(in: .whitespacesAndNewlines)
        let stripped = stripVersionPrefix(trimmed)

        var suffixStart = stripped.endIndex
        for separator: Character in ["-", "+"] {
            if let index = stripped.firstIndex(of: separator), index < suffixStart {
                suffixStart = index
            }
        }

        let core = stripped[stripped.startIndex..<suffixStart]
        let suffix = stripped[suffixStart...]

        // A core that is empty or holds more than three segments stays as it is, so it is never padded into
        // a version such as "0.0.0" that would then pass validation.
        let segments = core.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        guard (1...parts).contains(segments.count) else {
            return stripped
        }
        let padded = segments + Array(repeating: "0", count: parts - segments.count)
        return padded.joined(separator: ".") + suffix
    }

    /// A leading v is accepted in either case, so it is stripped before the version is validated.
    private static func stripVersionPrefix(_ version: String) -> String {
        guard let first = version.first, first == "v" || first == "V" else {
            return version
        }
        return String(version.dropFirst())
    }

    private static func isValid(_ version: String) -> Bool {
        guard let regex = regex else {
            return false
        }
        let range = NSRange(version.startIndex..<version.endIndex, in: version)
        return regex.firstMatch(in: version, range: range) != nil
    }

    private static func isNumericIdentifier(_ identifier: String) -> Bool {
        return !identifier.isEmpty && identifier.allSatisfy { $0.isASCII && $0.isNumber }
    }

    // Numeric identifiers carry no leading zeros, so the longer run of digits is the larger number.
    // Comparing them as digits rather than parsing to an integer keeps versions that overflow 64 bits
    // ordered correctly.
    private static func compareNumeric(_ a: String, _ b: String) -> Int64 {
        if a.count != b.count {
            return a.count < b.count ? -1 : 1
        }
        return compareASCII(a, b)
    }

    // Every identifier is restricted to [0-9A-Za-z-] by the official regex, so scalar order is ASCII order.
    private static func compareASCII(_ a: String, _ b: String) -> Int64 {
        if a == b {
            return 0
        }
        return a < b ? -1 : 1
    }

    // SemVer 2.0.0 section 11.4: digits compare numerically, a numeric identifier ranks below an
    // alphanumeric one, and anything else compares by ASCII order.
    private static func comparePrereleaseIdentifier(_ a: String, _ b: String) -> Int64 {
        let aNumeric = isNumericIdentifier(a)
        let bNumeric = isNumericIdentifier(b)
        if aNumeric && bNumeric {
            return compareNumeric(a, b)
        }
        if aNumeric {
            return -1
        }
        if bNumeric {
            return 1
        }
        return compareASCII(a, b)
    }

    // Ordering per SemVer 2.0.0 section 11. Both operands have already been normalized and matched against
    // the official regex, so the core holds exactly three numeric identifiers and every prerelease field is
    // well-formed; the split needs no error path.
    private static func compareValidated(_ actual: String, _ target: String) -> Int64 {
        let (actualCore, actualPrerelease) = split(actual)
        let (targetCore, targetPrerelease) = split(target)

        for index in actualCore.indices {
            let result = compareNumeric(actualCore[index], targetCore[index])
            if result != 0 {
                return result
            }
        }

        // A prerelease ranks below the release it belongs to (section 11.3).
        if actualPrerelease.isEmpty && targetPrerelease.isEmpty {
            return 0
        }
        if actualPrerelease.isEmpty {
            return 1
        }
        if targetPrerelease.isEmpty {
            return -1
        }

        for index in 0..<min(actualPrerelease.count, targetPrerelease.count) {
            let result = comparePrereleaseIdentifier(actualPrerelease[index], targetPrerelease[index])
            if result != 0 {
                return result
            }
        }
        // Every field so far is equal, so the longer list wins (section 11.4.4).
        if actualPrerelease.count != targetPrerelease.count {
            return actualPrerelease.count < targetPrerelease.count ? -1 : 1
        }
        return 0
    }

    // Strip optional build metadata and separate the core version from pre-release identifiers
    private static func split(_ version: String) -> (core: [String], prerelease: [String]) {
        var remaining = Substring(version)
        if let plus = remaining.firstIndex(of: "+") {
            remaining = remaining[remaining.startIndex..<plus]
        }
        guard let dash = remaining.firstIndex(of: "-") else {
            return (remaining.split(separator: ".", omittingEmptySubsequences: false).map(String.init), [])
        }
        let core = remaining[remaining.startIndex..<dash]
        let prerelease = remaining[remaining.index(after: dash)...]
        return (
            core.split(separator: ".", omittingEmptySubsequences: false).map(String.init),
            prerelease.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        )
    }
}
