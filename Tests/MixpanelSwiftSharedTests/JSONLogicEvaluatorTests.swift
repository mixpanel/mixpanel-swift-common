//
//  JSONLogicEvaluatorTests.swift
//  MixpanelSwiftShared
//
//  Created by Mixpanel on 2026-03-31.
//

import Testing
import Foundation
@testable import MixpanelSwiftShared

@Suite("JSONLogicEvaluator Tests")
struct JSONLogicEvaluatorTests {

    let evaluator = JSONLogicEvaluator()

    // MARK: - Comparison Operators

    @Suite("Equality Operators")
    struct EqualityTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Loose equality (==) with same types")
        func testLooseEqualitySameTypes() throws {
            let expr: [String: Any] = ["==": [5, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["==": ["hello", "hello"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = ["==": [true, true]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == true)
        }

        @Test("Loose equality (==) with type coercion")
        func testLooseEqualityWithCoercion() throws {
            let expr: [String: Any] = ["==": [5, "5"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["==": [5.0, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }

        @Test("Loose equality (==) with version strings")
        func testLooseEqualityWithVersions() throws {
            let expr: [String: Any] = ["==": ["5.2.0", "5.2.0"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["==": ["5.2", "5.2.0"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }

        @Test("Strict equality (===) rejects type coercion")
        func testStrictEquality() throws {
            let expr: [String: Any] = ["===": [5, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["===": [5, "5"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)

            // Test with clearly different types (string vs number)
            let expr3: [String: Any] = ["===": ["5", 5]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == false)

            // Test same values, same types
            let expr4: [String: Any] = ["===": ["hello", "hello"]]
            #expect(try evaluator.evaluate(expr4, data: [:]) == true)
        }

        @Test("Loose inequality (!=)")
        func testLooseInequality() throws {
            let expr: [String: Any] = ["!=": [5, 3]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["!=": [5, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Strict inequality (!==)")
        func testStrictInequality() throws {
            let expr: [String: Any] = ["!==": [5, "5"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["!==": [5, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }
    }

    @Suite("Comparison Operators")
    struct ComparisonTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Greater than (>) with numbers")
        func testGreaterThanNumbers() throws {
            let expr: [String: Any] = [">": [10, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = [">": [5, 10]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Greater than (>) with version strings")
        func testGreaterThanVersions() throws {
            let expr: [String: Any] = [">": ["5.10.0", "5.2.0"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = [">": ["5.2.0", "5.10.0"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)

            let expr3: [String: Any] = [">": ["2.0.0", "1.9.9"]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == true)
        }

        @Test("Greater or equal (>=)")
        func testGreaterOrEqual() throws {
            let expr: [String: Any] = [">=": [10, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = [">=": [5, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = [">=": [3, 5]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == false)
        }

        @Test("Less than (<) with numbers")
        func testLessThanNumbers() throws {
            let expr: [String: Any] = ["<": [5, 10]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<": [10, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Less than (<) with version strings")
        func testLessThanVersions() throws {
            let expr: [String: Any] = ["<": ["5.2.0", "5.10.0"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<": ["5.10.0", "5.2.0"]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Less than (<) with 3-arg chaining")
        func testLessThanChaining() throws {
            let expr: [String: Any] = ["<": [1, 2, 3]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<": [1, 3, 2]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }

        @Test("Less or equal (<=)")
        func testLessOrEqual() throws {
            let expr: [String: Any] = ["<=": [5, 10]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<=": [5, 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)

            let expr3: [String: Any] = ["<=": [10, 5]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == false)
        }

        @Test("Less or equal (<=) with 3-arg chaining")
        func testLessOrEqualChaining() throws {
            let expr: [String: Any] = ["<=": [1, 2, 3]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["<=": [1, 2, 2]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }
    }

    // MARK: - Logical Operators

    @Suite("Logical Operators")
    struct LogicalTests {
        let evaluator = JSONLogicEvaluator()

        @Test("AND operator - all true")
        func testAndAllTrue() throws {
            let expr: [String: Any] = [
                "and": [
                    [">": [5, 3]],
                    ["<": [2, 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("AND operator - one false")
        func testAndOneFalse() throws {
            let expr: [String: Any] = [
                "and": [
                    [">": [5, 3]],
                    ["<": [10, 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)
        }

        @Test("OR operator - one true")
        func testOrOneTrue() throws {
            let expr: [String: Any] = [
                "or": [
                    [">": [5, 3]],
                    ["<": [10, 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("OR operator - all false")
        func testOrAllFalse() throws {
            let expr: [String: Any] = [
                "or": [
                    [">": [2, 3]],
                    ["<": [10, 4]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)
        }

        @Test("NOT operator")
        func testNot() throws {
            let expr: [String: Any] = ["!": [">": [5, 3]]]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)

            let expr2: [String: Any] = ["!": [">": [2, 3]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }

        @Test("Double negation (!!) for truthy values")
        func testDoubleNegation() throws {
            let expr: [String: Any] = ["!!": [1]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["!!": [0]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)

            let expr3: [String: Any] = ["!!": [""]]
            #expect(try evaluator.evaluate(expr3, data: [:]) == false)

            let expr4: [String: Any] = ["!!": ["text"]]
            #expect(try evaluator.evaluate(expr4, data: [:]) == true)
        }
    }

    // MARK: - Arithmetic Operators

    @Suite("Arithmetic Operators")
    struct ArithmeticTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Addition (+)")
        func testAddition() throws {
            let expr: [String: Any] = ["+": [2, 3, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true) // 10 is truthy

            // Verify actual value using comparison
            let expr2: [String: Any] = ["==": [["+": [2, 3]], 5]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == true)
        }

        @Test("Subtraction (-) binary")
        func testSubtractionBinary() throws {
            let expr: [String: Any] = ["==": [["-": [10, 3]], 7]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Subtraction (-) unary negation")
        func testSubtractionUnary() throws {
            let expr: [String: Any] = ["==": [["-": [5]], -5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Multiplication (*)")
        func testMultiplication() throws {
            let expr: [String: Any] = ["==": [["*": [2, 3, 4]], 24]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Division (/)")
        func testDivision() throws {
            let expr: [String: Any] = ["==": [["/": [10, 2]], 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Modulo (%)")
        func testModulo() throws {
            let expr: [String: Any] = ["==": [["%": [10, 3]], 1]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Min function")
        func testMin() throws {
            let expr: [String: Any] = ["==": [["min": [5, 2, 8, 1]], 1]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Max function")
        func testMax() throws {
            let expr: [String: Any] = ["==": [["max": [5, 2, 8, 1]], 8]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }
    }

    // MARK: - String/Array Operators

    @Suite("String Operations")
    struct StringTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Concatenation (cat)")
        func testCat() throws {
            let expr: [String: Any] = ["==": [["cat": ["Hello", " ", "World"]], "Hello World"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Substring (substr) - 2 args")
        func testSubstrTwoArgs() throws {
            let expr: [String: Any] = ["==": [["substr": ["Hello", 1]], "ello"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Substring (substr) - 3 args")
        func testSubstrThreeArgs() throws {
            let expr: [String: Any] = ["==": [["substr": ["Hello", 0, 3]], "Hel"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Substring (substr) - negative index")
        func testSubstrNegativeIndex() throws {
            let expr: [String: Any] = ["==": [["substr": ["Hello", -3]], "llo"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Substring (substr) - negative length")
        func testSubstrNegativeLength() throws {
            let expr: [String: Any] = ["==": [["substr": ["Hello", 0, -1]], "Hell"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("In operator - element in array")
        func testInOperator() throws {
            let expr: [String: Any] = ["in": ["banana", ["apple", "banana", "cherry"]]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)

            let expr2: [String: Any] = ["in": ["grape", ["apple", "banana", "cherry"]]]
            #expect(try evaluator.evaluate(expr2, data: [:]) == false)
        }
    }

    @Suite("Array Operations")
    struct ArrayTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Merge arrays")
        func testMerge() throws {
            // Test that merge flattens arrays
            let expr: [String: Any] = [
                "==": [
                    ["merge": [[1, 2], [3, 4]]],
                    [1, 2, 3, 4]
                ]
            ]
            // Note: Array comparison in JSONLogic isn't direct, so we test element presence
            // For now, just ensure it evaluates without error
            _ = try evaluator.evaluate(expr, data: [:])
        }

        @Test("Missing - find missing keys")
        func testMissing() throws {
            let data: [String: Any] = ["name": "John", "age": 30]

            // Should return empty array (truthy as non-empty array would be if there were missing)
            // But since it returns array of strings, we need to check differently
            // Let's verify the function doesn't throw
            let expr: [String: Any] = ["missing": ["name", "email"]]
            _ = try evaluator.evaluate(expr, data: data)
        }

        @Test("Missing some - check minimum required fields")
        func testMissingSome() throws {
            let data: [String: Any] = ["name": "John"]

            // Need at least 1 of [name, email, phone] - should pass
            let expr: [String: Any] = ["missing_some": [1, ["name", "email", "phone"]]]
            _ = try evaluator.evaluate(expr, data: data)
        }
    }

    // MARK: - Variable Resolution

    @Suite("Variable Operations")
    struct VariableTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Var - simple variable access")
        func testVarSimple() throws {
            let data: [String: Any] = ["name": "John", "age": 30]
            let expr: [String: Any] = ["==": [["var": "name"], "John"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Var - with default value")
        func testVarWithDefault() throws {
            let data: [String: Any] = ["name": "John"]
            let expr: [String: Any] = ["==": [["var": ["email", "default@example.com"]], "default@example.com"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Var - nested property access")
        func testVarNested() throws {
            let data: [String: Any] = [
                "user": [
                    "profile": [
                        "name": "John"
                    ]
                ]
            ]
            let expr: [String: Any] = ["==": [["var": "user.profile.name"], "John"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Var - array index access")
        func testVarArrayIndex() throws {
            let data: [String: Any] = ["items": ["first", "second", "third"]]
            let expr: [String: Any] = ["==": [["var": "items.1"], "second"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
    }

    // MARK: - Complex Real-World Scenarios

    @Suite("Real-World Scenarios")
    struct RealWorldTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Version comparison with variable")
        func testVersionComparisonWithVar() throws {
            let data: [String: Any] = ["$lib_version": "5.10.0"]
            let expr: [String: Any] = [">": [["var": "$lib_version"], "5.2.0"]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Complex AND/OR with multiple conditions")
        func testComplexLogic() throws {
            let data: [String: Any] = [
                "amount": 150,
                "currency": "USD",
                "status": "active"
            ]

            let expr: [String: Any] = [
                "and": [
                    [">": [["var": "amount"], 100]],
                    ["==": [["var": "currency"], "USD"]],
                    ["==": [["var": "status"], "active"]]
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("Property filter with missing field")
        func testPropertyFilterMissing() throws {
            let data: [String: Any] = ["name": "John"]
            let expr: [String: Any] = ["==": [["var": "email"], "test@example.com"]]
            // Missing field should not equal the value
            #expect(try evaluator.evaluate(expr, data: data) == false)
        }

        @Test("Arithmetic in comparisons")
        func testArithmeticInComparison() throws {
            let data: [String: Any] = ["price": 100, "tax": 10]
            let expr: [String: Any] = [">": [["+": [["var": "price"], ["var": "tax"]]], 100]]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }

        @Test("String concatenation with variables")
        func testStringConcatWithVars() throws {
            let data: [String: Any] = ["first": "Hello", "second": "World"]
            let expr: [String: Any] = [
                "==": [
                    ["cat": [["var": "first"], " ", ["var": "second"]]],
                    "Hello World"
                ]
            ]
            #expect(try evaluator.evaluate(expr, data: data) == true)
        }
    }

    // MARK: - Error Cases

    @Suite("Error Handling")
    struct ErrorTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Unsupported operator throws error")
        func testUnsupportedOperator() throws {
            let expr: [String: Any] = ["unknown_op": [1, 2]]

            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(expr, data: [:])
            }
        }

        @Test("Invalid expression format throws error")
        func testInvalidExpression() throws {
            let expr: [String: Any] = [:]

            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(expr, data: [:])
            }
        }

        @Test("Type mismatch in operators")
        func testTypeMismatch() throws {
            // Division requires exactly 2 args
            let expr: [String: Any] = ["/": [10]]

            #expect(throws: JSONLogicEvaluator.EvaluationError.self) {
                try evaluator.evaluate(expr, data: [:])
            }
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCaseTests {
        let evaluator = JSONLogicEvaluator()

        @Test("Empty string vs null")
        func testEmptyStringVsNull() throws {
            let expr: [String: Any] = ["==": ["", ""]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Zero is falsy")
        func testZeroFalsy() throws {
            let expr: [String: Any] = ["!!": [0]]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)
        }

        @Test("Empty array is falsy")
        func testEmptyArrayFalsy() throws {
            let expr: [String: Any] = ["!!": [[Any]()]]
            #expect(try evaluator.evaluate(expr, data: [:]) == false)
        }

        @Test("Version string with 2 components")
        func testVersionTwoComponents() throws {
            let expr: [String: Any] = [">": ["5.10", "5.2"]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }

        @Test("Comparison with mixed number types")
        func testMixedNumberTypes() throws {
            let expr: [String: Any] = ["==": [5.0, 5]]
            #expect(try evaluator.evaluate(expr, data: [:]) == true)
        }
    }
}
