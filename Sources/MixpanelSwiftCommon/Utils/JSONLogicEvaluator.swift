//
//  JSONLogicEvaluator.swift
//  MixpanelSwiftCommon
//
//  Created by Mixpanel on 2026-03-03.
//  Copyright © 2026 Mixpanel. All rights reserved.
//
//  Full JSONLogic implementation with semantic version comparison support
//  Based on: http://jsonlogic.com/

import Foundation

/// A complete JSONLogic expression evaluator with semantic version comparison support.
///
/// Implements full JSONLogic (http://jsonlogic.com/) specification with enhanced
/// comparison operators that support semantic version strings.
///
/// ## All Supported Operators
/// - **Comparison**: `==`, `===`, `!=`, `!==`, `>`, `>=`, `<`, `<=` (with version support)
/// - **Logical**: `and`, `or`, `!`, `!!`
/// - **Arithmetic**: `+`, `-`, `*`, `/`, `%`, `min`, `max`
/// - **String**: `cat`, `substr`, `in`
/// - **Array**: `merge`, `missing`, `missing_some`
/// - **Data**: `var`, `log`
///
/// ## Version Comparison
/// String comparisons automatically detect semantic version format (e.g., "5.2.0", "1.10.3")
/// and compare them semantically: "5.10.0" > "5.2.0" (not lexicographically).
///
/// ## Variable Resolution
/// Use `{"var": "key_name"}` to reference properties. Missing variables resolve to `null`.
public final class JSONLogicEvaluator {

    public enum EvaluationError: Error {
        case invalidExpression
        case unsupportedOperator(String)
        case typeMismatch
    }

    public init() {}

    /// Evaluate a JSONLogic expression (returns Bool for backward compatibility)
    public func evaluate(
        _ expression: [String: Any],
        data: [String: Any]
    ) throws -> Bool {
        let result = try evaluateExpression(expression, data: data)
        return truthy(result)
    }

    /// Evaluate a JSONLogic expression and return the raw result (Any type)
    /// Use this for testing or when you need the actual computed value (numbers, strings, arrays, etc.)
    public func evaluateRaw(
        _ expression: [String: Any],
        data: [String: Any]
    ) throws -> Any {
        return try evaluateExpression(expression, data: data)
    }

    /// Evaluate a JSONLogic expression (returns Any)
    private func evaluateExpression(
        _ expression: [String: Any],
        data: [String: Any]
    ) throws -> Any {
        guard expression.count == 1,
              let (`operator`, args) = expression.first else {
            Logger.error(message: "Invalid JSONLogic expression (must have exactly one operator): \(expression)")
            throw EvaluationError.invalidExpression
        }

        switch `operator` {
        case "==":
            return try evaluateEquals(args, data: data, strict: false)
        case "===":
            return try evaluateEquals(args, data: data, strict: true)
        case "!=":
            return try !evaluateEquals(args, data: data, strict: false)
        case "!==":
            return try !evaluateEquals(args, data: data, strict: true)
        case "and":
            return try evaluateAnd(args, data: data)
        case "or":
            return try evaluateOr(args, data: data)
        case "!":
            return try evaluateNot(args, data: data)
        case "!!":
            return try evaluateDoubleNegation(args, data: data)
        case ">":
            return try evaluateGreaterThan(args, data: data)
        case ">=":
            return try evaluateGreaterOrEqual(args, data: data)
        case "<":
            return try evaluateLessThan(args, data: data)
        case "<=":
            return try evaluateLessOrEqual(args, data: data)
        case "+":
            return try evaluateAdd(args, data: data)
        case "-":
            return try evaluateSubtract(args, data: data)
        case "*":
            return try evaluateMultiply(args, data: data)
        case "/":
            return try evaluateDivide(args, data: data)
        case "%":
            return try evaluateModulo(args, data: data)
        case "min":
            return try evaluateMin(args, data: data)
        case "max":
            return try evaluateMax(args, data: data)
        case "in":
            return try evaluateIn(args, data: data)
        case "cat":
            return try evaluateCat(args, data: data)
        case "substr":
            return try evaluateSubStr(args, data: data)
        case "merge":
            return try evaluateMerge(args, data: data)
        case "var":
            return try evaluateVar(args, data: data)
        case "missing":
            return try evaluateMissing(args, data: data)
        case "missing_some":
            return try evaluateMissingSome(args, data: data)
        case "log":
            return try evaluateLog(args, data: data)
        default:
            Logger.error(message: "Unsupported JSONLogic operator: '\(`operator`)' in expression: \(expression)")
            throw EvaluationError.unsupportedOperator(`operator`)
        }
    }

    // MARK: - Comparison Operators

    private func evaluateEquals(_ args: Any, data: [String: Any], strict: Bool) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return strict ? isStrictEqual(left, right) : isEqual(left, right)
    }

    private func evaluateGreaterThan(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count >= 2 else {
            throw EvaluationError.invalidExpression
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isGreaterThan(left, right)
    }

    private func evaluateGreaterOrEqual(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count >= 2 else {
            throw EvaluationError.invalidExpression
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isGreaterThan(left, right) || isEqual(left, right)
    }

    private func evaluateLessThan(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count >= 2 else {
            throw EvaluationError.invalidExpression
        }

        // Support 3-arg chaining: {"<": [1, 2, 3]} means 1 < 2 && 2 < 3
        if array.count == 3 {
            let a = try resolveValue(array[0], data: data)
            let b = try resolveValue(array[1], data: data)
            let c = try resolveValue(array[2], data: data)
            return try isLessThan(a, b) && isLessThan(b, c)
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isLessThan(left, right)
    }

    private func evaluateLessOrEqual(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count >= 2 else {
            throw EvaluationError.invalidExpression
        }

        // Support 3-arg chaining: {"<=": [1, 2, 3]} means 1 <= 2 && 2 <= 3
        if array.count == 3 {
            let a = try resolveValue(array[0], data: data)
            let b = try resolveValue(array[1], data: data)
            let c = try resolveValue(array[2], data: data)
            let aLessOrEqualB = try isLessThan(a, b) || isEqual(a, b)
            let bLessOrEqualC = try isLessThan(b, c) || isEqual(b, c)
            return aLessOrEqualB && bLessOrEqualC
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isLessThan(left, right) || isEqual(left, right)
    }

    // MARK: - Logical Operators

    private func evaluateAnd(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let expressions = args as? [[String: Any]] else {
            throw EvaluationError.invalidExpression
        }

        for expr in expressions {
            if try !evaluate(expr, data: data) {
                return false
            }
        }
        return true
    }

    private func evaluateOr(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let expressions = args as? [[String: Any]] else {
            throw EvaluationError.invalidExpression
        }

        for expr in expressions {
            if try evaluate(expr, data: data) {
                return true
            }
        }
        return false
    }

    private func evaluateNot(_ args: Any, data: [String: Any]) throws -> Bool {
        let value: Any
        if let expression = args as? [String: Any] {
            value = try evaluateExpression(expression, data: data)
        } else if let array = args as? [Any], let first = array.first {
            value = try resolveValue(first, data: data)
        } else {
            value = try resolveValue(args, data: data)
        }
        return !truthy(value)
    }

    private func evaluateDoubleNegation(_ args: Any, data: [String: Any]) throws -> Bool {
        let value: Any
        if let expression = args as? [String: Any] {
            value = try evaluateExpression(expression, data: data)
        } else if let array = args as? [Any], let first = array.first {
            value = try resolveValue(first, data: data)
        } else {
            value = try resolveValue(args, data: data)
        }
        return truthy(value)
    }

    // MARK: - Arithmetic Operators

    private func evaluateAdd(_ args: Any, data: [String: Any]) throws -> Double {
        let values = try resolveArray(args, data: data)
        return try values.reduce(0.0) { sum, val in
            sum + (try toNumber(val))
        }
    }

    private func evaluateSubtract(_ args: Any, data: [String: Any]) throws -> Double {
        let values = try resolveArray(args, data: data)
        guard !values.isEmpty else { return 0.0 }

        // Unary negation
        if values.count == 1 {
            return -(try toNumber(values[0]))
        }

        // Binary subtraction
        let a = try toNumber(values[0])
        let b = try toNumber(values[1])
        return a - b
    }

    private func evaluateMultiply(_ args: Any, data: [String: Any]) throws -> Double {
        let values = try resolveArray(args, data: data)
        return try values.reduce(1.0) { product, val in
            product * (try toNumber(val))
        }
    }

    private func evaluateDivide(_ args: Any, data: [String: Any]) throws -> Double {
        let values = try resolveArray(args, data: data)
        guard values.count == 2 else {
            throw EvaluationError.invalidExpression
        }
        let a = try toNumber(values[0])
        let b = try toNumber(values[1])
        return a / b
    }

    private func evaluateModulo(_ args: Any, data: [String: Any]) throws -> Double {
        let values = try resolveArray(args, data: data)
        guard values.count == 2 else {
            throw EvaluationError.invalidExpression
        }
        let a = try toNumber(values[0])
        let b = try toNumber(values[1])
        return a.truncatingRemainder(dividingBy: b)
    }

    private func evaluateMin(_ args: Any, data: [String: Any]) throws -> Double {
        let values = try resolveArray(args, data: data)
        guard !values.isEmpty else {
            throw EvaluationError.invalidExpression
        }
        return try values.map { try toNumber($0) }.min() ?? 0.0
    }

    private func evaluateMax(_ args: Any, data: [String: Any]) throws -> Double {
        let values = try resolveArray(args, data: data)
        guard !values.isEmpty else {
            throw EvaluationError.invalidExpression
        }
        return try values.map { try toNumber($0) }.max() ?? 0.0
    }

    // MARK: - String/Array Operators

    private func evaluateIn(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let needle = try resolveValue(array[0], data: data)
        guard let haystack = try resolveValue(array[1], data: data) as? [Any] else {
            throw EvaluationError.typeMismatch
        }

        return haystack.contains { isEqual(needle, $0) }
    }

    private func evaluateSubStr(_ args: Any, data: [String: Any]) throws -> Any {
        guard let array = args as? [Any], array.count >= 2 else {
            throw EvaluationError.invalidExpression
        }

        let source = try resolveValue(array[0], data: data)
        let start = try resolveValue(array[1], data: data)

        let sourceStr = toString(source)
        guard let startInt = try? toNumber(start) else {
            throw EvaluationError.typeMismatch
        }

        let startIndex = Int(startInt)

        // 2-arg: substring or contains check
        if array.count == 2 {
            // If start is within bounds, treat as substring from start
            if startIndex < 0 {
                let actualStart = sourceStr.index(sourceStr.endIndex, offsetBy: startIndex, limitedBy: sourceStr.startIndex) ?? sourceStr.startIndex
                return String(sourceStr[actualStart...])
            } else {
                let actualStart = sourceStr.index(sourceStr.startIndex, offsetBy: startIndex, limitedBy: sourceStr.endIndex) ?? sourceStr.endIndex
                return String(sourceStr[actualStart...])
            }
        }

        // 3-arg: substring with length
        if array.count == 3 {
            let length = try resolveValue(array[2], data: data)
            guard let lengthInt = try? toNumber(length) else {
                throw EvaluationError.typeMismatch
            }

            let len = Int(lengthInt)

            let actualStart: String.Index
            if startIndex < 0 {
                actualStart = sourceStr.index(sourceStr.endIndex, offsetBy: startIndex, limitedBy: sourceStr.startIndex) ?? sourceStr.startIndex
            } else {
                actualStart = sourceStr.index(sourceStr.startIndex, offsetBy: startIndex, limitedBy: sourceStr.endIndex) ?? sourceStr.endIndex
            }

            // PHP-style negative length
            if len < 0 {
                let actualEnd = sourceStr.index(sourceStr.endIndex, offsetBy: len, limitedBy: actualStart) ?? actualStart
                return String(sourceStr[actualStart..<actualEnd])
            } else {
                let actualEnd = sourceStr.index(actualStart, offsetBy: len, limitedBy: sourceStr.endIndex) ?? sourceStr.endIndex
                return String(sourceStr[actualStart..<actualEnd])
            }
        }

        throw EvaluationError.invalidExpression
    }

    private func evaluateCat(_ args: Any, data: [String: Any]) throws -> String {
        let values = try resolveArray(args, data: data)
        return values.map { toString($0) }.joined()
    }

    private func evaluateMerge(_ args: Any, data: [String: Any]) throws -> [Any] {
        let values = try resolveArray(args, data: data)
        return values.flatMap { flattenArray($0) }
    }

    private func flattenArray(_ value: Any) -> [Any] {
        if let array = value as? [Any] {
            return array.flatMap { flattenArray($0) }
        }
        return [value]
    }

    private func evaluateVar(_ args: Any, data: [String: Any]) throws -> Any {
        // Handle default value
        var varKey: String
        var defaultValue: Any = NSNull()

        if let array = args as? [Any] {
            guard !array.isEmpty else { return data }
            varKey = toString(array[0])
            if array.count > 1 {
                defaultValue = try resolveValue(array[1], data: data)
            }
        } else {
            varKey = toString(args)
        }

        // Empty key returns entire data
        if varKey.isEmpty {
            return data
        }

        // Navigate nested keys
        let keyParts = varKey.split(separator: ".").map(String.init)
        var currentData: Any = data

        for key in keyParts {
            if let dict = currentData as? [String: Any] {
                currentData = dict[key] ?? NSNull()
            } else if let array = currentData as? [Any], let index = Int(key), index >= 0, index < array.count {
                currentData = array[index]
            } else {
                return defaultValue
            }

            if currentData is NSNull {
                return defaultValue
            }
        }

        return currentData
    }

    private func evaluateMissing(_ args: Any, data: [String: Any]) throws -> [String] {
        // Extract keys to check
        let keys: [String]
        if let array = args as? [Any] {
            // Handle nested array: {"missing": [["email", "phone"]]}
            if array.count == 1, let innerArray = array[0] as? [String] {
                keys = innerArray
            } else {
                keys = array.compactMap { $0 as? String }
            }
        } else if let str = args as? String {
            keys = [str]
        } else {
            return []
        }

        // Find missing keys
        var missing: [String] = []
        for key in keys {
            let varExpression: [String: Any] = ["var": key]
            let value = try evaluateExpression(varExpression, data: data)
            if value is NSNull || (value as? String)?.isEmpty == true {
                missing.append(key)
            }
        }
        return missing
    }

    private func evaluateMissingSome(_ args: Any, data: [String: Any]) throws -> [String] {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let minRequired: Int
        if let num = array[0] as? Int {
            minRequired = num
        } else if let num = try? toNumber(array[0]) {
            minRequired = Int(num)
        } else {
            throw EvaluationError.typeMismatch
        }

        guard let keys = array[1] as? [String] else {
            throw EvaluationError.invalidExpression
        }

        let missing = try evaluateMissing(keys, data: data)
        let foundCount = keys.count - missing.count

        return foundCount >= minRequired ? [] : missing
    }

    private func evaluateLog(_ args: Any, data: [String: Any]) throws -> Any {
        let value: Any
        if let expression = args as? [String: Any] {
            value = try evaluateExpression(expression, data: data)
        } else if let array = args as? [Any], let first = array.first {
            value = try resolveValue(first, data: data)
        } else {
            value = try resolveValue(args, data: data)
        }
        print("[JSONLogic log] \(value)")
        return value
    }

    // MARK: - Value Resolution

    private func resolveValue(_ value: Any, data: [String: Any]) throws -> Any {
        // If it's an expression (dictionary with single operator key), evaluate it
        if let dict = value as? [String: Any], dict.count == 1 {
            return try evaluateExpression(dict, data: data)
        }

        return value
    }

    // MARK: - Comparison Logic with Type Coercion & Version Support

    private func isGreaterThan(_ lhs: Any, _ rhs: Any) throws -> Bool {
        // String-to-string comparison (with version support)
        if let lhsStr = lhs as? String, let rhsStr = rhs as? String {
            // Try semantic version comparison first
            if isSemanticVersion(lhsStr) && isSemanticVersion(rhsStr),
               let lhsVer = parseVersion(lhsStr),
               let rhsVer = parseVersion(rhsStr) {
                Logger.debug(message: "Using semantic version comparison: '\(lhsStr)' vs '\(rhsStr)'")
                return compareVersions(lhsVer, rhsVer) == .orderedDescending
            }
            // Fall back to lexicographic comparison
            return lhsStr > rhsStr
        }

        // Numeric comparisons with type coercion
        let lhsNum = try toNumber(lhs)
        let rhsNum = try toNumber(rhs)
        return lhsNum > rhsNum
    }

    private func isLessThan(_ lhs: Any, _ rhs: Any) throws -> Bool {
        // String-to-string comparison (with version support)
        if let lhsStr = lhs as? String, let rhsStr = rhs as? String {
            // Try semantic version comparison first
            if isSemanticVersion(lhsStr) && isSemanticVersion(rhsStr),
               let lhsVer = parseVersion(lhsStr),
               let rhsVer = parseVersion(rhsStr) {
                Logger.debug(message: "Using semantic version comparison: '\(lhsStr)' vs '\(rhsStr)'")
                return compareVersions(lhsVer, rhsVer) == .orderedAscending
            }
            // Fall back to lexicographic comparison
            return lhsStr < rhsStr
        }

        // Numeric comparisons with type coercion
        let lhsNum = try toNumber(lhs)
        let rhsNum = try toNumber(rhs)
        return lhsNum < rhsNum
    }

    private func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        // NSNull handling
        if lhs is NSNull && rhs is NSNull {
            return true
        }
        if lhs is NSNull || rhs is NSNull {
            return false
        }

        // String comparison (with version normalization)
        if let lhsStr = lhs as? String, let rhsStr = rhs as? String {
            // Normalize version comparison
            if isSemanticVersion(lhsStr) && isSemanticVersion(rhsStr),
               let lhsVer = parseVersion(lhsStr),
               let rhsVer = parseVersion(rhsStr) {
                return compareVersions(lhsVer, rhsVer) == .orderedSame
            }
            return lhsStr == rhsStr
        }

        // Numeric comparison with type coercion
        if let lhsNum = lhs as? Double, let rhsNum = rhs as? Double {
            return lhsNum == rhsNum
        }
        if let lhsNum = lhs as? Int, let rhsNum = rhs as? Int {
            return lhsNum == rhsNum
        }
        if let lhsNum = lhs as? Double, let rhsNum = rhs as? Int {
            return lhsNum == Double(rhsNum)
        }
        if let lhsNum = lhs as? Int, let rhsNum = rhs as? Double {
            return Double(lhsNum) == rhsNum
        }

        // String-to-number coercion
        if let lhsStr = lhs as? String, let rhsNum = rhs as? Double {
            if let lhsAsNum = Double(lhsStr) {
                return lhsAsNum == rhsNum
            }
        }
        if let lhsNum = lhs as? Double, let rhsStr = rhs as? String {
            if let rhsAsNum = Double(rhsStr) {
                return lhsNum == rhsAsNum
            }
        }
        if let lhsStr = lhs as? String, let rhsNum = rhs as? Int {
            if let lhsAsNum = Double(lhsStr) {
                return lhsAsNum == Double(rhsNum)
            }
        }
        if let lhsNum = lhs as? Int, let rhsStr = rhs as? String {
            if let rhsAsNum = Double(rhsStr) {
                return Double(lhsNum) == rhsAsNum
            }
        }

        // Bool comparison
        if let lhsBool = lhs as? Bool, let rhsBool = rhs as? Bool {
            return lhsBool == rhsBool
        }

        return false
    }

    // MARK: - Semantic Version Support

    /// Check if string matches semantic version format (x.y or x.y.z)
    private func isSemanticVersion(_ string: String) -> Bool {
        let pattern = "^\\d+\\.\\d+(\\.\\d+)?$"
        return string.range(of: pattern, options: .regularExpression) != nil
    }

    /// Parse version string into [major, minor, patch]
    private func parseVersion(_ string: String) -> [Int]? {
        let components = string.split(separator: ".").compactMap { Int($0) }
        guard components.count >= 2 && components.count <= 3 else {
            return nil
        }

        // Normalize to 3 components
        if components.count == 2 {
            return [components[0], components[1], 0]
        }
        return components
    }

    /// Compare version arrays semantically
    private func compareVersions(_ lhs: [Int], _ rhs: [Int]) -> ComparisonResult {
        for i in 0..<max(lhs.count, rhs.count) {
            let lhsVal = i < lhs.count ? lhs[i] : 0
            let rhsVal = i < rhs.count ? rhs[i] : 0

            if lhsVal < rhsVal {
                return .orderedAscending
            } else if lhsVal > rhsVal {
                return .orderedDescending
            }
        }
        return .orderedSame
    }

    // MARK: - Type Coercion

    private func toNumber(_ value: Any) throws -> Double {
        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else if let str = value as? String, let num = Double(str) {
            return num
        } else if let bool = value as? Bool {
            return bool ? 1.0 : 0.0
        } else if value is NSNull {
            return 0.0
        } else {
            Logger.error(message: "Type mismatch: cannot convert '\(value)' (type: \(type(of: value))) to number")
            throw EvaluationError.typeMismatch
        }
    }

    private func toString(_ value: Any) -> String {
        if let str = value as? String {
            return str
        } else if let num = value as? Double {
            return String(num)
        } else if let num = value as? Int {
            return String(num)
        } else if let bool = value as? Bool {
            return bool ? "true" : "false"
        } else if value is NSNull {
            return ""
        } else if let array = value as? [Any] {
            return array.map { toString($0) }.joined(separator: ",")
        } else {
            return "\(value)"
        }
    }

    private func truthy(_ value: Any) -> Bool {
        if let bool = value as? Bool {
            return bool
        } else if let num = value as? Double {
            return num != 0.0
        } else if let num = value as? Int {
            return num != 0
        } else if let str = value as? String {
            return !str.isEmpty
        } else if let array = value as? [Any] {
            return !array.isEmpty
        } else if let dict = value as? [String: Any] {
            return !dict.isEmpty
        } else if value is NSNull {
            return false
        } else {
            return true
        }
    }

    private func isStrictEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        // Strict equality: same type and same value
        if lhs is NSNull && rhs is NSNull {
            return true
        }
        if type(of: lhs) != type(of: rhs) {
            return false
        }

        if let lhsStr = lhs as? String, let rhsStr = rhs as? String {
            return lhsStr == rhsStr
        }
        if let lhsNum = lhs as? Double, let rhsNum = rhs as? Double {
            return lhsNum == rhsNum
        }
        if let lhsNum = lhs as? Int, let rhsNum = rhs as? Int {
            return lhsNum == rhsNum
        }
        if let lhsBool = lhs as? Bool, let rhsBool = rhs as? Bool {
            return lhsBool == rhsBool
        }

        return false
    }

    private func resolveArray(_ args: Any, data: [String: Any]) throws -> [Any] {
        if let array = args as? [Any] {
            return try array.map { try resolveValue($0, data: data) }
        } else {
            return [try resolveValue(args, data: data)]
        }
    }
}
