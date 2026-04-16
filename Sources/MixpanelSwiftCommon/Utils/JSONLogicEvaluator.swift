//
//  JSONLogicEvaluator.swift
//  MixpanelSwiftCommon
//
//  Created by Mixpanel on 2026-03-03.
//  Copyright © 2026 Mixpanel. All rights reserved.
//
//  JSONLogic essential subset evaluator
//  Based on: http://jsonlogic.com/

import Foundation

/// A JSONLogic expression evaluator with support for essential comparison and logical operators.
///
/// ## Supported Operators (10 total)
/// - **Strict Equality**: `===` (is), `!==` (is not) - all types
/// - **Comparison**: `>`, `>=`, `<`, `<=` - numbers only
/// - **Logical**: `and`, `or` - all types
/// - **String/Array**: `in` (array membership and substring check) - strings only
/// - **Data**: `var` (variable resolution)
///
/// ## Type Restrictions
/// - **String**: `===`, `!==`, `in`
/// - **Boolean**: `===`, `!==`
/// - **Number**: `===`, `!==`, `<`, `<=`, `>`, `>=`
///
/// ## Examples
/// ```swift
/// // Strict equality (no type coercion)
/// {"===": [5, 5]}  // true
/// {"===": [5, "5"]}  // false (different types)
///
/// // Comparison (numbers only)
/// {">": [10, 5]}  // true
/// {"<=": [5, 10]}  // true
/// {">": ["b", "a"]}  // ERROR: strings not supported
///
/// // Array membership (strings only)
/// {"in": [{"var": "$city"}, ["Louisville", "Miami"]]}  // true if $city is in array
/// {"in": [5, [1, 2, 3]]}  // ERROR: numbers not supported
///
/// // Substring check (strings only)
/// {"in": ["Louisville", {"var": "$address"}]}  // true if "Louisville" is substring of $address
///
/// // Logical operators
/// {"and": [{"===": [{"var": "age"}, 25]}, {">": [{"var": "score"}, 80]}]}
/// ```
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

    /// Evaluate any value (including arrays with expressions)
    /// This handles primitives, expressions, and arrays containing expressions
    /// Data can be a dictionary, array, or primitive value
    public func evaluateAny(
        _ value: Any,
        data: Any
    ) throws -> Any {
        // If it's a dictionary (expression), evaluate it
        if let expression = value as? [String: Any] {
            // Convert to dict data or use empty dict
            let dictData = (data as? [String: Any]) ?? [:]
            return try evaluateExpression(expression, data: dictData, contextData: data)
        }

        // If it's an array, evaluate any expressions inside
        if let array = value as? [Any] {
            return try array.map { element in
                try evaluateAny(element, data: data)
            }
        }

        // Otherwise, return the value as-is
        return value
    }

    /// Evaluate a JSONLogic expression (returns Any)
    /// - Parameters:
    ///   - expression: The JSONLogic expression dictionary
    ///   - data: Dictionary data for normal operations
    ///   - contextData: Original data (can be dict, array, or primitive) for var operations
    private func evaluateExpression(
        _ expression: [String: Any],
        data: [String: Any],
        contextData: Any? = nil
    ) throws -> Any {
        // Use contextData if provided, otherwise use data
        let actualContext = contextData ?? data

        guard expression.count == 1,
              let (`operator`, args) = expression.first else {
            throw EvaluationError.invalidExpression
        }

        switch `operator` {
        case "===":
            return try evaluateEquals(args, data: data)
        case "!==":
            return try !evaluateEquals(args, data: data)
        case "and":
            return try evaluateAnd(args, data: data)
        case "or":
            return try evaluateOr(args, data: data)
        case ">":
            return try evaluateGreaterThan(args, data: data)
        case ">=":
            return try evaluateGreaterOrEqual(args, data: data)
        case "<":
            return try evaluateLessThan(args, data: data)
        case "<=":
            return try evaluateLessOrEqual(args, data: data)
        case "in":
            return try evaluateIn(args, data: data)
        case "var":
            return try evaluateVar(args, data: actualContext)
        default:
            throw EvaluationError.unsupportedOperator(`operator`)
        }
    }

    // MARK: - Comparison Operators

    private func evaluateEquals(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return isStrictEqual(left, right)
    }

    private func evaluateGreaterThan(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isGreaterThan(left, right)
    }

    private func evaluateGreaterOrEqual(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isGreaterThan(left, right) || isStrictEqual(left, right)
    }

    private func evaluateLessThan(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isLessThan(left, right)
    }

    private func evaluateLessOrEqual(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isLessThan(left, right) || isStrictEqual(left, right)
    }

    // MARK: - Logical Operators

    private func evaluateAnd(_ args: Any, data: [String: Any]) throws -> Any {
        // And returns the first falsy value, or the last value if all are truthy
        guard let values = args as? [Any] else {
            throw EvaluationError.invalidExpression
        }

        if values.isEmpty {
            return NSNull()
        }

        var lastValue: Any = NSNull()
        for value in values {
            let resolved = try resolveValue(value, data: data)
            if !truthy(resolved) {
                return resolved
            }
            lastValue = resolved
        }
        return lastValue
    }

    private func evaluateOr(_ args: Any, data: [String: Any]) throws -> Any {
        // Or returns the first truthy value, or the last value if all are falsy
        guard let values = args as? [Any] else {
            throw EvaluationError.invalidExpression
        }

        if values.isEmpty {
            return NSNull()
        }

        var lastValue: Any = NSNull()
        for value in values {
            let resolved = try resolveValue(value, data: data)
            if truthy(resolved) {
                return resolved
            }
            lastValue = resolved
        }
        return lastValue
    }

    // MARK: - String/Array Operators

    private func evaluateIn(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let needle = try resolveValue(array[0], data: data)
        let haystack = try resolveValue(array[1], data: data)

        // Only strings support the 'in' operator
        guard let needleStr = needle as? String else {
            throw EvaluationError.typeMismatch
        }

        // Check if haystack is an array (array membership)
        if let haystackArray = haystack as? [Any] {
            return haystackArray.contains { isStrictEqual(needleStr, $0) }
        }

        // Check if haystack is a string (substring check)
        if let haystackStr = haystack as? String {
            return haystackStr.contains(needleStr)
        }

        throw EvaluationError.typeMismatch
    }

    private func evaluateVar(_ args: Any, data: Any) throws -> Any {
        // Handle default value
        var varKey: String?
        var defaultValue: Any = NSNull()

        if let array = args as? [Any] {
            guard !array.isEmpty else { return data }
            // First element is the key (can be an expression that evaluates to a string)
            let dictData = (data as? [String: Any]) ?? [:]
            let keyValue = try resolveValue(array[0], data: dictData)

            if keyValue is NSNull {
                varKey = nil  // null key means return whole data
            } else {
                varKey = toString(keyValue)
            }
            // Second element (if present) is the default value
            if array.count > 1 {
                defaultValue = try resolveValue(array[1], data: dictData)
            }
        } else if args is NSNull {
            varKey = nil  // null arg means return whole data
        } else if let expr = args as? [String: Any] {
            // Args can be an expression (e.g., {"?:": [...]})
            let dictData = (data as? [String: Any]) ?? [:]
            let keyValue = try evaluateExpression(expr, data: dictData, contextData: data)
            varKey = toString(keyValue)
        } else {
            varKey = toString(args)
        }

        // Null key returns entire data
        if varKey == nil {
            return data
        }

        guard let key = varKey else {
            return data
        }

        // Empty string key is a special case in JSONLogic - it accesses the current element
        // This is used in array operations like map, filter, etc.
        if key.isEmpty {
            // Look up "" in the data if it's a dict, otherwise return the data itself
            if let dict = data as? [String: Any] {
                return dict[""] ?? defaultValue
            } else {
                return data
            }
        }

        // Navigate nested keys
        let keyParts = key.split(separator: ".").map(String.init)
        var currentData: Any = data

        for keyPart in keyParts {
            if let dict = currentData as? [String: Any] {
                currentData = dict[keyPart] ?? NSNull()
            } else if let array = currentData as? [Any], let index = Int(keyPart), index >= 0, index < array.count {
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

    // MARK: - Value Resolution

    private func resolveValue(_ value: Any, data: [String: Any]) throws -> Any {
        // If it's an expression (dictionary with single operator key), evaluate it
        if let dict = value as? [String: Any], dict.count == 1 {
            return try evaluateExpression(dict, data: data)
        }

        // If it's an array, evaluate any expressions inside
        if let array = value as? [Any] {
            return try array.map { try resolveValue($0, data: data) }
        }

        return value
    }

    // MARK: - Comparison Logic with Type Coercion

    private func isGreaterThan(_ lhs: Any, _ rhs: Any) throws -> Bool {
        // Only numbers support comparison operators
        let lhsNum = try toNumber(lhs)
        let rhsNum = try toNumber(rhs)
        return lhsNum > rhsNum
    }

    private func isLessThan(_ lhs: Any, _ rhs: Any) throws -> Bool {
        // Only numbers support comparison operators
        let lhsNum = try toNumber(lhs)
        let rhsNum = try toNumber(rhs)
        return lhsNum < rhsNum
    }

    // MARK: - Type Detection

    /// Determines whether a value is a true Boolean (from JSON `true`/`false`)
    /// versus a numeric NSNumber that happens to bridge to Bool.
    ///
    /// NSNumber bridges all numeric values to Bool via `as? Bool`,
    /// making `1 as? Bool == true` and `true as? Int == 1`.
    /// CoreFoundation's type ID is the only reliable way to distinguish them.
    /// Only apply the CF type check to values that bridge to NSNumber;
    /// non-Foundation Swift values are not guaranteed to be CFTypeRef-backed.
    private func isBoolValue(_ value: Any) -> Bool {
        guard let number = value as? NSNumber else {
            return false
        }
        return CFGetTypeID(number) == CFBooleanGetTypeID()
    }

    // MARK: - Type Coercion

    private func toNumber(_ value: Any) throws -> Double {
        // Only numbers are allowed in numeric comparisons (no booleans or strings)
        if isBoolValue(value) {
            throw EvaluationError.typeMismatch
        }
        if value is String {
            throw EvaluationError.typeMismatch
        }
        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else {
            // null, arrays, objects, etc. are not valid for numeric comparisons
            throw EvaluationError.typeMismatch
        }
    }

    private func toString(_ value: Any) -> String {
        if let str = value as? String {
            return str
        }
        // Check Bool before numeric types to avoid NSNumber bridging confusion
        // (without this, `true` matches `as? Double` and returns "1" instead of "true")
        if isBoolValue(value), let boolVal = value as? Bool {
            return boolVal ? "true" : "false"
        }
        if let num = value as? Double {
            // If it's a whole number, format without decimal
            if num.truncatingRemainder(dividingBy: 1) == 0 && !num.isNaN && !num.isInfinite {
                return String(Int(num))
            }
            return String(num)
        } else if let num = value as? Int {
            return String(num)
        } else if value is NSNull {
            return ""
        } else if let array = value as? [Any] {
            return array.map { toString($0) }.joined(separator: ",")
        } else {
            return "\(value)"
        }
    }

    private func truthy(_ value: Any) -> Bool {
        // Check Bool first using CF type ID to avoid NSNumber bridging confusion
        if isBoolValue(value), let boolVal = value as? Bool {
            return boolVal
        }
        if let num = value as? Double {
            return !num.isNaN && num != 0.0
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

        // Array comparison: deep equality (element-by-element)
        // Swift arrays are value types, so we compare contents recursively
        if let lhsArray = lhs as? [Any], let rhsArray = rhs as? [Any] {
            guard lhsArray.count == rhsArray.count else { return false }
            for (lhsElem, rhsElem) in zip(lhsArray, rhsArray) {
                if !isStrictEqual(lhsElem, rhsElem) {
                    return false
                }
            }
            return true
        }

        // Use CF type ID to distinguish Bool from numeric NSNumber
        // (NSNumber bridges Bool to Int/Double, making `as?` checks unreliable)
        let lhsIsBool = isBoolValue(lhs)
        let rhsIsBool = isBoolValue(rhs)

        // Bool vs non-Bool: always different types in strict equality
        if lhsIsBool != rhsIsBool {
            return false
        }

        // Both are booleans
        if lhsIsBool && rhsIsBool {
            guard let lhsBool = lhs as? Bool, let rhsBool = rhs as? Bool else {
                return false
            }
            return lhsBool == rhsBool
        }

        // String comparison
        if let lhsStr = lhs as? String, let rhsStr = rhs as? String {
            return lhsStr == rhsStr
        }

        // Numeric comparison (Int and Double are both numbers in JSONLogic)
        if let lhsNum = lhs as? Double, let rhsNum = rhs as? Double {
            return lhsNum == rhsNum
        }
        if let lhsNum = lhs as? Int, let rhsNum = rhs as? Int {
            return lhsNum == rhsNum
        }
        // Int and Double should be equal if values match (both are numbers)
        if let lhsInt = lhs as? Int, let rhsDouble = rhs as? Double {
            return Double(lhsInt) == rhsDouble
        }
        if let lhsDouble = lhs as? Double, let rhsInt = rhs as? Int {
            return lhsDouble == Double(rhsInt)
        }

        // Different types (string vs number, etc.)
        return false
    }
}
