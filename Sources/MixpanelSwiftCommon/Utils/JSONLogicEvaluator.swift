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
/// - **Control Flow**: `if`, `?:`
/// - **Arithmetic**: `+`, `-`, `*`, `/`, `%`, `min`, `max`
/// - **String**: `cat`, `substr`, `in`
/// - **Array**: `map`, `filter`, `reduce`, `all`, `some`, `none`, `merge`, `missing`, `missing_some`
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
            return try evaluateVar(args, data: actualContext)
        case "missing":
            return try evaluateMissing(args, data: data)
        case "missing_some":
            return try evaluateMissingSome(args, data: data)
        case "log":
            return try evaluateLog(args, data: data)
        case "if":
            return try evaluateIf(args, data: data)
        case "?:":
            return try evaluateTernary(args, data: data)
        case "map":
            return try evaluateMap(args, data: data)
        case "filter":
            return try evaluateFilter(args, data: data)
        case "reduce":
            return try evaluateReduce(args, data: data)
        case "all":
            return try evaluateAll(args, data: data)
        case "some":
            return try evaluateSome(args, data: data)
        case "none":
            return try evaluateNone(args, data: data)
        default:
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
        // Match Android behavior: modulo by zero returns 0
        if b == 0.0 {
            return 0.0
        }
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
        let haystack = try resolveValue(array[1], data: data)

        // Check if haystack is an array
        if let haystackArray = haystack as? [Any] {
            return haystackArray.contains { isEqual(needle, $0) }
        }

        // Check if both are strings (substring check)
        if let needleStr = needle as? String, let haystackStr = haystack as? String {
            return haystackStr.contains(needleStr)
        }

        throw EvaluationError.typeMismatch
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

    private func evaluateMissing(_ args: Any, data: [String: Any]) throws -> [String] {
        // If args is an expression, evaluate it first
        let resolvedArgs: Any
        if let expr = args as? [String: Any] {
            resolvedArgs = try evaluateExpression(expr, data: data)
        } else {
            resolvedArgs = args
        }

        // Extract keys to check
        let keys: [String]
        if let array = resolvedArgs as? [Any] {
            // Handle nested array: {"missing": [["email", "phone"]]}
            if array.count == 1, let innerArray = array[0] as? [String] {
                keys = innerArray
            } else {
                keys = array.compactMap { $0 as? String }
            }
        } else if let str = resolvedArgs as? String {
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

        let keys: [String]
        if let stringKeys = array[1] as? [String] {
            keys = stringKeys
        } else if let anyKeys = array[1] as? [Any] {
            keys = anyKeys.compactMap { $0 as? String }
        } else if let key = array[1] as? String {
            keys = [key]
        } else {
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

    // MARK: - Control Flow Operators

    private func evaluateIf(_ args: Any, data: [String: Any]) throws -> Any {
        guard let array = args as? [Any] else {
            // If not an array, just evaluate and return it
            return try resolveValue(args, data: data)
        }

        // Empty array returns null
        if array.isEmpty {
            return NSNull()
        }

        // Single element: return evaluated element
        if array.count == 1 {
            return try resolveValue(array[0], data: data)
        }

        // If-then or if-then-else or chained if-elseif-else
        // Pattern: [cond1, val1, cond2, val2, ..., defaultVal]
        var i = 0
        while i < array.count {
            if i == array.count - 1 {
                // Last element is the default value (no condition)
                return try resolveValue(array[i], data: data)
            }

            // Evaluate condition
            let condition = try resolveValue(array[i], data: data)
            if truthy(condition) {
                // Return the corresponding value
                if i + 1 < array.count {
                    return try resolveValue(array[i + 1], data: data)
                }
                return condition
            }

            // Move to next condition-value pair
            i += 2
        }

        // All conditions false and no default
        return NSNull()
    }

    private func evaluateTernary(_ args: Any, data: [String: Any]) throws -> Any {
        guard let array = args as? [Any], array.count == 3 else {
            throw EvaluationError.invalidExpression
        }

        let condition = try resolveValue(array[0], data: data)
        if truthy(condition) {
            return try resolveValue(array[1], data: data)
        } else {
            return try resolveValue(array[2], data: data)
        }
    }

    // MARK: - Array Operators

    private func evaluateMap(_ args: Any, data: [String: Any]) throws -> [Any] {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let sourceArray = try resolveValue(array[0], data: data)

        // Handle null or missing data - return empty array
        if sourceArray is NSNull {
            return []
        }

        guard let items = sourceArray as? [Any] else {
            throw EvaluationError.typeMismatch
        }

        let operation = array[1]

        return try items.map { element in
            // Create context where element is accessible
            // For objects: both {"var": ""} and {"var": "property"} work
            // For primitives: {"var": ""} returns the element
            let contextData: [String: Any]
            if let elementDict = element as? [String: Any] {
                // Element is an object - merge it with empty string key
                var merged = elementDict
                merged[""] = element
                contextData = merged
            } else {
                // Element is a primitive - only accessible via ""
                contextData = ["": element]
            }
            return try resolveValue(operation, data: contextData)
        }
    }

    private func evaluateFilter(_ args: Any, data: [String: Any]) throws -> [Any] {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let sourceArray = try resolveValue(array[0], data: data)

        // Handle null or missing data - return empty array
        if sourceArray is NSNull {
            return []
        }

        guard let items = sourceArray as? [Any] else {
            throw EvaluationError.typeMismatch
        }

        let predicate = array[1]

        return try items.filter { element in
            // Create context where element is accessible
            let contextData: [String: Any]
            if let elementDict = element as? [String: Any] {
                var merged = elementDict
                merged[""] = element
                contextData = merged
            } else {
                contextData = ["": element]
            }
            let result = try resolveValue(predicate, data: contextData)
            return truthy(result)
        }
    }

    private func evaluateReduce(_ args: Any, data: [String: Any]) throws -> Any {
        guard let array = args as? [Any], array.count >= 2 && array.count <= 3 else {
            throw EvaluationError.invalidExpression
        }

        let sourceArray = try resolveValue(array[0], data: data)

        // Handle null or missing data
        if sourceArray is NSNull {
            let hasInitial = array.count == 3
            if hasInitial {
                return try resolveValue(array[2], data: data)
            }
            return NSNull()
        }

        guard let items = sourceArray as? [Any] else {
            throw EvaluationError.typeMismatch
        }

        let operation = array[1]
        let hasInitial = array.count == 3

        // Handle empty array
        if items.isEmpty {
            if hasInitial {
                return try resolveValue(array[2], data: data)
            }
            return NSNull()
        }

        // Initialize accumulator
        var accumulator: Any
        var startIndex = 0

        if hasInitial {
            accumulator = try resolveValue(array[2], data: data)
        } else {
            // No initial value: use first element
            accumulator = items[0]
            startIndex = 1
        }

        // Reduce remaining elements
        for i in startIndex..<items.count {
            var contextData = data
            contextData["current"] = items[i]
            contextData["accumulator"] = accumulator
            accumulator = try resolveValue(operation, data: contextData)
        }

        return accumulator
    }

    private func evaluateAll(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let sourceArray = try resolveValue(array[0], data: data)

        // Handle null or missing data - all returns true for empty/null
        if sourceArray is NSNull {
            return true
        }

        guard let items = sourceArray as? [Any] else {
            throw EvaluationError.typeMismatch
        }

        // Empty array: all returns false (per JSONLogic spec)
        if items.isEmpty {
            return false
        }

        let predicate = array[1]

        for element in items {
            // Create context where element is accessible
            let contextData: [String: Any]
            if let elementDict = element as? [String: Any] {
                var merged = elementDict
                merged[""] = element
                contextData = merged
            } else {
                contextData = ["": element]
            }
            let result = try resolveValue(predicate, data: contextData)
            if !truthy(result) {
                return false
            }
        }

        return true
    }

    private func evaluateSome(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let sourceArray = try resolveValue(array[0], data: data)

        // Handle null or missing data - some returns false for empty/null
        if sourceArray is NSNull {
            return false
        }

        guard let items = sourceArray as? [Any] else {
            throw EvaluationError.typeMismatch
        }

        // Empty array: some returns false
        if items.isEmpty {
            return false
        }

        let predicate = array[1]

        for element in items {
            // Create context where element is accessible
            let contextData: [String: Any]
            if let elementDict = element as? [String: Any] {
                var merged = elementDict
                merged[""] = element
                contextData = merged
            } else {
                contextData = ["": element]
            }
            let result = try resolveValue(predicate, data: contextData)
            if truthy(result) {
                return true
            }
        }

        return false
    }

    private func evaluateNone(_ args: Any, data: [String: Any]) throws -> Bool {
        guard let array = args as? [Any], array.count == 2 else {
            throw EvaluationError.invalidExpression
        }

        let sourceArray = try resolveValue(array[0], data: data)

        // Handle null or missing data - none returns true for empty/null
        if sourceArray is NSNull {
            return true
        }

        guard let items = sourceArray as? [Any] else {
            throw EvaluationError.typeMismatch
        }

        // Empty array: none returns true
        if items.isEmpty {
            return true
        }

        let predicate = array[1]

        for element in items {
            // Create context where element is accessible
            let contextData: [String: Any]
            if let elementDict = element as? [String: Any] {
                var merged = elementDict
                merged[""] = element
                contextData = merged
            } else {
                contextData = ["": element]
            }
            let result = try resolveValue(predicate, data: contextData)
            if truthy(result) {
                return false
            }
        }

        return true
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

    // MARK: - Comparison Logic with Type Coercion & Version Support

    private func isGreaterThan(_ lhs: Any, _ rhs: Any) throws -> Bool {
        // String-to-string comparison (with version support)
        if let lhsStr = lhs as? String, let rhsStr = rhs as? String {
            // Try semantic version comparison first
            if isSemanticVersion(lhsStr) && isSemanticVersion(rhsStr),
               let lhsVer = parseVersion(lhsStr),
               let rhsVer = parseVersion(rhsStr) {
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

        // Bool handling: if either side is a Bool, coerce to number and compare
        // (JavaScript semantics: true == 1, false == 0)
        // Must check before numeric types due to NSNumber bridging
        let lhsIsBool = isBoolValue(lhs)
        let rhsIsBool = isBoolValue(rhs)
        if lhsIsBool || rhsIsBool {
            let lhsNum: Double
            if lhsIsBool, let lhsBool = lhs as? Bool {
                lhsNum = lhsBool ? 1.0 : 0.0
            } else {
                lhsNum = (try? toNumber(lhs)) ?? Double.nan
            }

            let rhsNum: Double
            if rhsIsBool, let rhsBool = rhs as? Bool {
                rhsNum = rhsBool ? 1.0 : 0.0
            } else {
                rhsNum = (try? toNumber(rhs)) ?? Double.nan
            }
            return lhsNum == rhsNum
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

    // MARK: - Type Detection

    /// Determines whether a value is a true Boolean (from JSON `true`/`false`)
    /// versus a numeric NSNumber that happens to bridge to Bool.
    ///
    /// NSNumber bridges all numeric values to Bool via `as? Bool`,
    /// making `1 as? Bool == true` and `true as? Int == 1`.
    /// CoreFoundation's type ID is the only reliable way to distinguish them.
    private func isBoolValue(_ value: Any) -> Bool {
        return CFGetTypeID(value as CFTypeRef) == CFBooleanGetTypeID()
    }

    // MARK: - Type Coercion

    private func toNumber(_ value: Any) throws -> Double {
        // Check Bool first using CF type ID, before numeric checks
        // (NSNumber bridges Bool to Int/Double, so `as? Double` would match bools)
        if isBoolValue(value), let boolVal = value as? Bool {
            return boolVal ? 1.0 : 0.0
        }
        if let num = value as? Double {
            return num
        } else if let num = value as? Int {
            return Double(num)
        } else if let str = value as? String, let num = Double(str) {
            return num
        } else if value is NSNull {
            return 0.0
        } else {
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

    private func resolveArray(_ args: Any, data: [String: Any]) throws -> [Any] {
        if let array = args as? [Any] {
            return try array.map { try resolveValue($0, data: data) }
        } else {
            return [try resolveValue(args, data: data)]
        }
    }
}
