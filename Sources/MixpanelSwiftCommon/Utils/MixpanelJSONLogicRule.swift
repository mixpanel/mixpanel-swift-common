//
//  MixpanelJSONLogicRule.swift
//  MixpanelSwiftCommon
//
//  Copyright 2026 Mixpanel, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  Public entry point to the vendored json-logic-swift engine (Vendor/JSONLogicSwift). The engine's
//  own types stay internal; consumers see only `MixpanelJSONLogicRule` and `MixpanelJSON`.
//

import Foundation

/// A JSON value as seen by a custom JSONLogic operator.
///
/// Custom operators receive their (already evaluated) arguments as a `MixpanelJSON` and return one.
/// Numbers keep the distinction JSON makes between integers and floating-point values: `1` is
/// `.int(1)`, `1.0` is `.double(1.0)`, and `true` is `.bool(true)`.
public enum MixpanelJSON: Equatable, Sendable {
    case null
    case bool(Bool)
    case int(Int64)
    case double(Double)
    case string(String)
    case array([MixpanelJSON])
    case dictionary([String: MixpanelJSON])

    /// The wrapped value when this is `.bool`, otherwise nil.
    public var bool: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }

    /// The wrapped value when this is `.int`, otherwise nil.
    public var int: Int64? {
        if case .int(let value) = self { return value }
        return nil
    }

    /// The wrapped value when this is `.double`, otherwise nil.
    public var double: Double? {
        if case .double(let value) = self { return value }
        return nil
    }

    /// The wrapped value when this is `.string`, otherwise nil.
    public var string: String? {
        if case .string(let value) = self { return value }
        return nil
    }

    /// The wrapped value when this is `.array`, otherwise nil.
    public var array: [MixpanelJSON]? {
        if case .array(let value) = self { return value }
        return nil
    }

    /// The wrapped value when this is `.dictionary`, otherwise nil.
    public var dictionary: [String: MixpanelJSON]? {
        if case .dictionary(let value) = self { return value }
        return nil
    }

    /// Converts a Foundation JSON object, as produced by `JSONSerialization`, into a `MixpanelJSON`.
    ///
    /// `nil` and `NSNull` become `.null`. Values that have no JSON representation (for example a
    /// `Date` or a custom class) also become `.null`.
    public init(_ value: Any?) {
        self.init(vendored: JSON(value as Any))
    }

    // MARK: - Bridging to the vendored engine

    init(vendored json: JSON) {
        switch json {
            case .Null, .Error:
                self = .null
            case .Bool(let value):
                self = .bool(value)
            case .Int(let value):
                self = .int(value)
            case .Double(let value):
                self = .double(value)
            case .String(let value):
                self = .string(value)
            case .Array(let values):
                self = .array(values.map(MixpanelJSON.init(vendored:)))
            case .Dictionary(let values):
                self = .dictionary(values.mapValues(MixpanelJSON.init(vendored:)))
        }
    }

    var vendored: JSON {
        switch self {
            case .null:
                return .Null
            case .bool(let value):
                return .Bool(value)
            case .int(let value):
                return .Int(value)
            case .double(let value):
                return .Double(value)
            case .string(let value):
                return .String(value)
            case .array(let values):
                return .Array(values.map { $0.vendored })
            case .dictionary(let values):
                return .Dictionary(values.mapValues { $0.vendored })
        }
    }
}

/// A parsed JSONLogic rule.
///
/// The rule follows jsonlogic.com semantics (all standard operators, including type coercion) and
/// is evaluated by the vendored json-logic-swift 1.2.4 engine. Consumers can add operators through
/// `customOperators`; the engine hands each custom operator its evaluated arguments and uses the
/// returned value in place of the operator call.
///
/// Parse once, evaluate many times. A rule is immutable after `init` and may be evaluated
/// concurrently from any thread, provided the custom operators are themselves thread-safe (they are
/// `@Sendable` closures for that reason).
///
/// A rule must evaluate to a JSON boolean. Truthy non-boolean results such as `1` or `"yes"` are not
/// coerced; they throw `EvaluationError.resultNotBoolean`.
///
/// ```swift
/// let rule = try MixpanelJSONLogicRule(#"{"and": [{"===": [{"var": "plan"}, "pro"]}, {">": [{"var": "seats"}, 5]}]}"#)
/// try rule.evaluate(data: #"{"plan": "pro", "seats": 12}"#)  // true
/// ```
public struct MixpanelJSONLogicRule: @unchecked Sendable {

    /// A custom operator. Receives the operator's evaluated arguments (an array when the rule passes
    /// several) and returns the operator's result.
    public typealias CustomOperator = @Sendable (MixpanelJSON?) -> MixpanelJSON

    public enum EvaluationError: Error, Equatable, LocalizedError {
        /// The rule is not valid JSON, or is a JSON shape the engine cannot parse.
        case invalidRule(String)
        /// The rule uses an operator that is neither a jsonlogic.com operator nor a registered custom one.
        case unsupportedOperator(String)
        /// The engine could not read the data. Rare in practice: unparseable data makes `var` resolve
        /// to null rather than fail, so most malformed input surfaces as a `false` result instead.
        case invalidData(String)
        /// The rule evaluated to a value that is not a JSON boolean.
        case resultNotBoolean(String)

        public var errorDescription: String? {
            switch self {
                case .invalidRule(let detail):
                    return "Invalid JSONLogic rule: \(detail)"
                case .unsupportedOperator(let name):
                    return "Unsupported JSONLogic operator '\(name)'"
                case .invalidData(let detail):
                    return "Invalid JSONLogic data: \(detail)"
                case .resultNotBoolean(let detail):
                    return "JSONLogic rule did not evaluate to a boolean: \(detail)"
            }
        }

        /// Maps the vendored engine's errors onto the public error type.
        fileprivate init(_ error: Error) {
            switch error {
                case let error as EvaluationError:
                    self = error
                case let error as JSONLogicError:
                    switch error {
                        case .canNotParseJSONRule(let detail):
                            self = .invalidRule(detail)
                        case .canNotParseJSONData(let detail):
                            self = .invalidData(detail)
                        case .canNotConvertResultToType:
                            self = .resultNotBoolean("expected a boolean result")
                    }
                case let error as ParseError:
                    switch error {
                        case .UnimplementedExpressionFor(let name):
                            self = .unsupportedOperator(name)
                        case .GenericError(let detail):
                            self = .invalidRule(detail)
                    }
                default:
                    self = .invalidRule("\(error)")
            }
        }
    }

    // The vendored engine caches the parsed expression tree; it is immutable after init.
    private let logic: JsonLogic

    /// Parses `rule` and caches the expression tree.
    ///
    /// - Parameters:
    ///   - rule: A JSONLogic rule serialised as a JSON string.
    ///   - customOperators: Additional operators keyed by the operator name used in rules.
    /// - Throws: `EvaluationError.invalidRule` or `EvaluationError.unsupportedOperator`.
    public init(_ rule: String, customOperators: [String: CustomOperator] = [:]) throws {
        let bridged: [String: (JSON?) -> JSON]? =
            customOperators.isEmpty
            ? nil
            : customOperators.mapValues { custom in
                { json in custom(json.map(MixpanelJSON.init(vendored:))).vendored }
            }
        do {
            logic = try JsonLogic(rule, customOperators: bridged)
        } catch {
            throw EvaluationError(error)
        }
    }

    /// Evaluates the rule.
    ///
    /// - Parameter data: A JSON object serialised as a string, read by `var` operators. Pass nil for
    ///   rules that do not reference data.
    /// - Returns: The boolean the rule evaluated to.
    /// - Throws: `EvaluationError.invalidData` or `EvaluationError.resultNotBoolean`.
    public func evaluate(data: String? = nil) throws -> Bool {
        do {
            return try logic.applyRule(to: data)
        } catch {
            throw EvaluationError(error)
        }
    }

    /// Parses and evaluates `rule` in one step. Prefer `init` plus `evaluate(data:)` when the same
    /// rule is applied more than once.
    public static func evaluate(
        _ rule: String,
        data: String? = nil,
        customOperators: [String: CustomOperator] = [:]
    ) throws -> Bool {
        return try MixpanelJSONLogicRule(rule, customOperators: customOperators).evaluate(data: data)
    }
}
