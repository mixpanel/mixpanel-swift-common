//
//  MixpanelJSONLogicRuleTests.swift
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
//  Covers the public boundary of the vendored JSONLogic engine: parsing, evaluation, error mapping,
//  custom operators and the MixpanelJSON bridge. Engine semantics themselves are covered by the
//  upstream suite under Vendored/JSONLogicSwift.
//

import Foundation
import Testing

@testable import MixpanelSwiftCommon

@Suite("MixpanelJSONLogicRule")
struct MixpanelJSONLogicRuleTests {

    // MARK: - Evaluation

    @Test("Parsed rule evaluates against data")
    func evaluatesAgainstData() throws {
        let rule = try MixpanelJSONLogicRule(
            #"{"and": [{"===": [{"var": "plan"}, "pro"]}, {">": [{"var": "seats"}, 5]}]}"#
        )
        #expect(try rule.evaluate(data: #"{"plan": "pro", "seats": 12}"#) == true)
        #expect(try rule.evaluate(data: #"{"plan": "pro", "seats": 3}"#) == false)
        #expect(try rule.evaluate(data: #"{"plan": "free", "seats": 12}"#) == false)
    }

    @Test("Rule without data references evaluates with nil data")
    func evaluatesWithoutData() throws {
        #expect(try MixpanelJSONLogicRule(#"{"===": [1, 1]}"#).evaluate() == true)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"!": [true]}"#) == false)
    }

    @Test("Missing variables resolve to null, as on jsonlogic.com")
    func missingVariableIsNull() throws {
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"==": [{"var": "absent"}, null]}"#, data: "{}") == true)
        // `missing` returns the array of absent keys; `!` of an empty array is true.
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"!": [{"missing": ["a"]}]}"#, data: #"{"a": 1}"#) == true)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"!": [{"missing": ["a"]}]}"#, data: "{}") == false)
        // The bare array is not a boolean result.
        #expect(throws: MixpanelJSONLogicRule.EvaluationError.self) {
            try MixpanelJSONLogicRule.evaluate(#"{"missing": ["a"]}"#, data: "{}")
        }
    }

    @Test("Standard operators keep jsonlogic.com coercion semantics")
    func standardOperatorSemantics() throws {
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"==": [1, "1"]}"#) == true)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"===": [1, "1"]}"#) == false)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"in": ["b", ["a", "b"]]}"#) == true)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"in": ["pan", "Mixpanel"]}"#) == true)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"<": [1, 2, 3]}"#) == true)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"if": [false, true, false]}"#) == false)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"!!": [{"var": "x"}]}"#, data: #"{"x": "yes"}"#) == true)
    }

    // MARK: - Errors

    @Test("Invalid rule JSON throws invalidRule")
    func invalidRule() {
        #expect(throws: MixpanelJSONLogicRule.EvaluationError.self) {
            try MixpanelJSONLogicRule("not json")
        }
        do {
            _ = try MixpanelJSONLogicRule(#"{"===": [1, 1"#)
            Issue.record("expected a throw")
        } catch let error as MixpanelJSONLogicRule.EvaluationError {
            guard case .invalidRule = error else {
                Issue.record("expected invalidRule, got \(error)")
                return
            }
        } catch {
            Issue.record("unexpected error type \(error)")
        }
    }

    @Test("Unknown operator throws unsupportedOperator with the operator name")
    func unsupportedOperator() {
        #expect(throws: MixpanelJSONLogicRule.EvaluationError.unsupportedOperator("frobnicate")) {
            try MixpanelJSONLogicRule(#"{"frobnicate": [1, 2]}"#)
        }
    }

    @Test("Non-boolean result throws resultNotBoolean")
    func resultNotBoolean() {
        #expect(throws: MixpanelJSONLogicRule.EvaluationError.resultNotBoolean("expected a boolean result")) {
            try MixpanelJSONLogicRule.evaluate(#"{"var": "n"}"#, data: #"{"n": 1}"#)
        }
        #expect(throws: MixpanelJSONLogicRule.EvaluationError.resultNotBoolean("expected a boolean result")) {
            try MixpanelJSONLogicRule.evaluate(#"{"+": [1, 2]}"#)
        }
        #expect(throws: MixpanelJSONLogicRule.EvaluationError.resultNotBoolean("expected a boolean result")) {
            try MixpanelJSONLogicRule.evaluate(#"{"var": "missing"}"#, data: "{}")
        }
    }

    @Test("Unparseable data behaves like an empty object, matching upstream")
    func unparseableData() throws {
        // The vendored engine resolves `var` against unparseable data to null rather than throwing,
        // so a filter on a property "fails closed" to false. Locked in so a future engine change
        // cannot silently alter feature-flag targeting.
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"===": [{"var": "a"}, 1]}"#, data: "not json") == false)
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"==": [{"var": "a"}, null]}"#, data: "not json") == true)
    }

    @Test("Errors have descriptions")
    func errorDescriptions() {
        let errors: [MixpanelJSONLogicRule.EvaluationError] = [
            .invalidRule("x"), .unsupportedOperator("x"), .invalidData("x"), .resultNotBoolean("x"),
        ]
        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }

    // MARK: - Custom operators

    @Test("Custom operator receives evaluated arguments and its result is used")
    func customOperatorIsCalled() throws {
        let received = LockedBox<MixpanelJSON?>(nil)
        let operators: [String: MixpanelJSONLogicRule.CustomOperator] = [
            "sum_is": { args in
                received.value = args
                guard let values = args?.array, values.count == 2, let expected = values[1].int else {
                    return .bool(false)
                }
                let total = (values[0].array ?? []).reduce(Int64(0)) { $0 + ($1.int ?? 0) }
                return .bool(total == expected)
            }
        ]
        let rule = try MixpanelJSONLogicRule(
            #"{"sum_is": [[{"var": "a"}, {"var": "b"}], 3]}"#, customOperators: operators)

        #expect(try rule.evaluate(data: #"{"a": 1, "b": 2}"#) == true)
        #expect(received.value == .array([.array([.int(1), .int(2)]), .int(3)]))
        #expect(try rule.evaluate(data: #"{"a": 1, "b": 1}"#) == false)
    }

    @Test("Custom operator result can feed a standard operator")
    func customOperatorComposes() throws {
        let operators: [String: MixpanelJSONLogicRule.CustomOperator] = [
            "plus": { args in
                let total = (args?.array ?? []).reduce(Int64(0)) { $0 + ($1.int ?? 0) }
                return .int(total)
            }
        ]
        #expect(
            try MixpanelJSONLogicRule.evaluate(#"{"===": [{"plus": [1, 2]}, 3]}"#, customOperators: operators) == true)
        #expect(
            try MixpanelJSONLogicRule.evaluate(#"{">": [{"plus": [1, 2]}, 5]}"#, customOperators: operators) == false)
    }

    @Test("Custom operators do not leak between rules")
    func customOperatorsAreScopedToRule() throws {
        let operators: [String: MixpanelJSONLogicRule.CustomOperator] = ["always": { _ in .bool(true) }]
        #expect(try MixpanelJSONLogicRule.evaluate(#"{"always": []}"#, customOperators: operators) == true)
        #expect(throws: MixpanelJSONLogicRule.EvaluationError.unsupportedOperator("always")) {
            try MixpanelJSONLogicRule(#"{"always": []}"#)
        }
    }

    // MARK: - MixpanelJSON bridge

    @Test("MixpanelJSON is built from JSONSerialization output with number kinds preserved")
    func mixpanelJSONFromFoundation() throws {
        let data = #"{"i": 1, "d": 1.5, "b": true, "s": "x", "n": null, "a": [1, "two"], "o": {"k": false}}"#
        let object = try JSONSerialization.jsonObject(with: Data(data.utf8))
        let json = MixpanelJSON(object)

        #expect(
            json
                == .dictionary([
                    "i": .int(1),
                    "d": .double(1.5),
                    "b": .bool(true),
                    "s": .string("x"),
                    "n": .null,
                    "a": .array([.int(1), .string("two")]),
                    "o": .dictionary(["k": .bool(false)]),
                ])
        )
        #expect(json.dictionary?["i"]?.int == 1)
        #expect(json.dictionary?["d"]?.double == 1.5)
        #expect(json.dictionary?["b"]?.bool == true)
        #expect(json.dictionary?["s"]?.string == "x")
        #expect(json.dictionary?["a"]?.array?.count == 2)
    }

    @Test("MixpanelJSON maps nil, NSNull and unsupported values to null")
    func mixpanelJSONNullHandling() {
        #expect(MixpanelJSON(nil) == .null)
        #expect(MixpanelJSON(NSNull()) == .null)
        #expect(MixpanelJSON(Date()) == .null)
    }

    @Test("MixpanelJSON round-trips through the vendored representation")
    func mixpanelJSONRoundTrip() {
        let value: MixpanelJSON = .dictionary([
            "a": .array([.int(1), .double(2.5), .string("s"), .bool(true), .null]),
            "o": .dictionary(["nested": .array([])]),
        ])
        #expect(MixpanelJSON(vendored: value.vendored) == value)
        #expect(MixpanelJSON(vendored: .Error(.notJSONValue)) == .null)
    }

    // MARK: - Concurrency

    @Test("One parsed rule can be evaluated concurrently")
    func concurrentEvaluation() throws {
        let rule = try MixpanelJSONLogicRule(
            #"{"semver_ok": [{"var": "v"}]}"#,
            customOperators: ["semver_ok": { args in .bool(args?.array?.first?.string == "1.2.3") }]
        )
        let failures = LockedBox(0)
        DispatchQueue.concurrentPerform(iterations: 200) { i in
            let data = i % 2 == 0 ? #"{"v": "1.2.3"}"# : #"{"v": "0.0.1"}"#
            let want = i % 2 == 0
            if (try? rule.evaluate(data: data)) != want {
                failures.value += 1
            }
        }
        #expect(failures.value == 0)
    }
}

/// Minimal lock-protected box for asserting from inside @Sendable closures.
private final class LockedBox<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: Value

    init(_ value: Value) {
        stored = value
    }

    var value: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return stored
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            stored = newValue
        }
    }
}
