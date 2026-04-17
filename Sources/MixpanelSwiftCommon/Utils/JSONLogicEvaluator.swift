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

    public enum EvaluationError: Error, LocalizedError {
        case invalidExpression(expression: String, reason: String)
        case unsupportedOperator(String)
        case typeMismatch(operator: String, reason: String)

        public var errorDescription: String? {
            switch self {
            case .invalidExpression(let expression, let reason):
                return "Invalid expression '\(expression)': \(reason). Try updating to a newer SDK version for possible expression support."
            case .unsupportedOperator(let op):
                return "Unsupported operator '\(op)'. Try updating to a newer SDK version for possible operator support."
            case .typeMismatch(let op, let reason):
                return "Type mismatch in '\(op)': \(reason). Try updating to a newer SDK version for possible type support."
            }
        }
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
            throw EvaluationError.invalidExpression(
                expression: "\(expression)",
                reason: "expression must contain exactly one operator"
            )
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
            throw EvaluationError.invalidExpression(
                expression: "===",
                reason: "requires exactly 2 arguments"
            )
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isStrictEqual(left, right)
    }

    private func evaluateGreaterThan(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression(
                expression: ">",
                reason: "requires exactly 2 arguments"
            )
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isGreaterThan(left, right)
    }

    private func evaluateGreaterOrEqual(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression(
                expression: ">=",
                reason: "requires exactly 2 arguments"
            )
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isGreaterThan(left, right) || (try isStrictEqual(left, right))
    }

    private func evaluateLessThan(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression(
                expression: "<",
                reason: "requires exactly 2 arguments"
            )
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isLessThan(left, right)
    }

    private func evaluateLessOrEqual(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression(
                expression: "<=",
                reason: "requires exactly 2 arguments"
            )
        }

        let left = try resolveValue(array[0], data: data)
        let right = try resolveValue(array[1], data: data)

        return try isLessThan(left, right) || (try isStrictEqual(left, right))
    }

    // MARK: - Logical Operators

    private func evaluateAnd(_ args: Any, data: [String: Any]) throws -> Bool {
        // All operands must be boolean expressions
        guard let values = args as? [Any] else {
            throw EvaluationError.invalidExpression(
                expression: "and",
                reason: "arguments must be an array"
            )
        }

        // 'and' requires at least 1 argument per jsonlogic.com
        if values.isEmpty {
            throw EvaluationError.invalidExpression(
                expression: "and",
                reason: "requires at least 1 argument"
            )
        }

        for value in values {
            let resolved = try resolveValue(value, data: data)
            // Only boolean values are allowed
            guard let boolValue = resolved as? Bool else {
                throw EvaluationError.typeMismatch(
                    operator: "and",
                    reason: "all operands must be boolean expressions"
                )
            }
            if !boolValue {
                return false
            }
        }
        return true
    }

    private func evaluateOr(_ args: Any, data: [String: Any]) throws -> Bool {
        // All operands must be boolean expressions
        guard let values = args as? [Any] else {
            throw EvaluationError.invalidExpression(
                expression: "or",
                reason: "arguments must be an array"
            )
        }

        // 'or' requires at least 1 argument per jsonlogic.com
        if values.isEmpty {
            throw EvaluationError.invalidExpression(
                expression: "or",
                reason: "requires at least 1 argument"
            )
        }

        for value in values {
            let resolved = try resolveValue(value, data: data)
            // Only boolean values are allowed
            guard let boolValue = resolved as? Bool else {
                throw EvaluationError.typeMismatch(
                    operator: "or",
                    reason: "all operands must be boolean expressions"
                )
            }
            if boolValue {
                return true
            }
        }
        return false
    }

    // MARK: - String/Array Operators

    private func evaluateIn(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression(
                expression: "in",
                reason: "requires exactly 2 arguments"
            )
        }

        let needle = try resolveValue(array[0], data: data)
        let haystack = try resolveValue(array[1], data: data)

        // Only strings support the 'in' operator
        guard let needleStr = needle as? String else {
            throw EvaluationError.typeMismatch(
                operator: "in",
                reason: "requires a string needle"
            )
        }

        // Check if haystack is an array (array membership)
        if let haystackArray = haystack as? [Any] {
            // All elements must be strings - validate all elements even after finding a match
            // Example: {"in": ["a", ["a", 1]]} throws because element 1 is not a string
            var foundMatch = false
            for element in haystackArray {
                // Validate element is a string
                guard element is String else {
                    throw EvaluationError.typeMismatch(
                        operator: "in",
                        reason: "all array elements must be strings"
                    )
                }
                // Check for match using strict equality
                if try isStrictEqual(needleStr, element) {
                    foundMatch = true
                }
            }
            return foundMatch
        }

        // Check if haystack is a string (substring check)
        if let haystackStr = haystack as? String {
            return haystackStr.contains(needleStr)
        }

        throw EvaluationError.typeMismatch(
            operator: "in",
            reason: "haystack must be a string or array"
        )
    }

    private func evaluateVar(_ args: Any, data: Any) throws -> Any {
        // No array index access or default values support (per Android alignment)
        var varKey: String?

        if let array = args as? [Any] {
            guard !array.isEmpty else { return data }

            // Default values not supported
            if array.count > 1 {
                throw EvaluationError.invalidExpression(
                    expression: "var",
                    reason: "default values are not supported"
                )
            }

            // First element is the key (can be an expression that evaluates to a string)
            let dictData = (data as? [String: Any]) ?? [:]
            let keyValue = try resolveValue(array[0], data: dictData)

            if keyValue is NSNull {
                varKey = nil  // null key means return whole data
            } else {
                varKey = toString(keyValue)
            }
        } else if args is NSNull {
            varKey = nil  // null arg means return whole data
        } else if let expr = args as? [String: Any] {
            // Args can be an expression
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

        // Empty string key returns entire data
        if key.isEmpty {
            return data
        }

        // Reject nested property access (dot notation not supported)
        if key.contains(".") {
            throw EvaluationError.invalidExpression(
                expression: "var",
                reason: "nested property access is not supported"
            )
        }

        // Reject numeric keys (array index access not supported)
        if Int(key) != nil {
            throw EvaluationError.invalidExpression(
                expression: "var",
                reason: "array index access is not supported"
            )
        }

        // Simple property lookup (no nesting)
        if let dict = data as? [String: Any] {
            return dict[key] ?? NSNull()
        } else {
            return NSNull()
        }
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
        // Only numbers are allowed in numeric comparisons
        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else {
            // null, arrays, objects, etc. are not valid for numeric comparisons
            throw EvaluationError.typeMismatch(
                operator: ">, <, >=, <=",
                reason: "only support numbers"
            )
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

    private func isStrictEqual(_ lhs: Any, _ rhs: Any) throws -> Bool {
        // null can only compare with null
        if lhs is NSNull && rhs is NSNull {
            return true
        }
        if lhs is NSNull || rhs is NSNull {
            throw EvaluationError.typeMismatch(
                operator: "===, !==",
                reason: "operands must be the same type"
            )
        }

        // Array comparison is not supported - throw exception
        if lhs is [Any] || rhs is [Any] {
            throw EvaluationError.typeMismatch(
                operator: "===, !==",
                reason: "array comparison is not supported"
            )
        }

        // Use CF type ID to distinguish Bool from numeric NSNumber
        // (NSNumber bridges Bool to Int/Double, making `as?` checks unreliable)
        let lhsIsBool = isBoolValue(lhs)
        let rhsIsBool = isBoolValue(rhs)

        // Bool vs non-Bool: throw error (different types)
        if lhsIsBool != rhsIsBool {
            throw EvaluationError.typeMismatch(
                operator: "===, !==",
                reason: "operands must be the same type"
            )
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

        // Different types (string vs number, etc.) - throw error
        throw EvaluationError.typeMismatch(
            operator: "===, !==",
            reason: "operands must be the same type"
        )
    }
}
